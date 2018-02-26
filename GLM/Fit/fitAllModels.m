%% Description
% The model: r = exp(W*theta), where r is the predicted # of spikes, W is a
% matrix of one-hot vectors describing variable (P, H, S, or T) values, and
% theta is the learned vector of parameters.
function [numModels, testFit, trainFit, param, Models,modelType, kfoldsParam, selected_models] = fitAllModels(learnedParameters, config, features, fCoupling)

%% Fit all 15 LN models
posgrid = features.posgrid;
hdgrid = features.hdgrid;
speedgrid = features.speedgrid;
thetaGrid = features.thetaGrid;

numModels = config.numModels;
testFit = cell(numModels,1);
trainFit = cell(numModels,1);
param = cell(numModels,1);
kfoldsParam = cell(numModels,1);

Models = cell(numModels,1);
modelType = cell(numModels,1);

% ALL VARIABLES
Models{1} = [posgrid hdgrid speedgrid thetaGrid];
modelType{1} = [1 1 1 1];

% THREE VARIABLES
modelType{2} = [1 1 1 0];
modelType{3} = [1 1 0 1];
modelType{4} = [1 0 1 1];
modelType{5} = [0 1 1 1];

Models{2} = [posgrid hdgrid speedgrid];
Models{3} = [posgrid hdgrid thetaGrid];
Models{4} = [posgrid speedgrid thetaGrid];
Models{5} = [hdgrid speedgrid thetaGrid];

% TWO VARIABLES
modelType{6} = [1 1 0 0];
modelType{7} = [1 0 1 0];
modelType{8} = [1 0 0 1];
modelType{9} = [0 1 1 0];
modelType{10} = [0 1 0 1];
modelType{11} = [0 0 1 1];

Models{6} = [posgrid hdgrid];
Models{7} = [posgrid speedgrid];
Models{8} = [posgrid thetaGrid];
Models{9} = [hdgrid speedgrid];
Models{10} = [hdgrid thetaGrid];
Models{11} = [speedgrid thetaGrid];

% ONE VARIABLE
modelType{12} = [1 0 0 0];
modelType{13} = [0 1 0 0];
modelType{14} = [0 0 1 0];
modelType{15} = [0 0 0 1];

Models{12} = [posgrid];
Models{13} = [hdgrid];
Models{14} = [speedgrid];
Models{15} = [thetaGrid];
% compute the number of folds we would like to do
numFolds = config.numFolds;
%selected_models = [2 6 7 9 12 13 14];
selected_models = [12];
%selected_models = 1:(numModels);
for n = selected_models
    fprintf('\t- Fitting model %d of %d\n', n, numModels);
    [testFit{n},trainFit{n},param{n}, kfoldsParam{n}] = fit_model(Models{n},  learnedParameters.spiketrain, ...
        config.filter, modelType{n}, numFolds, config, features.designMatrix);
end

notselected = setdiff(1:numModels, selected_models);
for j = notselected
    testFit{j} =  nan(numFolds,6);
    trainFit{j} =  nan(numFolds,6);
    param{j} = 0;
end