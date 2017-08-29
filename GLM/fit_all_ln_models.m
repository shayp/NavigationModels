%% Description
% The model: r = exp(W*theta), where r is the predicted # of spikes, W is a
% matrix of one-hot vectors describing variable (P, H, S, or T) values, and
% theta is the learned vector of parameters.

%% compute the position, head direction, speed, and theta phase matrices

% compute position matrix
[posgrid, xBins, yBins] = pos_map([posx posy], n_pos_bins, boxSize);

% compute head direction matrix
[hdgrid,hdVec, headDirection] = hd_map(headDirection,n_dir_bins);

%Compute border matrix
[bordergrid, borderBins, border] = border_map([posx posy], n_border_bins, boxSize, maxDistanceFromBorder);

% compute veocity matrix
[velgrid, velx, vely, velXVec, velYVec] = vel_map(posx,posy, numVelX, numVelY, sampleRate, Max_Speed_X, Max_Speed_Y);


% too_slow_x = find(velx < 2 & velx > -2);
% too_slow_y = find(vely < 2 & vely > -2);
% [too_slow,ia,ib] = intersect(too_slow_x,too_slow_y);
% numOfSpikesCleaned = length(too_slow);
% posgrid(too_slow,:) = zeros(numOfSpikesCleaned, n_pos_bins* n_pos_bins);
% hdgrid(too_slow,:) = zeros(numOfSpikesCleaned, n_dir_bins);
% velgrid(too_slow,:) = zeros(numOfSpikesCleaned, numVelX * numVelY);
% bordergrid(too_slow,:) = zeros(numOfSpikesCleaned, n_border_bins);
% spiketrain(too_slow) = zeros(numOfSpikesCleaned,1);
% indexesToRemove = too_slow;
% numOfSpikes = sum(spiketrain)
%% Fit all 31 LN models

numModels = 15;
testFit = cell(numModels,1);
trainFit = cell(numModels,1);
param = cell(numModels,1);
A = cell(numModels,1);
modelType = cell(numModels,1);

% ALL VARIABLES
A{1} = [posgrid hdgrid velgrid bordergrid];
modelType{1} = [1 1 1 1];

% THREE VARIABLES
modelType{2} = [1 1 1 0];
modelType{3} = [1 1 0 1];
modelType{4} = [1 0 1 1];
modelType{5} = [0 1 1 1];

A{2} = [posgrid hdgrid velgrid];
A{3} = [posgrid hdgrid bordergrid];
A{4} = [posgrid velgrid bordergrid];
A{5} = [hdgrid velgrid bordergrid];

% TWO VARIABLES
modelType{6} = [1 1 0 0];
modelType{7} = [1 0 1 0];
modelType{8} = [1 0 0 1];
modelType{9} = [0 1 1 0];
modelType{10} = [0 1 0 1];
modelType{11} = [0 0 1 1];

A{6} = [posgrid hdgrid];
A{7} = [posgrid velgrid];
A{8} = [posgrid bordergrid];
A{9} = [hdgrid velgrid];
A{10} = [hdgrid bordergrid];
A{11} = [velgrid bordergrid];

% ONE VARIABLE
modelType{12} = [1 0 0 0];
modelType{13} = [0 1 0 0];
modelType{14} = [0 0 1 0];
modelType{15} = [0 0 0 1];

A{12} = [posgrid];
A{13} = [hdgrid];
A{14} = [velgrid];
A{15} = [bordergrid];

% compute a filter, which will be used to smooth the firing rate
filter = gaussmf(-4:4,[2 0]); filter = filter/sum(filter); 
dt = post(4)-post(3); fr = spiketrain/dt;
smooth_fr = conv(fr,filter,'same');

% compute the number of folds we would like to do
numFolds = 10;

%for n = 1:numModels
for n = 1:numModels
    fprintf('\t- Fitting model %d of %d\n', n, numModels);
    [testFit{n},trainFit{n},param{n}] = fit_model(A{n},dt,spiketrain,filter,modelType{n},numFolds, numPos, numHD, numVel, numBorder);
end
