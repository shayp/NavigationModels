%% Description
% This will compute the firing rate tuning curves for position, head
% direction, running speed, and theta phase.

function [pos_curve, hd_curve, speed_curve, thetaCurve] = computeTuningCurves(dataForLearning, features, config, spiketrain)
firingRate = spiketrain / config.dt;
% compute tuning curves for position, head direction, speed, and theta phase
[pos_curve] = compute_2d_tuning_curve(dataForLearning.posx, dataForLearning.posy,firingRate,config.numOfPositionAxisParams, [0 0], config.boxSize);
[hd_curve] = compute_1d_tuning_curve(dataForLearning.headDirection, firingRate, config.numOfHeadDirectionParams, 0, 2*pi);
[speed_curve] = compute_1d_tuning_curve(features.speed,  firingRate, config.numOfSpeedBins, 0, config.maxSpeed);
[thetaCurve] = compute_1d_tuning_curve(dataForLearning.thetaPhase, firingRate, config.numOfTheta, 0, 2*pi);

end