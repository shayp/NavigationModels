function [metrics, learnedParams, smoothPsthExp, smoothPsthSim, ISI] = ...
    getModelMetricsAndParameters(config, spiketrain, stimulus, modelParams,...
    modelType, filter, numOfCoupledNeurons, couplingData, historyBaseVectors, couplingBaseVectors)

numOfFilters = 5;

% Set learned bias
learnedParams.biasParam = modelParams(1);

if config.fCoupling
    
    couplingParamsLength = config.numOfCouplingParams * numOfCoupledNeurons;
   
    % Spike history filter added
    numOfFilters = numOfFilters + 1;
   
    % Set spike history filter
    learnedParams.spikeHistory = historyBaseVectors * modelParams(2:1 + config.numOfHistoryParams)';
   
    if numOfCoupledNeurons > 0
        % Set coupling fiilters
        couplingParams = reshape(modelParams(2 + config.numOfHistoryParams:couplingParamsLength + config.numOfHistoryParams + 1), config.numOfCouplingParams, numOfCoupledNeurons);

        for i = 1:numOfCoupledNeurons
            learnedParams.couplingFilters(:,i) = couplingBaseVectors * couplingParams(:, i);
        end
        
        numOfFilters = numOfFilters + numOfCoupledNeurons;
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
    modelFiringRate(:,i) = simulateModelResponse(stimulus, tuningParams, learnedParams, config.fCoupling, numOfCoupledNeurons, couplingData, config.dt);   
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
[learnedParams.pos_param, learnedParams.hd_param, learnedParams.vel_param, learnedParams.border_param] = ...
    find_param(tuningParams, modelType, config.numOfPositionParams, config.numOfHeadDirectionParams, ...
    config.numOfVelocityParams, config.numOfDistanceFromBorderParams);

% IF the curves are not configured in the model, zeroize
if numel(learnedParams.pos_param) ~= config.numOfPositionParams
    learnedParams.pos_param = 0;
    numOfFilters = numOfFilters - 1;
end
if numel(learnedParams.hd_param) ~= config.numOfHeadDirectionParams
    learnedParams.hd_param = 0;
    numOfFilters = numOfFilters - 1;
end
if numel(learnedParams.vel_param) ~= config.numOfVelocityParams
    learnedParams.vel_param = 0;
    numOfFilters = numOfFilters - 1;
end
if numel(learnedParams.border_param) ~= config.numOfDistanceFromBorderParams
    learnedParams.border_param = 0;
    numOfFilters = numOfFilters - 1;
end

learnedParams.numOfFilters = numOfFilters;
end