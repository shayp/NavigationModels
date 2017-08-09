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
[bordergrid, borderBins, border] = border_map([posx posy], n_border_bins, boxSize);
% compute speed matrix
[speedgrid,speedVec,speed, velxgrid,velxVec, velx] = speed_map(posx,posy,n_speed_bins, n_vel_bins);

limitSppedToPlot = max(speed);
% remove times when the animal ran > 50 cm/s (these data points may contain artifacts)
too_fast = find(speed >= Max_Speed);
too_slow = find(speed <= Min_Speed);
%indexesToRemove = [too_fast' too_slow']';
indexesToRemove = too_fast;
posgrid(indexesToRemove,:) = [];
hdgrid(indexesToRemove,:) = []; 
speedgrid(indexesToRemove,:) = [];
spiketrain(indexesToRemove) = [];
velxgrid(indexesToRemove,:) = [];
bordergrid(indexesToRemove,:) = [];
%% Fit all 31 LN models

numModels = 31;
testFit = cell(numModels,1);
trainFit = cell(numModels,1);
param = cell(numModels,1);
A = cell(numModels,1);
modelType = cell(numModels,1);

% ALL VARIABLES
A{1} = [posgrid hdgrid speedgrid velxgrid bordergrid];
modelType{1} = [1 1 1 1 1];

% FOUR VARIABLES
modelType{2} = [1 1 1 1 0];
modelType{3} = [1 1 1 0 1];
modelType{4} = [1 1 0 1 1];
modelType{5} = [1 0 1 1 1];
modelType{6} = [0 1 1 1 1];

A{2} = [posgrid hdgrid speedgrid velxgrid];
A{3} = [posgrid hdgrid speedgrid bordergrid];
A{4} = [posgrid hdgrid velxgrid bordergrid];
A{5} = [posgrid speedgrid velxgrid bordergrid];
A{6} = [hdgrid speedgrid velxgrid bordergrid];

% THREE VARIABLES
modelType{7} = [1 1 1 0 0];
modelType{8} = [1 1 0 1 0];
modelType{9} = [1 1 0 0 1];
modelType{10} = [1 0 1 1 0];
modelType{11} = [1 0 1 0 1];
modelType{12} = [1 0 0 1 1];
modelType{13} = [0 1 1 1 0];
modelType{14} = [0 1 1 0 1];
modelType{15} = [0 1 0 1 1];
modelType{16} = [0 0 1 1 1];

A{7} = [posgrid hdgrid speedgrid];
A{8} = [posgrid hdgrid velxgrid];
A{9} = [posgrid hdgrid bordergrid];
A{10} = [posgrid speedgrid velxgrid];
A{11} = [posgrid speedgrid bordergrid];
A{12} = [posgrid velxgrid bordergrid];
A{13} = [hdgrid speedgrid velxgrid];
A{14} = [hdgrid speedgrid bordergrid];
A{15} = [hdgrid velxgrid bordergrid];
A{16} = [speedgrid velxgrid bordergrid];


% TWO VARIABLES
modelType{17} = [1 1 0 0 0];
modelType{18} = [1 0 1 0 0];
modelType{19} = [1 0 0 1 0];
modelType{20} = [1 0 0 0 1];
modelType{21} = [0 1 1 0 0];
modelType{22} = [0 1 0 1 0];
modelType{23} = [0 1 0 0 1];
modelType{24} = [0 0 1 1 0];
modelType{25} = [0 0 1 0 1];
modelType{26} = [0 0 0 1 1];

A{17} = [posgrid hdgrid];
A{18} = [posgrid speedgrid];
A{19} = [posgrid velxgrid];
A{20} = [posgrid bordergrid];
A{21} = [hdgrid speedgrid];
A{22} = [hdgrid velxgrid];
A{23} = [hdgrid bordergrid];
A{24} = [speedgrid velxgrid];
A{25} = [speedgrid bordergrid];
A{26} = [velxgrid bordergrid];


% ONE VARIABLE
modelType{27} = [1 0 0 0 0];
modelType{28} = [0 1 0 0 0];
modelType{29} = [0 0 1 0 0];
modelType{30} = [0 0 0 1 0];
modelType{31} = [0 0 0 0 1];

A{27} = [posgrid];
A{28} = [hdgrid];
A{29} = [speedgrid];
A{30} = [velxgrid];
A{31} = [bordergrid];

% compute a filter, which will be used to smooth the firing rate
filter = gaussmf(-4:4,[2 0]); filter = filter/sum(filter); 
dt = post(4)-post(3); fr = spiketrain/dt;
smooth_fr = conv(fr,filter,'same');

% compute the number of folds we would like to do
numFolds = 10;

%for n = 1:numModels
for n = 1:numModels
    fprintf('\t- Fitting model %d of %d\n', n, numModels);
    [testFit{n},trainFit{n},param{n}] = fit_model(A{n},dt,spiketrain,filter,modelType{n},numFolds, numPos, numHD, numSpd, numVelX, numBorder);
end
