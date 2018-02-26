function [config, learningData, couplingData, validationData, validationCouplingData, isi, posx, posy, boxSize,sampleRate,headDirection, phase] = loadDataForLearning(folderPath,  configFilePath, neuronNumber, fCoupling, coupledNeurons)
load(configFilePath);

% Define num of learned parameters for learning
config.numOfHeadDirectionParams = 30;
config.numOfSpeedBins = 8;
config.numOfTheta = 20;

config.numOfPositionAxisParams = 25;
config.numOfPositionParams = config.numOfPositionAxisParams * config.numOfPositionAxisParams;
config.numofTuningParams = config.numOfHeadDirectionParams + config.numOfTheta + config.numOfPositionParams + config.numOfSpeedBins;
% define limits of bins
config.thetaMask = [0 0 0 1];
config.boxSize = boxSize;
config.isiToCount = 125;
config.windowSize = 20;
config.fCoupling = fCoupling;
% define temporal difference
config.sampleRate = 1000;
config.dt = 1/1000;
config.psthdt = 1/1000 * config.windowSize;
config.numFolds = 2;
config.numModels = 15;
config.maxSpeed = 50;
config.timeBeforeSpike = 0;
config.acausalInteraction = 0;
% History and coupling config
config.numOfHistoryParams = 16;
%config.numOfCouplingParams = 20;
config.numOfCouplingParams = 5;
config.speedVec = [0 1 4 8 14 26 38 50];

config.lastPeakHistory = 0.15;
config.bForHistory = 0.02;
%config.lastPeakCoupling = 0.025;

config.lastPeakCoupling = 0.032;
config.bForCoupling = 1;
config.numOfRepeats = 400;

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
learningData.thetaPhase = phase(maxBins + 1:end);
learningData.headDirection = headDirection(maxBins + 1:end);
learningData.spiketrain = spiketrain(maxBins + 1:end);

validationData.neuronNumber = neuronNumber;
validationData.posx = posx(1:maxBins);
validationData.posy = posy(1:maxBins);

validationData.thetaPhase = phase(1:maxBins);
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

[~, ~, learningData.historyBaseVectors] = buildBaseVectorsForPostSpikeAndCoupling(config.numOfHistoryParams, config.dt, historyPeaks, config.bForHistory, learningData.refreactoryPeriod);
%[~, ~, learningData.couplingBaseVectors] = buildBaseVectorsForPostSpikeAndCoupling(config.numOfCouplingParams, config.dt, couplingPeaks, config.bForCoupling, config.dt);
[~, ~, learningData.couplingBaseVectors] = buildBaseVectorsForPostSpikeAndCoupling(config.numOfCouplingParams, config.dt, [config.dt config.lastPeakCoupling] , config.bForCoupling, 0);

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