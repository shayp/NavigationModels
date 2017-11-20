clear all;
%profile on
folderPath = 'C:\projects\NavigationModels\GLM\rawDataForLearning\11084-10030502\';
configFilePath = [folderPath 'config'];
filePath = [folderPath 'data_for_cell_'];
fCoupling = 1;
coupledNeurons = [];
for neuronNumber = 3:3

neuronNumber
[config, learningData, features, numModels, testFit, trainFit, param] =...
    runLearning(filePath, neuronNumber, configFilePath, fCoupling, coupledNeurons);
end

%profile viewer