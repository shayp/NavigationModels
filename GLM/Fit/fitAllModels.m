%% Description
% The model: r = exp(W*theta), where r is the predicted # of spikes, W is a
% matrix of one-hot vectors describing variable (P, H, S, or T) values, and
% theta is the learned vector of parameters.
function [numModels, testFit, trainFit, param, Models,modelType] = fitAllModels(learnedParameters, config, features, fCoupling)

%% Fit all 15 LN models
posgrid = features.posgrid;
hdgrid = features.hdgrid;
speedgrid = features.speedgrid;
speedHDGrid = features.speedHDGrid;

numModels = config.numModels;
testFit = cell(numModels,1);
trainFit = cell(numModels,1);
param = cell(numModels,1);
Models = cell(numModels,1);
modelType = cell(numModels,1);

% ALL VARIABLES
Models{1} = [posgrid hdgrid speedgrid speedHDGrid];
modelType{1} = [1 1 1 1];

% THREE VARIABLES
modelType{2} = [1 1 1 0];
modelType{3} = [1 1 0 1];
modelType{4} = [1 0 1 1];
modelType{5} = [0 1 1 1];

Models{2} = [posgrid hdgrid speedgrid];
Models{3} = [posgrid hdgrid speedHDGrid];
Models{4} = [posgrid speedgrid speedHDGrid];
Models{5} = [hdgrid speedgrid speedHDGrid];

% TWO VARIABLES
modelType{6} = [1 1 0 0];
modelType{7} = [1 0 1 0];
modelType{8} = [1 0 0 1];
modelType{9} = [0 1 1 0];
modelType{10} = [0 1 0 1];
modelType{11} = [0 0 1 1];

Models{6} = [posgrid hdgrid];
Models{7} = [posgrid speedgrid];
Models{8} = [posgrid speedHDGrid];
Models{9} = [hdgrid speedgrid];
Models{10} = [hdgrid speedHDGrid];
Models{11} = [speedgrid speedHDGrid];

% ONE VARIABLE
modelType{12} = [1 0 0 0];
modelType{13} = [0 1 0 0];
modelType{14} = [0 0 1 0];
modelType{15} = [0 0 0 1];

Models{12} = [posgrid];
Models{13} = [hdgrid];
Models{14} = [speedgrid];
Models{15} = [speedHDGrid];


% compute the number of folds we would like to do
numFolds = config.numFolds;

for n = 1:numModels
    fprintf('\t- Fitting model %d of %d\n', n, numModels);
    [testFit{n},trainFit{n},param{n}] = fit_model(Models{n},  learnedParameters.spiketrain, ...
        config.filter, modelType{n}, numFolds, config, features.designMatrix);
end
