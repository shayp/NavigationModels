function [testFit,trainFit,param_mean] = fit_model(A,dt,spiketrain,filter,modelType,numFolds, numPos, numHD, numVel, numBorder)

%% Description
% This code will section the data into 10 different portions. Each portion
% is drawn from across the entire recording session. It will then
% fit the model to 9 sections, and test the model performance on the
% remaining section. This procedure will be repeated 10 times, with all
% possible unique testing sections. The fraction of variance explained, the
% mean-squared error, the log-likelihood increase, and the mean square
% error will be computed for each test data set. In addition, the learned
% parameters will be recorded for each section.


%% Initialize matrices and section the data for k-fold cross-validation

[~,numCol] = size(A);
% numOfSpikes = sum(spiketrain);
% numOfSPikesInSection = floor(numOfSpikes / numFolds);
% cumulativeSikeTrain = cumsum(spiketrain);
% foldStartIndexes = ones(numFolds + 1, 1);

sections = numFolds*5;

% divide the data up into 5*num_folds pieces
edges = round(linspace(1,numel(spiketrain)+1,sections+1));

% for i = 1:numFolds - 1
%     indexes = find(cumulativeSikeTrain >= numOfSPikesInSection * i & cumulativeSikeTrain <= numOfSPikesInSection * (i + 1));
%     selectedIndex = 1;
%     foldStartIndexes(i + 1) = indexes(selectedIndex);
% end
foldStartIndexes(numFolds + 1) = length(spiketrain);
% initialize matrices
testFit = nan(numFolds,6); % var ex, correlation, llh increase, mse, # of spikes, length of test data
trainFit = nan(numFolds,6); % var ex, correlation, llh increase, mse, # of spikes, length of train data
paramMat = nan(numFolds,numCol);

%% perform k-fold cross validation
for k = 1:numFolds
    fprintf('\t\t- Cross validation fold %d of %d\n', k, numFolds);
    
        % get test data from edges - each test data chunk comes from entire session
        test_ind  = [edges(k):edges(k+1)-1 edges(k+numFolds):edges(k+numFolds+1)-1 ...
        edges(k+2*numFolds):edges(k+2*numFolds+1)-1 edges(k+3*numFolds):edges(k+3*numFolds+1)-1 ...
        edges(k+4*numFolds):edges(k+4*numFolds+1)-1]   ;
        train_ind = setdiff(1:numel(spiketrain),test_ind);

%     % get test data from edges - each test data chunk comes from entire session
%     test_ind  = foldStartIndexes(k):(foldStartIndexes(k + 1) - 1);
%     train_ind = setdiff(1:numel(spiketrain), test_ind);
    test_spikes = spiketrain(test_ind); %test spiking
    smooth_spikes_test = conv(test_spikes,filter,'same'); %returns vector same size as original
    smooth_fr_test = smooth_spikes_test./dt;
    test_A = A(test_ind,:);
    
    % training data
    %train_ind = setdiff(1:numel(spiketrain),test_ind);
    train_spikes = spiketrain(train_ind);
    smooth_spikes_train = conv(train_spikes,filter,'same'); %returns vector same size as original
    smooth_fr_train = smooth_spikes_train./dt;
    train_A = A(train_ind,:);
    
    opts = optimset('Gradobj','on','Hessian','on','Display','off');
    
    data{1} = train_A; data{2} = train_spikes;
    if k == 1
        init_param = 1e-3*randn(numCol, 1);
    else
        init_param = param;
    end
    [param] = fminunc(@(param)ln_poisson_model(param,data,modelType, numPos, numHD, numVel, numBorder),init_param,opts);
    
    %%%%%%%%%%%%% TEST DATA %%%%%%%%%%%%%%%%%%%%%%%
    % compute the firing rate
    fr_hat_test = exp(test_A * param)/dt;
    smooth_fr_hat_test = conv(fr_hat_test,filter,'same'); %returns vector same size as original
    % compare between test fr and model fr
    sse = sum((smooth_fr_hat_test-smooth_fr_test).^2);
    sst = sum((smooth_fr_test-mean(smooth_fr_test)).^2);
    if sst == 0
        sst = sse;
    end
    varExplain_test = 1-(sse/sst);
    
    % compute correlation
    correlation_test = corr(smooth_fr_test,smooth_fr_hat_test,'type','Pearson');
    
    % compute llh increase from "mean firing rate model" - NO SMOOTHING
    liniearProjection = test_A * param;
    r = exp(liniearProjection); n = test_spikes; meanFR_test = nanmean(test_spikes); 

    if sum(n) == 0
        log_llh_test = NaN;
    else
        log_llh_test_model = nansum(r-n.*log2(r) + log2(factorial(n)))/sum(n); %note: log(gamma(n+1)) will be unstable if n is large (which it isn't here)
        log_llh_test_mean = nansum(meanFR_test-n.*log2(meanFR_test) + log2(factorial(n)))/sum(n);

        log_llh_test = (-log_llh_test_model + log_llh_test_mean);
    end
    
    % compute MSE
    mse_test = nanmean((smooth_fr_hat_test-smooth_fr_test).^2);

    % fill in all the relevant values for the test fit cases
    testFit(k,:) = [varExplain_test correlation_test log_llh_test mse_test sum(n) numel(test_ind)];

    %%%%%%%%%%%%% TRAINING DATA %%%%%%%%%%%%%%%%%%%%%%%
    % compute the firing rate
    fr_hat_train = exp(train_A * param)/dt;
    smooth_fr_hat_train = conv(fr_hat_train,filter,'same'); %returns vector same size as original
    
    % compare between test fr and model fr
    sse = sum((smooth_fr_hat_train-smooth_fr_train).^2);
    sst = sum((smooth_fr_train-mean(smooth_fr_train)).^2);
    varExplain_train = 1-(sse/sst);
    
    % compute correlation
    correlation_train = corr(smooth_fr_train,smooth_fr_hat_train,'type','Pearson');
    
    % compute log-likelihood
    r_train = exp(train_A * param); n_train = train_spikes; meanFR_train = nanmean(train_spikes);   
    log_llh_train_model = nansum(r_train-n_train.*log(r_train)+log(gamma(n_train+1)))/sum(n_train);
    log_llh_train_mean = nansum(meanFR_train-n_train.*log(meanFR_train)+log(gamma(n_train+1)))/sum(n_train);
    log_llh_train = (-log_llh_train_model + log_llh_train_mean);
    
    % compute MSE
    mse_train = nanmean((smooth_fr_hat_train-smooth_fr_train).^2);
    trainFit(k,:) = [varExplain_train correlation_train log_llh_train mse_train sum(n_train) numel(train_ind)];
    if sum(n) ~= 0
        % save the parameters
        paramMat(k,:) = param;
    end

end

param_mean = nanmean(paramMat);

return
