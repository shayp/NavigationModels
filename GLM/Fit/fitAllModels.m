%% Description
% The model: r = exp(W*theta), where r is the predicted # of spikes, W is a
% matrix of one-hot vectors describing variable (P, H, S, or T) values, and
% theta is the learned vector of parameters.
function [numModels, testFit, trainFit, param, Models,modelType] = fitAllModels(learnedParameters, config, features, fCoupling)

%% Fit all 15 LN models
posgrid = features.posgrid;
hdgrid = features.hdgrid;
velgrid = features.velgrid;
bordergrid = features.bordergrid;

numModels = config.numModels;
testFit = cell(numModels,1);
trainFit = cell(numModels,1);
param = cell(numModels,1);
Models = cell(numModels,1);
modelType = cell(numModels,1);

% ALL VARIABLES
Models{1} = [posgrid hdgrid velgrid bordergrid];
modelType{1} = [1 1 1 1];

% THREE VARIABLES
modelType{2} = [1 1 1 0];
modelType{3} = [1 1 0 1];
modelType{4} = [1 0 1 1];
modelType{5} = [0 1 1 1];

Models{2} = [posgrid hdgrid velgrid];
Models{3} = [posgrid hdgrid bordergrid];
Models{4} = [posgrid velgrid bordergrid];
Models{5} = [hdgrid velgrid bordergrid];

% TWO VARIABLES
modelType{6} = [1 1 0 0];
modelType{7} = [1 0 1 0];
modelType{8} = [1 0 0 1];
modelType{9} = [0 1 1 0];
modelType{10} = [0 1 0 1];
modelType{11} = [0 0 1 1];

Models{6} = [posgrid hdgrid];
Models{7} = [posgrid velgrid];
Models{8} = [posgrid bordergrid];
Models{9} = [hdgrid velgrid];
Models{10} = [hdgrid bordergrid];
Models{11} = [velgrid bordergrid];

% ONE VARIABLE
modelType{12} = [1 0 0 0];
modelType{13} = [0 1 0 0];
modelType{14} = [0 0 1 0];
modelType{15} = [0 0 0 1];

Models{12} = [posgrid];
Models{13} = [hdgrid];
Models{14} = [velgrid];
Models{15} = [bordergrid];


% compute the number of folds we would like to do
numFolds = config.numFolds;

for n = 1:numModels
    fprintf('\t- Fitting model %d of %d\n', n, numModels);
    [testFit{n},trainFit{n},param{n}] = fit_model(Models{n},  learnedParameters.spiketrain, ...
        config.filter, modelType{n}, numFolds, config, features.designMatrix);
end
