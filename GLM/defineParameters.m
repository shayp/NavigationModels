% description of variables included:

Max_Speed_X = 40;
Max_Speed_Y = 40;
numPos = 400; numHD = 20; % hardcoded: number of parameters
numBorder = 10;
numVelX = 25;
numVelY = 25;
numVel = numVelX * numVelY;
sampleRate = 50;
maxDistanceFromBorder = 10;
% initialize the number of bins that position, head direction, speed, and
% theta phase will be divided into
n_pos_bins = sqrt(numPos);
n_dir_bins = numHD;
n_vel_bins = sqrt(numVel);
n_border_bins = numBorder;