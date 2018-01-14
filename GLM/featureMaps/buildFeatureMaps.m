function [features] = buildFeatureMaps(config, learningData, hdVec)
% compute position matrix
[features.posgrid, features.xBins, features.yBins] = pos_map([learningData.posx learningData.posy], config.numOfPositionAxisParams, config.boxSize);

% compute head direction matrix
[features.hdgrid, features.hdVec] = hd_map(learningData.headDirection, config.numOfHeadDirectionParams);

% compute theta matrix
[features.thetaGrid, features.thetaVec] = theta_map(learningData.thetaPhase, config.numOfTheta);


% %Compute velocity(speed X HD) matrix
% [features.speedHDGrid, features.speedHDBins, features.speedHD] = speedHD_map(learningData.headDirection,learningData.posx, learningData.posy, config.numOfHDSpeedBins, config.maxSpeed, hdVec, config.dt);

% compute speed matrix
[features.speedgrid, features.speed, features.speedBins] = speed_map(learningData.posx,learningData.posy, config.sampleRate, config.maxSpeed, config.numOfSpeedBins);

end