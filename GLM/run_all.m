    clear all;
%profile on
folderPath = 'C:\projects\NavigationModels\dummyCheck\';
configFilePath = [folderPath 'config'];
filePath = [folderPath 'data_for_cell_'];
fCoupling = 0;
coupledNeurons = [];
for neuronNumber = 502:502

    neuronNumber
[config, learningData, features, numModels, testFit, trainFit, param] =...
    runLearning(filePath, neuronNumber, configFilePath, fCoupling, coupledNeurons);
end

%profile viewer