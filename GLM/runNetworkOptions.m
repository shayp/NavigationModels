clear all;
%profile on
sessionName = '11025-19050503-SpecialFilter';
neurons = [1 3];
numOfNeurons = length(neurons);
folderPath = strcat('C:\projects\NavigationModels\GLM\rawDataForLearning\', sessionName);
configFilePath = ['C:\projects\NavigationModels\GLM\rawDataForLearning\' 'config'];
filePath = [folderPath '\data_for_cell_'];

%% Single neurons, no history
fCoupling = 0;
coupledNeurons = [];
for neuronNumber = 1:length(neurons)
[stimulus,tuningParams, couplingFilters, historyFilter, bias, dt] =...
    runLearning(sessionName,filePath, neurons(neuronNumber), configFilePath, fCoupling, coupledNeurons);
end

%% single neurons, history
fCoupling = 1;

coupledNeurons = [];
for neuronNumber = 1:length(neurons)

[stimulus,tuningParams, couplingFilters, historyFilter, bias, dt] =...
    runLearning(sessionName,filePath,  neurons(neuronNumber), configFilePath, fCoupling, coupledNeurons);
end

%% network neurons, history and coupling
fCoupling = 1;

stimulus = {};
tuning = {};
couplingFilters = {};
historyFilters = {};
bias = zeros(numOfNeurons, 1);
maxCouplingLength = [];
maxHistoryLength = [];

for neuronNumber = 1:length(neurons);
coupledNeurons = neurons;
coupledNeurons(neuronNumber) = [];
[stimulus{neuronNumber},tuning{neuronNumber}, couplingFilters{neuronNumber}, historyFilters{neuronNumber}, bias(neuronNumber), dt] =...
    runLearning(sessionName, filePath,  neurons(neuronNumber), configFilePath, fCoupling, coupledNeurons);

maxCouplingLength = [maxCouplingLength; size(couplingFilters{neuronNumber},1)];
maxHistoryLength = [maxHistoryLength; length(historyFilters{neuronNumber})];
end

historyLen = max(maxHistoryLength);
couplingLen = max(maxCouplingLength);
historyFilt = zeros(historyLen, numOfNeurons);
couplingFilt = zeros(couplingLen,numOfNeurons,numOfNeurons);
for neuronNumber = 1:length(neurons)
    currNeuron = neuronNumber;
    coupledNeurons = 1:numOfNeurons;
    coupledNeurons(neuronNumber) = [];
    currCouplingLen = size(couplingFilters{neuronNumber},1);
    currHistoryLen =  length(historyFilters{neuronNumber});
    couplingFilt(1:currCouplingLen,neuronNumber, coupledNeurons) = couplingFilters{neuronNumber};
    historyFilt(1:currHistoryLen, neuronNumber) = historyFilters{neuronNumber};
end
%% Full simulation of the network
simulationLength = size(stimulus{1},1);
firingRate = [];
for i = 1:10
firingRate = [firingRate; simulateCoupledNetworkResponse(numOfNeurons, stimulus, tuning, historyFilt, couplingFilt, bias,  dt, simulationLength, historyLen)];
end
for neuronNumber = 1:length(neurons)
    spiketrain = firingRate(:,neuronNumber);
    save(['rawDataForLearning/' sessionName '/fullyCoupled_' num2str(neurons(neuronNumber))], 'spiketrain');
end
sum(firingRate)
%profile viewer