%% Description
% This will compute the firing rate tuning curves for position, head
% direction, running speed, and theta phase.


% take out times when the animal ran >= 50 cm/s
% posx(indexesToRemove) = []; posy(indexesToRemove) = []; 
% headDirection(indexesToRemove) = [];
% speed(indexesToRemove) = [];
% border(indexesToRemove) = [];
% velx(indexesToRemove) = [];

% compute tuning curves for position, head direction, speed, and theta phase
[pos_curve] = compute_2d_tuning_curve(posx,posy,smooth_fr,n_pos_bins,[0 0],boxSize);
[hd_curve] = compute_1d_tuning_curve(headDirection,smooth_fr,n_dir_bins,0,2*pi);
[vel_curve] = compute_2d_tuning_curve(velx,vely,smooth_fr,n_vel_bins,[-Max_Speed_X -Max_Speed_Y],[Max_Speed_X Max_Speed_Y]);
[border_curve] = compute_1d_tuning_curve(border,smooth_fr,n_border_bins,0,5);
