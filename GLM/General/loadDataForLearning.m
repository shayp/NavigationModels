function [config, learningData, couplingData, validationData, validationCouplingData,...
    isi, posx, posy, boxSize,sampleRate,headDirection, phase] = loadDataForLearning(folderPath,  configFilePath, neuronNumber, fCoupling, coupledNeurons)

% First load the config file
load(configFilePath);

% Deefine phase to be non for cases we don't have theta phase data
phase = [];

% *********** Global config **************

% Box size is loaded from config
config.boxSize = boxSize;

% The window size to use for psth
config.windowSize = 40;

config.fCoupling = fCoupling;

% The rate that we use for the analysis
config.sampleRate = 1000;
config.dt = 1/1000;

% The rate for the psth 
config.psthdt = 1/1000 * config.windowSize;

% Number of folds to use
config.numFolds = 2;

% Num of models we compare
config.numModels = 15;

% Num of repeats for simulation
config.numOfRepeats = 400;


% *********** Learned parametrs config **************

% Num of head direction params
config.numOfHeadDirectionParams = 30;

% num of spedd params
config.numOfSpeedBins = 8;

% Num of theta phase params
config.numOfTheta = 20;

% num of position in an axis params
config.numOfPositionAxisParams = 25;

% For a square 2D env, the number of position params is the power of one
% axis
config.numOfPositionParams = config.numOfPositionAxisParams * config.numOfPositionAxisParams;

% The number of all stimulus params
config.numofTuningParams = config.numOfHeadDirectionParams + config.numOfTheta + config.numOfPositionParams + config.numOfSpeedBins;

% Max speed to use
config.maxSpeed = 50;

% speed bins
config.speedVec = [0 1 4 8 14 26 38 50];


%  ********************* History and coupling config *********************

% Num of history coefficent params
config.numOfHistoryParams = 16;

% num of coupling params
config.numOfCouplingParams = 1;

% Set to 1 in case we use acausal interaction
config.acausalInteraction = 0;

% In case we use acausal interaction, how much time before spike to model
config.timeBeforeSpike = 0;

% Last peak time for history(in seconds)
config.lastPeakHistory = 0.15;

% How linear is the change in the cosine bumps (bigger is more linear)
config.bForHistory = 0.02;

% Last peak time for coupling(in seconds)
config.lastPeakCoupling = 0.032;

% How linear is the change in the cosine bumps (bigger is more linear)
config.bForCoupling = 1;

% compute a filter, which will be used to smooth the firing rate
filter = gaussmf(-4:4,[2 0]);
filter = filter/sum(filter); 
config.filter = filter;

% ********** Load params for learning **********
load([folderPath num2str(neuronNumber)]);

% The ratio of training from the session
trainRatio = 0.8;

% Number of bins for training
trainBins = ceil(length(posx) * trainRatio);

% Get neuron number, position, head direction and spike train data of the neuron we want to
% learn
learningData.neuronNumber = neuronNumber;
learningData.posx = posx(1:trainBins);
learningData.posy = posy(1:trainBins);
learningData.headDirection = headDirection(1:trainBins);
learningData.spiketrain = spiketrain(1:trainBins);

fPhaseExist = 1;

% Check if we have phase data, add phase data in case we have, otherwise
% use zeros 
if length(phase) < trainBins
    fPhaseExist = 0;
    'No phase in this neuron'
    learningData.thetaPhase = zeros(trainBins, 1);
else
    learningData.thetaPhase = phase(1:trainBins);
end

% Set valildation data
validationData.neuronNumber = neuronNumber;
validationData.posx = posx(trainBins + 1:end);
validationData.posy = posy(trainBins + 1:end);
validationData.headDirection = headDirection(trainBins + 1:end);
validationData.spiketrain = spiketrain(trainBins + 1:end);

% Check if we have phase data, add phase data in case we have, otherwise
% use zeros 
if fPhaseExist == 0
    validationData.thetaPhase = zeros(length(validationData.posx), 1);
else
    validationData.thetaPhase = phase(trainBins + 1:end);
end

% ********** Calculate interspike interval **********
spikeDistance = diff(find(spiketrain));
maxISI = max(spikeDistance);
isi = zeros(maxISI, 1);
for i = 1:maxISI
    isi(i) = sum(i == spikeDistance);
end

isi = isi / length(spikeDistance);


% ************ Base vectors for history and coupling ************

% Get refractory params
[learningData.refreactoryPeriod , learningData.ISIPeak] =  getRefractoryPeriodForNeurons(spiketrain, config.dt);

% Set first peak to be one time step after refactort period
firstPeak = learningData.refreactoryPeriod + config.dt;

% Set history peaks
historyPeaks = [firstPeak config.lastPeakHistory];

% Get history base vectors
[~, ~, learningData.historyBaseVectors] = buildBaseVectorsForPostSpikeAndCoupling(config.numOfHistoryParams,...
    config.dt, historyPeaks, config.bForHistory, learningData.refreactoryPeriod);

% Set coupling base vectors
couplingFilter = exp(-2:0.1:3);
couplingFilter = couplingFilter / max(couplingFilter);
couplingFilter = [0 0 fliplr(couplingFilter) 0];
learningData.couplingBaseVectors = couplingFilter';


couplingData = [];
validationCouplingData = [];

% ****** Add coupled neurons information for test and train
if config.fCoupling == 1

    % Get the position head direction and spike train of the coupled neurons
    % that we want to combine in the model
    for i = 1:length(coupledNeurons)
        
        % train params
        load([folderPath num2str(coupledNeurons(i))]);
        couplingData.data(i).posx  = posx(1:trainBins);
        couplingData.data(i).posy  = posy(1:trainBins);
        couplingData.data(i).headDirection  = headDirection(1:trainBins);
        couplingData.data(i).spiketrain  = spiketrain(1:trainBins);
 
        % test params
        validationCouplingData.data(i).spiketrain  = spiketrain(trainBins + 1:end);
    end
end

end