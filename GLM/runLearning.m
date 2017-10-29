function [config, learningData, features, numModels, testFit, trainFit, param] = runLearning(data_path, neuronNumber, configFilePath, fCoupling, coupledNeurons)

if fCoupling == 0
    numOfCoupledNeurons = 0;
else
    fCoupling = 1;
    numOfCoupledNeurons = length(coupledNeurons);
end

couplingData = [];
% Get learning data
[config, learningData, couplingData, validationData, validationCouplingData] = loadDataForLearning(data_path, configFilePath, neuronNumber, fCoupling, coupledNeurons);

% Build feature maps from the loaded data
features = buildFeatureMaps(config, learningData);

validationFeatures = buildFeatureMaps(config, validationData);

% Add spike history or coupling if needed
designMatrix = [];
if fCoupling
    designMatrix = getSpikeHistoryDataForLearning(config, learningData, numOfCoupledNeurons, couplingData);
end

features.designMatrix = designMatrix;

% Fit model
[numModels, testFit, trainFit, param, smooth_fr,  Models,modelType, filter] = ...
    fitAllModels(learningData, config, features, fCoupling);

% Select best models
[topSingleCurve, selectedModel] = ...
    selectBestModel(testFit,config.numFolds, numModels);

% Get experiment tuning curves
[pos_curve, hd_curve, vel_curve, border_curve] = ...
    computeTuningCurves(learningData, features, config, smooth_fr);

% Plot experiment tuning curve
plotExperimentTuningCurves(config, features, pos_curve, hd_curve, vel_curve, border_curve, neuronNumber);

% validationStimulusSingle = getStimulusByModelNumber(topSingleCurve, validationFeatures.posgrid, validationFeatures.hdgrid, validationFeatures.velgrid, validationFeatures.bordergrid);
% % Get Single model perfomace and parameters
% [metrics, learnedParams, smoothPsthExp, smoothPsthSim, ISI] = ...
%     getModelMetricsAndParameters(config, validationData.spiketrain, validationStimulusSingle, param{topSingleCurve},...
%     modelType{topSingleCurve}, filter, numOfCoupledNeurons, validationCouplingData, learningData.historyBaseVectors, learningData.couplingBaseVectors);
% 
% % plot results
% plotPerformanceAndParameters(config, learnedParams, metrics, smoothPsthExp, ...
%     smoothPsthSim, neuronNumber, 'single', numOfCoupledNeurons, ISI)

validationStimulusSelected = getStimulusByModelNumber(selectedModel, validationFeatures.posgrid, validationFeatures.hdgrid, validationFeatures.velgrid, validationFeatures.bordergrid);


% Get Single model perfomace and parameters
[metrics, learnedParams, smoothPsthExp, smoothPsthSim, ISI] = ...
    getModelMetricsAndParameters(config, validationData.spiketrain, validationStimulusSelected, param{selectedModel},...
    modelType{selectedModel}, filter, numOfCoupledNeurons, validationCouplingData, learningData.historyBaseVectors, learningData.couplingBaseVectors);

% plot results
plotPerformanceAndParameters(config, learnedParams, metrics, smoothPsthExp, ...
    smoothPsthSim, neuronNumber, 'best', numOfCoupledNeurons, ISI)
end