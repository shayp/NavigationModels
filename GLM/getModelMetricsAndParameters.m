function [metrics, learnedParams, smoothPsthExp, smoothPsthSim, ISI, modelFiringRate] = ...
    getModelMetricsAndParameters(config, spiketrain, stimulus, modelParams,...
    modelType, filter, numOfCoupledNeurons, couplingData, historyBaseVectors, couplingBaseVectors)

numOfFilters = 4;

% Set learned bias
learnedParams.biasParam = modelParams(1);

if config.fCoupling
    
    couplingParamsLength = config.numOfCouplingParams * numOfCoupledNeurons;
   
   
    % Set spike history filter
    learnedParams.spikeHistory = historyBaseVectors * modelParams(2:1 + config.numOfHistoryParams)';
   
    if numOfCoupledNeurons > 0
        % Set coupling fiilters
        couplingParams = reshape(modelParams(2 + config.numOfHistoryParams:couplingParamsLength + config.numOfHistoryParams + 1), config.numOfCouplingParams, numOfCoupledNeurons);

        for i = 1:numOfCoupledNeurons
            learnedParams.couplingFilters(:,i) = couplingBaseVectors * couplingParams(:, i);
        end
            end
    
    % Set tuning params
    tuningParams = modelParams(2 + config.numOfHistoryParams + couplingParamsLength:end);
else
    % Set tuning params
    tuningParams = modelParams(2:end);
end

simulationLength = length(spiketrain);
modelFiringRate = zeros(simulationLength, config.numOfRepeats);
simISI = [];
for i = 1:config.numOfRepeats
    % Get simulated firing rate
    modelFiringRate(:,i) = simulateResponsePillow(stimulus, tuningParams, learnedParams, config.fCoupling, numOfCoupledNeurons, couplingData, config.dt);   
    simISI = [simISI diff(find(modelFiringRate(:,i)))'];
end

summedFiringRate = sum(modelFiringRate,2) / config.numOfRepeats;

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
[learnedParams.pos_param, learnedParams.hd_param, learnedParams.speed_param, learnedParams.speedHD_param] = ...
    find_param(tuningParams, modelType, config.numOfPositionParams, config.numOfHeadDirectionParams, ...
    config.numOfSpeedBins, config.numOfHDSpeedBins);

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
if numel(learnedParams.speedHD_param) ~= config.numOfHDSpeedBins
    learnedParams.speedHD_param = 0;
    numOfFilters = numOfFilters - 1;
end

learnedParams.numOfFilters = numOfFilters;
end