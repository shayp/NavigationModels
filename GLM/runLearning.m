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
[config, learningData, couplingData, validationData, validationCouplingData, expISI, posx, posy, boxSize,sampleRate,headDirection, phase] = loadDataForLearning(data_path, configFilePath, neuronNumber, fCoupling, coupledNeurons);

hd_tuning = compute_1d_tuning_curve(learningData.headDirection, learningData.spiketrain, config.numOfHeadDirectionParams, 0, 2*pi);


% Build feature maps from the loaded data
features = buildFeatureMaps(config, learningData, 1);

validationFeatures = buildFeatureMaps(config, validationData, 0);

% Add spike history or coupling if needed
designMatrix = [];
if fCoupling
    designMatrix = getSpikeHistoryDataForLearning(config, learningData, numOfCoupledNeurons, couplingData);
end

features.designMatrix = designMatrix;

smooth_fr = conv(learningData.spiketrain, config.filter, 'same');

% Get experiment tuning curves
[pos_curve, hd_curve, speed_curve, theta_curve] = ...
    computeTuningCurves(learningData, features, config, smooth_fr);

% Plot experiment tuning curve
plotExperimentTuningCurves(config, features, pos_curve, hd_curve, speed_curve, theta_curve, neuronNumber, learningData, sessionName);


% Fit model
[numModels, testFit, trainFit, param, Models,modelType, kFoldParams] = ...
    fitAllModels(learningData, config, features, fCoupling);

% Select best models
[topSingleCurve, selectedModel] = ...
    selectBestModel(testFit,config.numFolds, numModels);
testFit_mat = cell2mat(testFit);

LL_values = reshape(testFit_mat(:,3),config.numFolds,numModels);
PlotLogLikelihood(LL_values, config.numFolds, selectedModel, sessionName, neuronNumber, fCoupling, numOfCoupledNeurons)

validationStimulusSingle = getStimulusByModelNumber(topSingleCurve, validationFeatures.posgrid, validationFeatures.hdgrid, validationFeatures.speedgrid, validationFeatures.thetaGrid);
% Get Single model perfomace and parameters
[metrics, learnedParams, smoothPsthExp, smoothPsthSim, ISI, modelFiringRate, log_ll] = ...
    getModelMetricsAndParameters(config, validationData.spiketrain, validationStimulusSingle, param{topSingleCurve},...
    modelType{topSingleCurve}, config.filter, numOfCoupledNeurons, validationCouplingData,...
    learningData.historyBaseVectors, learningData.couplingBaseVectors, validationFeatures.thetaGrid, kFoldParams{topSingleCurve});
learnedParams.modelNumber = topSingleCurve;
% plot results
plotPerformanceAndParameters(config, learnedParams, metrics, smoothPsthExp, ...
    smoothPsthSim, neuronNumber, 'single', numOfCoupledNeurons, ISI,ISI.expISIPr,  sessionName,modelFiringRate,validationData, coupledNeurons, log_ll)

validationStimulusSelected = getStimulusByModelNumber(selectedModel, validationFeatures.posgrid, validationFeatures.hdgrid, validationFeatures.speedgrid, validationFeatures.thetaGrid);
config.fTheta = sum(modelType{selectedModel} & config.thetaMask);
simFeatures = buildFeatureMaps(config, learningData, 0);

% **********************
% Create synthetic data 
if config.fCoupling == 0 
    modelParams = param{selectedModel};
    if config.fTheta
        tuningParams = modelParams(2:end - config.numOfTheta);
        learnedParams.thetaParam = modelParams(end - config.numOfTheta + 1:end);
    else
    	tuningParams = modelParams(2:end);
    end
    learnedParams.biasParam = modelParams(1);
    couplingData = [];
    learningStimulus = getStimulusByModelNumber(selectedModel, simFeatures.posgrid, simFeatures.hdgrid, simFeatures.speedgrid, simFeatures.thetaGrid);
    [trainFiringRate, ~] = simulateResponsePillow(learningStimulus, tuningParams, learnedParams, config.fCoupling,  numOfCoupledNeurons, couplingData, config.dt, config, config.fTheta, simFeatures.thetaGrid,0,[]);
    
    [testFiringRate, ~] = simulateResponsePillow(validationStimulusSelected, tuningParams, learnedParams, config.fCoupling,  numOfCoupledNeurons, couplingData,config.dt, config, config.fTheta, validationFeatures.thetaGrid,0,[]);
    spiketrain = [testFiringRate; trainFiringRate];

    save(['rawDataForLearning/' sessionName '/simulated_data_cell_' num2str(neuronNumber)], 'posx', 'posy', 'boxSize','sampleRate','headDirection', 'spiketrain');
elseif config.fCoupling == 1 && numOfCoupledNeurons == 0
     modelParams = param{selectedModel};
    learnedParams.biasParam = modelParams(1);
    % Set spike history filter
    learnedParams.spikeHistory = learningData.historyBaseVectors * modelParams(2:1 + config.numOfHistoryParams)';
    if config.fTheta
        tuningParams = modelParams(2 + config.numOfHistoryParams:end - config.numOfTheta);
        learnedParams.thetaParam = modelParams(end - config.numOfTheta + 1:end);
    else
    	tuningParams = modelParams(2 + config.numOfHistoryParams:end);
    end

    couplingData = [];
    learningStimulus = getStimulusByModelNumber(selectedModel, simFeatures.posgrid, simFeatures.hdgrid, simFeatures.speedgrid, simFeatures.thetaGrid);
    [trainFiringRate, ~] = simulateResponsePillow(learningStimulus, tuningParams, learnedParams, config.fCoupling,  numOfCoupledNeurons, couplingData, config.dt, config, config.fTheta, simFeatures.thetaGrid, 0, []);
    
    [testFiringRate, ~] = simulateResponsePillow(validationStimulusSelected, tuningParams, learnedParams, config.fCoupling,  numOfCoupledNeurons, couplingData,config.dt, config, config.fTheta, validationFeatures.thetaGrid, 0, []);
    spiketrain = [testFiringRate; trainFiringRate];

    save(['rawDataForLearning/' sessionName '/history_simulated_data_cell_' num2str(neuronNumber)], 'posx', 'posy', 'boxSize','sampleRate','headDirection', 'spiketrain');
else
    kFoldFilters = kFoldParams{selectedModel};
     modelParams = param{selectedModel};
    learnedParams.biasParam = modelParams(1);
    % Set spike history filter
    learnedParams.spikeHistory = learningData.historyBaseVectors * modelParams(2:1 + config.numOfHistoryParams)';
    couplingParamsLength = config.numOfCouplingParams * numOfCoupledNeurons;
    kFoldcouplingParams = reshape(kFoldFilters(:,2 + config.numOfHistoryParams:couplingParamsLength + config.numOfHistoryParams + 1), config.numFolds, config.numOfCouplingParams, numOfCoupledNeurons);
    figure();
    time = linspace(config.dt, config.dt * size(learningData.couplingBaseVectors,1), size(learningData.couplingBaseVectors, 1));
    for i = 1:numOfCoupledNeurons
    subplot(numOfCoupledNeurons, 1, i);
    constVal = ones(size(learningData.couplingBaseVectors,1),1);
    plot(time, exp(learningData.couplingBaseVectors * kFoldcouplingParams(:,:,i)'));
    hold on
    plot(time, constVal,'--r','linewidth', 2);
    hold off;
    hold on
    plot(time, exp(mean(learningData.couplingBaseVectors * kFoldcouplingParams(:,:,i)',2)),'linewidth', 2);
    hold off;
    title('coupling filters - k folds');
    ylabel('Intensity');
    xlabel('Times (sec)');
    end

    drawnow;
    savefig(['Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_Coupled_ConfidenceInterval']);
  % Set tuning params
   if config.fTheta
        tuningParams = modelParams(2 + config.numOfHistoryParams + couplingParamsLength:end - config.numOfTheta);
        learnedParams.thetaParam = modelParams(end - config.numOfTheta + 1:end);
    else
    	tuningParams = modelParams(2 + config.numOfHistoryParams + couplingParamsLength:end);
    end

 learningStimulus = getStimulusByModelNumber(selectedModel, simFeatures.posgrid, simFeatures.hdgrid, simFeatures.speedgrid, simFeatures.thetaGrid);
 [trainFiringRate, ~] = simulateResponsePillow(learningStimulus, tuningParams, learnedParams, config.fCoupling,  numOfCoupledNeurons, couplingData, config.dt,  config, config.fTheta, simFeatures.thetaGrid,1,learningData.spiketrain);
    
 [testFiringRate, ~] = simulateResponsePillow(validationStimulusSelected, tuningParams, learnedParams, config.fCoupling,  numOfCoupledNeurons, validationCouplingData,config.dt,  config, config.fTheta, validationFeatures.thetaGrid,0,[]);
 spiketrain = [testFiringRate; trainFiringRate];

    save(['rawDataForLearning/' sessionName '/coupled_simulated_data_cell_' num2str(neuronNumber)], 'posx', 'posy', 'boxSize','sampleRate','headDirection', 'spiketrain');
end
 % Get Single model perfomace and parameters
[metrics, learnedParams, smoothPsthExp, smoothPsthSim, ISI, modelFiringRate, log_ll] = ...
    getModelMetricsAndParameters(config, validationData.spiketrain, validationStimulusSelected, param{selectedModel},...
    modelType{selectedModel}, config.filter, numOfCoupledNeurons, validationCouplingData,...
    learningData.historyBaseVectors, learningData.couplingBaseVectors, validationFeatures.thetaGrid, kFoldParams{selectedModel});
learnedParams.modelNumber = selectedModel;

% plot results
plotPerformanceAndParameters(config, learnedParams, metrics, smoothPsthExp, ...
    smoothPsthSim, neuronNumber, 'best', numOfCoupledNeurons, ISI,ISI.expISIPr,  sessionName, modelFiringRate, validationData, coupledNeurons, log_ll)
end