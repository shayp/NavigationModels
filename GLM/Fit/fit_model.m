%% Description
% This code will section the data into 10 different portions. Each portion
% is drawn from across the entire recording session. It will then
% fit the model to 9 sections, and test the model performance on the
% remaining section. This procedure will be repeated 10 times, with all
% possible unique testing sections. The fraction of variance explained, the
% mean-squared error, the log-likelihood increase, and the mean square
% error will be computed for each test data set. In addition, the learned
% parameters will be recorded for each section.
function [testFit,trainFit,param_mean] = fit_model(features, spiketrain, filter, modelType, numFolds, config, designMatrix)

%% Initialize matrices and section the data for k-fold cross-validation
modelType
[~,numCol] = size(features);

% divide the data up into 5*num_folds pieces
lengthOfFold = floor(numel(spiketrain) / numFolds);
% initialize matrices

% var ex, correlation, llh increase, mse, # of spikes, length of test data
testFit = nan(numFolds,6); 

% var ex, correlation, llh increase, mse, # of spikes, length of train data
trainFit = nan(numFolds,6); 
if config.fCoupling
    numOfCouplingParams = size(designMatrix,2);
else
    numOfCouplingParams = 0;
end
numOfLearnedParams = numCol + numOfCouplingParams + 1;
paramMat = nan(numFolds,numOfLearnedParams);
%% perform k-fold cross validation
for k = 1:numFolds
    fprintf('\t\t- Cross validation fold %d of %d\n', k, numFolds);
    
        test_ind  = (k-1) * lengthOfFold + 1:k * lengthOfFold;
        train_ind = setdiff(1:numel(spiketrain),test_ind);

    % get test data from edges - each test data chunk comes from entire session
    test_spikes = spiketrain(test_ind);
    fr_test = spiketrain(test_ind); %test spiking
    test_features = features(test_ind,:);
    if config.fCoupling
        test_designMat = designMatrix(test_ind,:);
    end
    
    % training data
    train_spikes = spiketrain(train_ind);
    fr_train = spiketrain(train_ind); %test spiking
    train_features = features(train_ind,:);
    if config.fCoupling
        train_designMat = designMatrix(train_ind,:);
    end
    opts = optimset('Gradobj','on','Hessian','on','Display','off');
    
    trainData{1} = train_features;
    testData{1} = test_features;

    if config.fCoupling
        trainData{2} = train_designMat;
        testData{2} = test_designMat;
    end
    trainData{3} = train_spikes;
    testData{3} = test_spikes;

    if k == 1
        init_param = zeros(numOfLearnedParams, 1);
        init_param(1) = -10;
    else
        init_param = param;
        %init_param = zeros(numOfLearnedParams, 1);
        init_param(1) = -10;
    end
    lossFunc  = @(param)ln_poisson_model(param,trainData,modelType, config, numOfCouplingParams);
    [param] = fminunc(lossFunc, init_param, opts);

    biasParam = param(1);

    if config.fCoupling
       spikeHistoryParam = param(2:1 + numOfCouplingParams); 
       tuningParams = param(2 + numOfCouplingParams:end);
    else
        tuningParams = param(2:end);
    end
    
    %%%%%%%%%%%%% TEST DATA %%%%%%%%%%%%%%%%%%%%%%%
    % compute the firing rate
    linearFilter_hat_test = test_features * tuningParams + biasParam;
    if config.fCoupling
        linearFilter_hat_test = linearFilter_hat_test + test_designMat * spikeHistoryParam;
    end
    fr_hat_test = exp(linearFilter_hat_test) * config.dt;
    
    test_ll = -1*  sum(fr_hat_test - fr_test.*linearFilter_hat_test);
    % compare between test fr and model fr
    sse = sum((fr_hat_test-fr_test).^2);
    sst = sum((fr_hat_test-mean(fr_test)).^2);
    if sst == 0
        sst = sse;
    end
    varExplain_test = 1-(sse/sst);
    
    % compute correlation
    correlation_test = corr(fr_test,fr_hat_test,'type','Pearson');
    
    % compute llh increase from "mean firing rate model" - NO SMOOTHING
    log_llh_test_model = nansum(fr_hat_test - fr_test.*log(fr_hat_test) + log(factorial(fr_test))) / sum(fr_test);
    mean_fr_test = nanmean(fr_test);
    log_llh_test_mean = nansum(mean_fr_test - fr_test .* log(mean_fr_test) + log(factorial(fr_test))) / sum(fr_test);
    log_llh_test = log(2) * (-log_llh_test_model + log_llh_test_mean)
    if log_llh_test == inf || log_llh_test == -inf
        log_llh_test = nan;
    end
    % compute MSE
    mse_test = nanmean((fr_hat_test-fr_test).^2);

    % fill in all the relevant values for the test fit cases
    testFit(k,:) = [varExplain_test correlation_test log_llh_test mse_test sum(test_spikes) numel(test_ind)];

    %%%%%%%%%%%%% TRAINING DATA %%%%%%%%%%%%%%%%%%%%%%%
    % compute the firing rate
    
    linearFilter_hat_train = train_features * tuningParams + biasParam;
    if config.fCoupling
        linearFilter_hat_train = linearFilter_hat_train + train_designMat * spikeHistoryParam;
    end
    fr_hat_train = exp(linearFilter_hat_train) / config.dt;
    
    % compare between test fr and model fr
    sse = sum((fr_hat_train-fr_train).^2);
    sst = sum((fr_hat_train-mean(fr_train)).^2);
    varExplain_train = 1-(sse/sst);
    
    % compute correlation
    correlation_train = corr(fr_train,fr_hat_train,'type','Pearson');
    
%     log_llh_train_model = nansum(linearFilter_hat_train - train_spikes.*log(linearFilter_hat_train) + log(factorial(train_spikes))) / sum(train_spikes);
%     mean_fr_train = nanmean(train_spikes);
%     log_llh_train_mean = nansum(mean_fr_train - train_spikes .* log(mean_fr_train) + log(factorial(train_spikes))) / sum(train_spikes);
%     log_llh_train = log(2) * (-log_llh_train_model + log_llh_train_mean);
% 
%     if log_llh_train == inf || log_llh_train == -inf
%         log_llh_train = 0;
%     end
    
    train_ll = -1 * sum(fr_hat_train - fr_train.*linearFilter_hat_train);


    % compute MSE
    mse_train = nanmean((fr_hat_train - fr_train).^2);
    trainFit(k,:) = [varExplain_train correlation_train train_ll mse_train sum(train_spikes) numel(train_ind)];
    if sum(train_spikes) ~= 0
        % save the parameters
        paramMat(k,:) = param;
    end

end

selectedInd = ~isnan(testFit(:,3));
param_mean = paramMat(selectedInd,:);
if sum(selectedInd) > 1
    param_mean = nanmean(param_mean);
end

return
