function [config, learningData, couplingData, validationData, validationCouplingData, isi, posx, posy, boxSize,sampleRate,headDirection] = loadDataForLearning(folderPath,  configFilePath, neuronNumber, fCoupling, coupledNeurons)
load(configFilePath);

% Define num of learned parameters for learning
config.numOfHeadDirectionParams = 30;
config.numOfHDSpeedBins = 10;
config.numOfSpeedBins = 10;

config.numOfPositionAxisParams = numOfPositionAxisParams;
config.numOfPositionParams = config.numOfPositionAxisParams * config.numOfPositionAxisParams;
config.numofTuningParams = config.numOfHeadDirectionParams + config.numOfHDSpeedBins + config.numOfPositionParams + config.numOfSpeedBins;
% define limits of bins

config.boxSize = boxSize;

config.windowSize = 5;
config.fCoupling = fCoupling;
% define temporal difference
config.sampleRate = 1000;
config.dt = 1/1000;
config.psthdt = 1/1000 * config.windowSize;
config.numFolds = 10;
config.numModels = 15;
config.maxSpeed = 50;
% History and coupling config
config.numOfHistoryParams = 15;
%config.numOfCouplingParams = 20;
config.numOfCouplingParams = 10;

config.lastPeakHistory = 0.17;
config.bForHistory = config.dt * 5;
%config.lastPeakCoupling = 0.025;

config.lastPeakCoupling = 0.03;
config.bForCoupling = 0.5;
config.numOfRepeats = 200;

% compute a filter, which will be used to smooth the firing rate
filter = gaussmf(-4:4,[2 0]);
filter = filter/sum(filter); 
config.filter = filter;

load([folderPath num2str(neuronNumber)]);

maxBins = ceil(length(posx) * 0.1);

% Get position, head direction and spike train data of the neuron we want to
% learn
learningData.neuronNumber = neuronNumber;
learningData.posx = posx(maxBins + 1:end);
learningData.posy = posy(maxBins + 1:end);
learningData.headDirection = headDirection(maxBins + 1:end);
learningData.spiketrain = spiketrain(maxBins + 1:end);

validationData.neuronNumber = neuronNumber;
validationData.posx = posx(1:maxBins);
validationData.posy = posy(1:maxBins);
validationData.headDirection = headDirection(1:maxBins);
validationData.spiketrain = spiketrain(1:maxBins);
spikeDistance = diff(find(spiketrain));
maxISI = max(spikeDistance);
isi = zeros(maxISI, 1);
for i = 1:maxISI
    isi(i) = sum(i == spikeDistance);
end

isi = isi / length(spikeDistance);
[learningData.refreactoryPeriod , learningData.ISIPeak] =  getRefractoryPeriodForNeurons(spiketrain, config.dt);

firstPeak = max(learningData.refreactoryPeriod + config.dt, learningData.refreactoryPeriod);

historyPeaks = [firstPeak config.lastPeakHistory];
couplingPeaks = [0.005 config.lastPeakCoupling];

[~, ~, learningData.historyBaseVectors] = buildBaseVectorsForPostSpikeAndCoupling(config.numOfHistoryParams, config.dt, historyPeaks, config.bForHistory, learningData.refreactoryPeriod);

[~, ~, learningData.couplingBaseVectors] = buildBaseVectorsForPostSpikeAndCoupling(config.numOfCouplingParams, config.dt, couplingPeaks, config.bForCoupling, config.dt);
% learningData.couplingBaseVectors = buildBaseVectors(config.numOfCouplingParams);

couplingData = [];
validationCouplingData = [];
if fCoupling == 1
    config.fCoupling = 1;
    % Get the position head direction and spike train of the coupled neurons
    % that we want to combine in the model
    for i = 1:length(coupledNeurons)
        load([folderPath num2str(coupledNeurons(i))]);
        couplingData.data(i).posx  = posx(maxBins + 1:end);
        couplingData.data(i).posy  = posy(maxBins + 1:end);
        couplingData.data(i).headDirection  = headDirection(maxBins + 1:end);
        couplingData.data(i).spiketrain  = spiketrain(maxBins + 1:end);
        

        validationCouplingData.data(i).spiketrain  = spiketrain(1:maxBins);
    end
end

end