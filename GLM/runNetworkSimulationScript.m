clear all;
networkName = '11025-19050503';
addpath('featureMaps');
addpath('General');

sessionName = networkName;
neuron1 = 1;
neuron2 = 3;

rawDatafolderPath = strcat('C:\projects\NavigationModels\GLM\rawDataForLearning\', sessionName);
filePath = [rawDatafolderPath '\data_for_cell_'];
learnedParamsFolderPath = strcat('C:\projects\NavigationModels\GLM\Graphs\', sessionName);
Neuron1leanredParamsFilePath = [learnedParamsFolderPath '\Neuron_' num2str(neuron1) '_Coupled_Results_single'];
Neuron2leanredParamsFilePath = [learnedParamsFolderPath '\Neuron_' num2str(neuron2) '_Coupled_Results_single'];

config.numOfPositionAxisParams = 25;
config.numOfPositionParams = config.numOfPositionAxisParams * config.numOfPositionAxisParams;
config.numOfHeadDirectionParams = 30;
config.numOfSpeedBins = 10;
config.numOfTheta = 10;
config.sampleRate = 1000;
config.maxSpeed = 50;
config.boxSize = [100 100];
config.dt = 1/1000;

% load general data
load([filePath num2str(neuron1)]);
data.posx = posx;
data.posy = posy;
data.headDirection = headDirection;
data.thetaPhase = phase;
[features] = buildFeatureMaps(config, data);

%% Get first neuronParams
load(Neuron1leanredParamsFilePath);
load([filePath num2str(neuron1)]);

selectedModel = modelParams.modelNumber;
neuronParams(1).stimulus = getStimulusByModelNumber(selectedModel, features.posgrid, features.hdgrid, features.speedgrid, features.thetaGrid);
neuronParams(1).bias = modelParams.biasParam;
neuronParams(1).history = modelParams.spikeHistory;
neuronParams(1).couplingFilter = modelParams.couplingFilters;
neuronParams(1).tuningParams = modelParams.tuningParams;
neuronParams(1).thetaFactor = modelParams.thetaFactor;
neuronParams(1).startThetaBin = modelParams.startThetaBin;
neuronParams(1).endThetaBin = modelParams.endThetaBin;
neuronParams(1).spiketrain = spiketrain;
% Get second neuron params
load(Neuron2leanredParamsFilePath);
load([filePath num2str(neuron2)]);
selectedModel = modelParams.modelNumber;
neuronParams(2).stimulus = getStimulusByModelNumber(selectedModel, features.posgrid, features.hdgrid, features.speedgrid, features.thetaGrid);
neuronParams(2).bias = modelParams.biasParam;
neuronParams(2).history = modelParams.spikeHistory;
neuronParams(2).couplingFilter = modelParams.couplingFilters;
neuronParams(2).tuningParams = modelParams.tuningParams;
neuronParams(2).thetaFactor = modelParams.thetaFactor;
neuronParams(2).startThetaBin = modelParams.startThetaBin;
neuronParams(2).endThetaBin = modelParams.endThetaBin;
neuronParams(2).spiketrain = spiketrain;
[response] = simulateCoupledNetworkResponse(neuronParams,  config.dt, length(data.posx), data.thetaPhase);
spiketrain = response(:,1);
sum(spiketrain)
save([rawDatafolderPath '\fully_simulated_' num2str(neuron1)], 'spiketrain');


spiketrain = response(:,2);
save([rawDatafolderPath '\fully_simulated_' num2str(neuron2)], 'spiketrain');
sum(spiketrain)