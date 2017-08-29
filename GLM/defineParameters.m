% description of variables included:
% boxSize = length (in cm) of one side of the square box
% post = vector of time (seconds) at every 20 ms time bin
% spiketrain = vector of the # of spikes in each 20 ms time bin
% posx = x-position of left LED every 20 ms
% posy = y-position of left LED every 20 ms
% sampleRate = sampling rate of neural data and behavioral variable (8Hz)
Max_Speed_X = 40;
Max_Speed_Y = 20;
numPos = 100; numHD = 10; % hardcoded: number of parameters
numBorder = 10;
numVelX = 25;
numVelY = 25;
numVel = numVelX * numVelY;
sampleRate = 8;
maxDistanceFromBorder = 7;
% initialize the number of bins that position, head direction, speed, and
% theta phase will be divided into
n_pos_bins = sqrt(numPos);
n_dir_bins = numHD;
n_vel_bins = sqrt(numVel);
n_border_bins = numBorder;