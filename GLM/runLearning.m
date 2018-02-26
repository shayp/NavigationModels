function [allStimulus,tuningParams, couplingFilters, historyFilter, bias, dt] = runLearning(sessionName, data_path, neuronNumber, configFilePath, fCoupling, coupledNeurons)
allStimulus = [];
tuningParams = [];
couplingFilters = [];
historyFilter = [];
bias = nan;

addpath('General');
addpath('featureMaps');
addpath('Fit');
addpath('simulation');

addpath('BuildPlots');
if fCoupling == 0
    numOfCoupledNeurons = 0;
else
    fCoupling = 1;
    numOfCoupledNeurons = length(coupledNeurons);
end

couplingData = [];


% Get learning data
[config, learningData, couplingData, validationData, validationCouplingData, expISI, posx, posy, boxSize,sampleRate,headDirection, phase] = loadDataForLearning(data_path, configFilePath, neuronNumber, fCoupling, coupledNeurons);

hd_tuning = compute_1d_tuning_curve(learningData.headDirection, learningData.spiketrain, config.numOfHeadDirectionParams, 0, 2*pi);


% Build feature maps from the loaded data
features = buildFeatureMaps(config, learningData, 1);

validationFeatures = buildFeatureMaps(config, validationData, 0);

dumpInputToFile(sessionName, neuronNumber, features, validationFeatures, learningData, validationData,boxSize, sampleRate);

% Add spike history or coupling if needed
designMatrix = [];
if fCoupling
    designMatrix = getSpikeHistoryDataForLearning(config, learningData, numOfCoupledNeurons, couplingData);
end

features.designMatrix = designMatrix;

smooth_fr = conv(learningData.spiketrain, config.filter, 'same');
mean_fr = sum(learningData.spiketrain) / length(learningData.spiketrain) / config.dt;
% Get experiment tuning curves
[pos_curve, hd_curve, speed_curve, theta_curve] = ...
    computeTuningCurves(learningData, features, config, smooth_fr);

% Plot experiment tuning curve
plotExperimentTuningCurves(config, features, pos_curve, hd_curve, speed_curve, theta_curve, neuronNumber, learningData, sessionName, mean_fr);


% Fit model
[numModels, testFit, trainFit, param, Models,modelTypes, kFoldParams, selected_models] = ...
    fitAllModels(learningData, config, features, fCoupling);

% % Select best models
% [topSingleCurve, selected Model] = ...
%     selectBestModel(testFit,config.numFolds, numModels);
% testFit_mat = cell2mat(testFit);
numOfRepeats = 10;
simFeatures = buildFeatureMaps(config, learningData, 0);

[topSingleCurve, selectedModel, scores] = selectBestModelBySimulation(selected_models, modelTypes, param, numOfRepeats, config,learningData.historyBaseVectors, simFeatures, learningData.spiketrain,kFoldParams, numOfCoupledNeurons, learningData.couplingBaseVectors, couplingData);

PlotLogLikelihood(scores, config.numFolds, selectedModel, sessionName, neuronNumber, fCoupling, numOfCoupledNeurons)

validationStimulusSingle = getStimulusByModelNumber(topSingleCurve, validationFeatures.posgrid, validationFeatures.hdgrid, validationFeatures.speedgrid, validationFeatures.thetaGrid);
% Get Single model perfomace and parameters
[metrics, learnedParams, smoothPsthExp, smoothPsthSim, ISI, modelFiringRate, log_ll] = ...
    getModelMetricsAndParameters(config, validationData.spiketrain, validationStimulusSingle, param{topSingleCurve},...
    modelTypes{topSingleCurve}, config.filter, numOfCoupledNeurons, validationCouplingData,...
    learningData.historyBaseVectors, learningData.couplingBaseVectors, validationFeatures.thetaGrid, kFoldParams{topSingleCurve});
learnedParams.modelNumber = topSingleCurve;
% plot results
plotPerformanceAndParameters(config, learnedParams, metrics, smoothPsthExp, ...
    smoothPsthSim, neuronNumber, 'single', numOfCoupledNeurons, ISI,ISI.expISIPr,  sessionName,modelFiringRate,validationData, coupledNeurons, log_ll)

validationStimulusSelected = getStimulusByModelNumber(selectedModel, validationFeatures.posgrid, validationFeatures.hdgrid, validationFeatures.speedgrid, validationFeatures.thetaGrid);
config.fTheta = sum(modelTypes{selectedModel} & config.thetaMask);

% **********************
% Create synthetic data 
modelParam = param{selectedModel};
modelType = modelTypes{selectedModel};
kFoldParam = kFoldParams{selectedModel};
[learnedParams, fTheta] = getLearnedParameters(modelParam, modelType, config, kFoldParam, learningData.historyBaseVectors, numOfCoupledNeurons, learningData.couplingBaseVectors);
learningStimulus = getStimulusByModelNumber(selectedModel, simFeatures.posgrid, simFeatures.hdgrid, simFeatures.speedgrid, simFeatures.thetaGrid);

if config.fCoupling == 0 || (config.fCoupling == 1 && numOfCoupledNeurons == 0)
    couplingData = [];
end

[trainFiringRate, ~] = simulateResponsePillow(learningStimulus, learnedParams.tuningParams, learnedParams, config.fCoupling,  numOfCoupledNeurons, couplingData, config.dt, config, fTheta, simFeatures.thetaGrid,0,[]);
[testFiringRate, ~] = simulateResponsePillow(validationStimulusSelected, learnedParams.tuningParams, learnedParams, config.fCoupling,  numOfCoupledNeurons, validationCouplingData,config.dt, config, fTheta, validationFeatures.thetaGrid,0,[]);
dt = config.dt;

if (config.fCoupling == 1 && numOfCoupledNeurons > 0)
    allStimulus = [learningStimulus; validationStimulusSelected];
    tuningParams = learnedParams.tuningParams;
    couplingFilters = learnedParams.couplingFilters;
    historyFilter = learnedParams.spikeHistory;
    bias = learnedParams.biasParam;
end

spiketrain = [testFiringRate; trainFiringRate];

if config.fCoupling == 0
    save(['rawDataForLearning/' sessionName '/simulated_data_cell_' num2str(neuronNumber)], 'posx', 'posy', 'boxSize','sampleRate','headDirection', 'spiketrain');
elseif config.fCoupling == 1 && numOfCoupledNeurons == 0
    save(['rawDataForLearning/' sessionName '/history_simulated_data_cell_' num2str(neuronNumber)], 'posx', 'posy', 'boxSize','sampleRate','headDirection', 'spiketrain');
else
    save(['rawDataForLearning/' sessionName '/coupled_simulated_data_cell_' num2str(neuronNumber)], 'posx', 'posy', 'boxSize','sampleRate','headDirection', 'spiketrain');
end

 % Get Single model perfomace and parameters
[metrics, learnedParams, smoothPsthExp, smoothPsthSim, ISI, modelFiringRate, log_ll] = ...
    getModelMetricsAndParameters(config, validationData.spiketrain, validationStimulusSelected, param{selectedModel},...
    modelTypes{selectedModel}, config.filter, numOfCoupledNeurons, validationCouplingData,...
    learningData.historyBaseVectors, learningData.couplingBaseVectors, validationFeatures.thetaGrid, kFoldParams{selectedModel});
learnedParams.modelNumber = selectedModel;

% plot results
plotPerformanceAndParameters(config, learnedParams, metrics, smoothPsthExp, ...
    smoothPsthSim, neuronNumber, 'best', numOfCoupledNeurons, ISI,ISI.expISIPr,  sessionName, modelFiringRate, validationData, coupledNeurons, log_ll)
end