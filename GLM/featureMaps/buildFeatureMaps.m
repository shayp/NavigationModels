function [features] = buildFeatureMaps(config, learningData)
% compute position matrix
[features.posgrid, features.xBins, features.yBins] = pos_map([learningData.posx learningData.posy], config.numOfPositionAxisParams, config.boxSize);

% compute head direction matrix
[features.hdgrid, features.hdVec] = hd_map(learningData.headDirection, config.numOfHeadDirectionParams);

%Compute border matrix
[features.bordergrid, features.borderBins, features.distanceFromBorder] = border_map([learningData.posx learningData.posy], config.numOfDistanceFromBorderParams, config.boxSize, config.maxDistanceFromBorder);

% compute veocity matrix
[features.velgrid, features.velx, features.vely, features.velXVec, features.velYVec] = vel_map(learningData.posx,learningData.posy, config.numOfVelocityAxisParams, config.numOfVelocityAxisParams, config.sampleRate, config.maxVelocityXAxis, config.maxVelocityYAxis);

end