    clear all;
%profile on
folderPath = 'C:\projects\NavigationModels\dummyCheck\';
configFilePath = [folderPath 'config'];
filePath = [folderPath 'data_for_cell_'];
fCoupling = 1;
coupledNeurons = [507];
for neuronNumber = 506:506

    neuronNumber
[config, learningData, features, numModels, testFit, trainFit, param] =...
    runLearning(filePath, neuronNumber, configFilePath, fCoupling, coupledNeurons);
end

%profile viewer