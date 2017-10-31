%% Description
% This will compute the firing rate tuning curves for position, head
% direction, running speed, and theta phase.

function [pos_curve, hd_curve, vel_curve, border_curve] = computeTuningCurves(dataForLearning, features, config, spiketrain)
firingRate = spiketrain / config.dt;
% compute tuning curves for position, head direction, speed, and theta phase
[pos_curve] = compute_2d_tuning_curve(dataForLearning.posx, dataForLearning.posy,firingRate,config.numOfPositionAxisParams, [0 0], config.boxSize);
[hd_curve] = compute_1d_tuning_curve(dataForLearning.headDirection, firingRate, config.numOfHeadDirectionParams, 0, 2*pi);
[vel_curve] = compute_2d_tuning_curve(features.velx, features.vely, firingRate, config.numOfVelocityAxisParams, [-config.maxVelocityXAxis -config.maxVelocityYAxis],[config.maxVelocityXAxis config.maxVelocityYAxis]);
[border_curve] = compute_1d_tuning_curve(features.distanceFromBorder, firingRate, config.numOfDistanceFromBorderParams, 0, config.maxDistanceFromBorder);

end