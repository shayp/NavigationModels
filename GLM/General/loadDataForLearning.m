function [config, learningData, couplingData, validationData, validationCouplingData] = loadDataForLearning(folderPath,  configFilePath, neuronNumber, fCoupling, coupledNeurons)
load(configFilePath);

% Define num of learned parameters for learning
config.numOfHeadDirectionParams = numOfHeadDirectionParams;
config.numOfDistanceFromBorderParams = numOfDistanceFromBorderParams;
config.numOfPositionAxisParams = numOfPositionAxisParams;
config.numOfPositionParams = config.numOfPositionAxisParams * config.numOfPositionAxisParams;
config.numOfVelocityAxisParams = numOfVelocityAxisParams;
config.numOfVelocityParams = numOfVelocityAxisParams * numOfVelocityAxisParams;
config.numofTuningParams = config.numOfHeadDirectionParams + config.numOfDistanceFromBorderParams + config.numOfPositionParams + config.numOfVelocityParams;
% define limits of bins
config.maxVelocityXAxis = maxVelocityXAxis;
config.maxVelocityYAxis = maxVelocityYAxis;
config.boxSize = boxSize;
config.maxDistanceFromBorder = maxDistanceFromBorder;

config.windowSize = 20;
config.fCoupling = fCoupling;
% define temporal difference
config.sampleRate = 1000;
config.dt = 1/1000;
config.psthdt = 1/1000 * config.windowSize;

config.numFolds = 2;
config.numModels = 15;

% History and coupling config
config.numOfHistoryParams = 20;
config.numOfCouplingParams = 4;
config.lastPeakHistory = 0.075;
config.bForHistory = config.dt * 5;
config.lastPeakCoupling = 0.025;
config.bForCoupling = config.dt * 5;
config.numOfRepeats = 40;

% compute a filter, which will be used to smooth the firing rate
filter = gaussmf(-4:4,[2 0]);
filter = filter/sum(filter); 
config.filter = filter;

load([folderPath num2str(neuronNumber)]);

maxBins = ceil(length(posx) * 0.2);

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

[learningData.refreactoryPeriod , learningData.ISIPeak] =  getRefractoryPeriodForNeurons(spiketrain, config.dt);

firstPeak = max(learningData.refreactoryPeriod + config.dt, learningData.refreactoryPeriod);

historyPeaks = [firstPeak config.lastPeakHistory];
couplingPeaks = [config.dt config.lastPeakCoupling];

[~, ~, learningData.historyBaseVectors] = buildBaseVectorsForPostSpikeAndCoupling(config.numOfHistoryParams, config.dt, historyPeaks, config.bForHistory, learningData.refreactoryPeriod);

[~, ~, learningData.couplingBaseVectors] = buildBaseVectorsForPostSpikeAndCoupling(config.numOfCouplingParams, config.dt, couplingPeaks, config.bForCoupling, 0);


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