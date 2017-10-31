%% Description
% This will compute the firing rate tuning curves for position, head
% direction, running speed, and theta phase.

function [pos_curve, hd_curve, vel_curve, border_curve] = computeTuningCurves(dataForLearning, features, config, smooth_fr)

% compute tuning curves for position, head direction, speed, and theta phase
[pos_curve] = compute_2d_tuning_curve(dataForLearning.posx, dataForLearning.posy,smooth_fr,config.numOfPositionAxisParams, [0 0], config.boxSize);
[hd_curve] = compute_1d_tuning_curve(dataForLearning.headDirection, smooth_fr, config.numOfHeadDirectionParams, 0, 2*pi);
[vel_curve] = compute_2d_tuning_curve(features.velx, features.vely, smooth_fr, config.numOfVelocityAxisParams, [-config.maxVelocityXAxis -config.maxVelocityYAxis],[config.maxVelocityXAxis config.maxVelocityYAxis]);
[border_curve] = compute_1d_tuning_curve(features.distanceFromBorder, smooth_fr, config.numOfDistanceFromBorderParams, 0, config.maxDistanceFromBorder);

end