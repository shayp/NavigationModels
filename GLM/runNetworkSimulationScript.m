clear all;
networkName = '11025-19050503';
addpath('featureMaps');
addpath('General');

sessionName = networkName;
neuron1 = 1;
neuron2 = 3;
config.thetaMask = [0 0 0 1];

rawDatafolderPath = strcat('C:\projects\NavigationModels\GLM\rawDataForLearning\', sessionName);
filePath = [rawDatafolderPath '\data_for_cell_'];
learnedParamsFolderPath = strcat('C:\projects\NavigationModels\GLM\Graphs\', sessionName);
Neuron1leanredParamsFilePath = [learnedParamsFolderPath '\Neuron_' num2str(neuron1) '_Coupled_Results_best'];
Neuron2leanredParamsFilePath = [learnedParamsFolderPath '\Neuron_' num2str(neuron2) '_Coupled_Results_best'];

config.numOfPositionAxisParams = 25;
config.numOfPositionParams = config.numOfPositionAxisParams * config.numOfPositionAxisParams;
config.numOfHeadDirectionParams = 30;
config.numOfSpeedBins = 10;
config.numOfTheta = 20;
config.sampleRate = 1000;
config.maxSpeed = 50;
config.boxSize = [100 100];
config.dt = 1/1000;
isiToCount = 125;
config.isiToCount = isiToCount;
% load general data
load([filePath num2str(neuron1)]);
data.posx = posx;
data.posy = posy;
data.headDirection = headDirection;
data.spiketrain = zeros(length(posx),1);
data.thetaPhase = phase;
[features] = buildFeatureMaps(config, data, 0);

%% Get first neuronParams
load(Neuron1leanredParamsFilePath);
load([filePath num2str(neuron1)]);
neuronParams(1).fTheta = sum(modelParams.modelType & config.thetaMask);
selectedModel = modelParams.modelNumber;
neuronParams(1).stimulus = getStimulusByModelNumber(selectedModel, features.posgrid, features.hdgrid, features.speedgrid, features.thetaGrid);
neuronParams(1).bias = modelParams.biasParam;
neuronParams(1).history = modelParams.spikeHistory;
neuronParams(1).couplingFilter = modelParams.couplingFilters;
neuronParams(1).tuningParams = modelParams.tuningParams;
if neuronParams(1).fTheta
    neuronParams(1).thetaParam = modelParams.thetaParam;
end
neuronParams(1).spiketrain = spiketrain;
% Get second neuron params
load(Neuron2leanredParamsFilePath);
load([filePath num2str(neuron2)]);
selectedModel = modelParams.modelNumber;
neuronParams(2).fTheta = sum(modelParams.modelType & config.thetaMask);

neuronParams(2).stimulus = getStimulusByModelNumber(selectedModel, features.posgrid, features.hdgrid, features.speedgrid, features.thetaGrid);
neuronParams(2).bias = modelParams.biasParam;
neuronParams(2).history = modelParams.spikeHistory;
neuronParams(2).couplingFilter = modelParams.couplingFilters;
neuronParams(2).tuningParams = modelParams.tuningParams;
if neuronParams(2).fTheta
    neuronParams(2).thetaParam = modelParams.thetaParam;
end
neuronParams(2).spiketrain = spiketrain;
[response] = simulateCoupledNetworkResponse(neuronParams,  config.dt, length(data.posx), features.thetaGrid, isiToCount);
spiketrain = response(:,1);
sum(spiketrain)
save([rawDatafolderPath '\fully_simulated_' num2str(neuron1)], 'spiketrain');


spiketrain = response(:,2);
save([rawDatafolderPath '\fully_simulated_' num2str(neuron2)], 'spiketrain');
sum(spiketrain)