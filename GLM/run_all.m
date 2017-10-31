    clear all;
%profile on
folderPath = 'C:\projects\NavigationModels\dummyCheck\';
configFilePath = [folderPath 'config'];
filePath = [folderPath 'data_for_cell_'];
fCoupling = 1;
coupledNeurons = [];
for neuronNumber = 510:510

    neuronNumber
[config, learningData, features, numModels, testFit, trainFit, param] =...
    runLearning(filePath, neuronNumber, configFilePath, fCoupling, coupledNeurons);
end

%profile viewer