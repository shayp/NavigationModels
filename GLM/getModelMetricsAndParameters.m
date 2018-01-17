function [metrics, learnedParams, smoothPsthExp, smoothPsthSim, ISI, modelFiringRate, log_likekihood_final] = ...
    getModelMetricsAndParameters(config, spiketrain, stimulus, modelParams,...
    modelType, filter, numOfCoupledNeurons, couplingData, historyBaseVectors, couplingBaseVectors, thetaGrid, kFoldParams)

numOfFilters = 4;

% Set learned bias
learnedParams.biasParam = modelParams(1);
numFolds = size(kFoldParams,1);
if config.fCoupling
    
    couplingParamsLength = config.numOfCouplingParams * numOfCoupledNeurons;
   
   
    % Set spike history filter
    learnedParams.spikeHistory = mean(historyBaseVectors * kFoldParams(:, 2:1 + config.numOfHistoryParams)', 2);
   
    if numOfCoupledNeurons > 0
        % Set coupling fiilters
        kFoldcouplingParams = reshape(kFoldParams(:,2 + config.numOfHistoryParams:couplingParamsLength + config.numOfHistoryParams + 1), numFolds, config.numOfCouplingParams, numOfCoupledNeurons);
        couplingParams = reshape(modelParams(2 + config.numOfHistoryParams:couplingParamsLength + config.numOfHistoryParams + 1), config.numOfCouplingParams, numOfCoupledNeurons);

        for i = 1:numOfCoupledNeurons
            learnedParams.couplingFilters(:,i) = mean(couplingBaseVectors * kFoldcouplingParams(:,:, i)', 2);
        end
    end
    
    % Set tuning params
    tuningParams = modelParams(2 + config.numOfHistoryParams + couplingParamsLength:end);
else
    % Set tuning params
    tuningParams = modelParams(2:end);
end
config.fTheta = 0;
learnedParams.allTuningParams = tuningParams;
if sum(config.thetaMask & modelType) > 0
    config.fTheta = 1;
    learnedParams.thetaParam = tuningParams(end - config.numOfTheta + 1:end);
    tuningParams = tuningParams(1:end - config.numOfTheta);
end
learnedParams.tuningParams = tuningParams;
learnedParams.modelType = modelType;
simulationLength = length(spiketrain);
modelFiringRate = zeros(simulationLength, config.numOfRepeats);
simISI = [];
mean_fr = nanmean(spiketrain);
log_llh_mean = nansum(mean_fr - spiketrain .* log(mean_fr) + log(factorial(spiketrain))) / sum(spiketrain);
log_likekihood_final = 0;
selectedInd = 0;

for i = 1:config.numOfRepeats
    % Get simulated firing rate
    [modelFiringRate(:,i), modelLambdas] = simulateResponsePillow(stimulus, tuningParams, learnedParams, config.fCoupling, numOfCoupledNeurons, couplingData, config.dt, config, config.fTheta, thetaGrid,0, spiketrain);   
    log_llh_model = nansum(modelLambdas - spiketrain.*log(modelLambdas) + log(factorial(spiketrain))) / sum(spiketrain);
    log_llh = log(2) * (-log_llh_model + log_llh_mean);
    if log_llh > -1
        selectedInd = selectedInd + 1;
        log_likekihood_final = log_likekihood_final + log_llh;
        simISI = [simISI diff(find(modelFiringRate(:,i)))'];
        %modelFiringRate(:,i) = modelLambdas;
    else
        modelFiringRate(:,i) = modelFiringRate(:,i) -  modelFiringRate(:,i);
    end
end
log_likekihood_final = log_likekihood_final / selectedInd;
log_likekihood_final
selectedInd
summedFiringRate = sum(modelFiringRate,2) / selectedInd;

% Get psth and metrics 
[metrics, smoothPsthExp, smoothPsthSim, ISI] = ...
    estimateModelPerformance(config.dt, spiketrain, summedFiringRate, filter, config.windowSize);

maxSimISI = max(simISI);
simISIPr = zeros(maxSimISI, 1);
for j = 1:maxSimISI
    simISIPr(j) = sum(simISI == j);
end

simISIPr = simISIPr / sum(simISIPr);
simISITimes = linspace(1 * config.dt, maxSimISI * config.dt, maxSimISI);
ISI.simISITimes = simISITimes;
ISI.simISIPr = simISIPr;

% Get the learned tuning curves
[learnedParams.pos_param, learnedParams.hd_param, learnedParams.speed_param, learnedParams.theta_param] = ...
    find_param(learnedParams.allTuningParams, modelType, config.numOfPositionParams, config.numOfHeadDirectionParams, ...
    config.numOfSpeedBins, config.numOfTheta);

% IF the curves are not configured in the model, zeroize
if numel(learnedParams.pos_param) ~= config.numOfPositionParams
    learnedParams.pos_param = 0;
    numOfFilters = numOfFilters - 1;
end
if numel(learnedParams.hd_param) ~= config.numOfHeadDirectionParams
    learnedParams.hd_param = 0;
    numOfFilters = numOfFilters - 1;
end
if numel(learnedParams.speed_param) ~= config.numOfSpeedBins
    learnedParams.speed_param = 0;
    numOfFilters = numOfFilters - 1;
end
if numel(learnedParams.theta_param) ~= config.numOfTheta
    learnedParams.theta_param = 0;
    numOfFilters = numOfFilters - 1;
end

learnedParams.numOfFilters = numOfFilters;
end