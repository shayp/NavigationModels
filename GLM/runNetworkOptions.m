clear all;
%profile on
sessionName = '11084-08030506';
neurons = [1 2];

folderPath = strcat('C:\projects\NavigationModels\GLM\rawDataForLearning\', sessionName);
configFilePath = ['C:\projects\NavigationModels\GLM\rawDataForLearning\' 'config'];
filePath = [folderPath '\data_for_cell_'];

%% Single neurons, no history
fCoupling = 0;
coupledNeurons = [];
for neuronNumber = 1:length(neurons)
[config, learningData, features, numModels, testFit, trainFit, param] =...
    runLearning(sessionName,filePath, neurons(neuronNumber), configFilePath, fCoupling, coupledNeurons);
end

%% single neurons, history
fCoupling = 1;
coupledNeurons = [];
for neuronNumber = 1:length(neurons)

[config, learningData, features, numModels, testFit, trainFit, param] =...
    runLearning(sessionName,filePath,  neurons(neuronNumber), configFilePath, fCoupling, coupledNeurons);
end

%% network neurons, history and coupling
fCoupling = 1;
for neuronNumber = 1:length(neurons)
coupledNeurons = neurons;
coupledNeurons(neurons(neuronNumber)) = [];
[config, learningData, features, numModels, testFit, trainFit, param] =...
    runLearning(sessionName, filePath,  neurons(neuronNumber), configFilePath, fCoupling, coupledNeurons);
end

%profile viewer