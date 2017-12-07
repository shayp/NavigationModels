function [config, learningData, features, numModels, testFit, trainFit, param] = runLearning(sessionName, data_path, neuronNumber, configFilePath, fCoupling, coupledNeurons)
addpath('General');
addpath('featureMaps');
addpath('Fit');
addpath('BuildPlots');
if fCoupling == 0
    numOfCoupledNeurons = 0;
else
    fCoupling = 1;
    numOfCoupledNeurons = length(coupledNeurons);
end

couplingData = [];


% Get learning data
[config, learningData, couplingData, validationData, validationCouplingData, expISI, posx, posy, boxSize,sampleRate,headDirection] = loadDataForLearning(data_path, configFilePath, neuronNumber, fCoupling, coupledNeurons);

hd_tuning = compute_1d_tuning_curve(learningData.headDirection, learningData.spiketrain, config.numOfHeadDirectionParams, 0, 2*pi);


% Build feature maps from the loaded data
features = buildFeatureMaps(config, learningData, hd_tuning);

validationFeatures = buildFeatureMaps(config, validationData,hd_tuning);

% Add spike history or coupling if needed
designMatrix = [];
if fCoupling
    designMatrix = getSpikeHistoryDataForLearning(config, learningData, numOfCoupledNeurons, couplingData);
end

features.designMatrix = designMatrix;

smooth_fr = conv(learningData.spiketrain, config.filter, 'same');

% Get experiment tuning curves
[pos_curve, hd_curve, speed_curve, speedHD_curve] = ...
    computeTuningCurves(learningData, features, config, smooth_fr);

% Plot experiment tuning curve
plotExperimentTuningCurves(config, features, pos_curve, hd_curve, speed_curve, speedHD_curve, neuronNumber, learningData, sessionName);


% Fit model
[numModels, testFit, trainFit, param, Models,modelType] = ...
    fitAllModels(learningData, config, features, fCoupling);

% Select best models
[topSingleCurve, selectedModel] = ...
    selectBestModel(testFit,config.numFolds, numModels);


validationStimulusSingle = getStimulusByModelNumber(topSingleCurve, validationFeatures.posgrid, validationFeatures.hdgrid, validationFeatures.speedgrid, validationFeatures.speedHDGrid);
% Get Single model perfomace and parameters
[metrics, learnedParams, smoothPsthExp, smoothPsthSim, ISI, modelFiringRate] = ...
    getModelMetricsAndParameters(config, validationData.spiketrain, validationStimulusSingle, param{topSingleCurve},...
    modelType{topSingleCurve}, config.filter, numOfCoupledNeurons, validationCouplingData,...
    learningData.historyBaseVectors, learningData.couplingBaseVectors);

% plot results
plotPerformanceAndParameters(config, learnedParams, metrics, smoothPsthExp, ...
    smoothPsthSim, neuronNumber, 'single', numOfCoupledNeurons, ISI,expISI,  sessionName,modelFiringRate,validationData, coupledNeurons)

validationStimulusSelected = getStimulusByModelNumber(selectedModel, validationFeatures.posgrid, validationFeatures.hdgrid, validationFeatures.speedgrid, validationFeatures.speedHDGrid);

% **********************
% Create synthetic data 
if config.fCoupling == 0 
    modelParams = param{topSingleCurve};
    tuningParams = modelParams(2:end);
    learnedParams.biasParam = modelParams(1);
    couplingData = [];
    learningStimulus = getStimulusByModelNumber(topSingleCurve, features.posgrid, features.hdgrid, features.speedgrid, features.speedHDGrid);
    trainFiringRate = simulateModelResponse(learningStimulus, tuningParams, learnedParams, config.fCoupling,  numOfCoupledNeurons, couplingData, config.dt);
    
    testFiringRate = simulateModelResponse(validationStimulusSingle, tuningParams, learnedParams, config.fCoupling,  numOfCoupledNeurons, couplingData,config.dt);
    spiketrain = [testFiringRate; trainFiringRate];

    save(['simulated_data_cell_' num2str(neuronNumber)], 'posx', 'posy', 'boxSize','sampleRate','headDirection', 'spiketrain');
elseif config.fCoupling == 1 && numOfCoupledNeurons == 0
     modelParams = param{topSingleCurve};
    learnedParams.biasParam = modelParams(1);
    % Set spike history filter
    learnedParams.spikeHistory = learningData.historyBaseVectors * modelParams(2:1 + config.numOfHistoryParams)';
    tuningParams = modelParams(2 + config.numOfHistoryParams:end);

    couplingData = [];
    learningStimulus = getStimulusByModelNumber(topSingleCurve, features.posgrid, features.hdgrid, features.speedgrid, features.speedHDGrid);
    trainFiringRate = simulateModelResponse(learningStimulus, tuningParams, learnedParams, config.fCoupling,  numOfCoupledNeurons, couplingData, config.dt);
    
    testFiringRate = simulateModelResponse(validationStimulusSingle, tuningParams, learnedParams, config.fCoupling,  numOfCoupledNeurons, couplingData,config.dt);
    spiketrain = [testFiringRate; trainFiringRate];

    save(['history_simulated_data_cell_' num2str(neuronNumber)], 'posx', 'posy', 'boxSize','sampleRate','headDirection', 'spiketrain');
end
 % Get Single model perfomace and parameters
[metrics, learnedParams, smoothPsthExp, smoothPsthSim, ISI, modelFiringRate] = ...
    getModelMetricsAndParameters(config, validationData.spiketrain, validationStimulusSelected, param{selectedModel},...
    modelType{selectedModel}, config.filter, numOfCoupledNeurons, validationCouplingData,...
    learningData.historyBaseVectors, learningData.couplingBaseVectors);

% plot results
plotPerformanceAndParameters(config, learnedParams, metrics, smoothPsthExp, ...
    smoothPsthSim, neuronNumber, 'best', numOfCoupledNeurons, ISI,expISI,  sessionName, modelFiringRate, validationData, coupledNeurons)
end