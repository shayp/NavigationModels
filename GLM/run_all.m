clear all;
%profile on
folderPath = 'C:\projects\NavigationModels\GLM\rawDataForLearning\11084-10030502\';
configFilePath = [folderPath 'config'];
filePath = [folderPath 'data_for_cell_'];
fCoupling = 1;
coupledNeurons = [2 3 4 5 6 7 8 9];
for neuronNumber = 1:1

neuronNumber
[config, learningData, features, numModels, testFit, trainFit, param] =...
    runLearning(filePath, neuronNumber, configFilePath, fCoupling, coupledNeurons);
end

%profile viewer