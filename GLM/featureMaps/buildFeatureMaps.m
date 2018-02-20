function [features] = buildFeatureMaps(config, learningData, fTrain)
% compute position matrix
[features.posgrid, features.xBins, features.yBins] = pos_map([learningData.posx learningData.posy], config.numOfPositionAxisParams, config.boxSize);

% compute head direction matrix
[features.hdgrid, features.hdVec] = hd_map(learningData.headDirection, config.numOfHeadDirectionParams);

%smoothfr = conv(learningData.spiketrain, config.filter,'same');
smoothfr = learningData.spiketrain;
% compute theta matrix
[features.thetaGrid, features.thetaVec] = theta_map(learningData.thetaPhase, config.numOfTheta, smoothfr, config.isiToCount, fTrain);

% compute speed matrix
[features.speedgrid, features.speed, features.speedBins] = speed_map(learningData.posx,learningData.posy, config.sampleRate, config.maxSpeed, config.numOfSpeedBins);

end