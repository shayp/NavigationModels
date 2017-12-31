function [tuning_curve] = compute_2d_tuning_curve(variable_x,variable_y,fr,numBin,minVal,maxVal)
% this assumes that the 2d environment is a square box, and that the
% variable is recorded along the x- and y-axes

%% define the axes and initialize variables

xAxis = linspace(minVal(1),maxVal(1),numBin+1);
yAxis = linspace(minVal(2),maxVal(2),numBin+1);

% initialize 
tuning_curve = zeros(numBin,numBin);

%% fill out the tuning curve

% find the mean firing rate in each position bin
for i  = 1:numBin
    start_x = xAxis(i); stop_x = xAxis(i+1);
    % find the times the animal was in the bin
    if i == numBin
        x_ind = find(variable_x >= start_x & variable_x <= stop_x);
    else
        x_ind = find(variable_x >= start_x & variable_x < stop_x);
    end
    for j = 1:numBin
        
        start_y = yAxis(j); stop_y = yAxis(j+1);
        
        if j == numBin
            y_ind = find(variable_y >= start_y & variable_y <= stop_y);
        else
            y_ind = find(variable_y >= start_y & variable_y < stop_y);
        end
        ind = intersect(x_ind,y_ind);
        % fill in rate map
        tuning_curve(numBin + 1 - j, i) = mean(fr(ind));

    end
end

tuning_curve(isnan(tuning_curve)) = 0;
%% smooth the tuning curve

% % fill in the NaNs with neigboring values
% nan_ind = find(isnan(tuning_curve));
% [j,i] = ind2sub(size(tuning_curve),nan_ind);
% nan_num= numel(nan_ind);
% 
% % fill in the NaNs with neigboring values
% for n = 1:nan_num
%     ind_i = i(n); ind_j = j(n);
%     
%     right = tuning_curve(ind_j,min(ind_i+1,numBin));
%     left = tuning_curve(ind_j,max(ind_i-1,1));
%     down = tuning_curve(min(ind_j+1,numBin),ind_i);
%     up = tuning_curve(max(ind_j-1,1),ind_i);
%     
%     ru = tuning_curve(max(ind_j-1,1),min(ind_i+1,numBin));
%     lu = tuning_curve(max(ind_j-1,1),max(ind_i-1,1));
%     ld = tuning_curve(min(ind_j+1,numBin),max(ind_i-1,1));
%     rd = tuning_curve(max(ind_j-1,1),min(ind_i+1,numBin));
%     
%     tuning_curve(ind_j,ind_i) = nanmean([left right up down lu ru rd ld]);
%     
% end

BIN = 3;
FilterSize=10; %in cm
FilterSize=FilterSize/2;
ind = -FilterSize/BIN : FilterSize/BIN; % 
[X Y] = meshgrid(ind, ind);
sigma=10.5; %in cm;
sigma=sigma/BIN;
%// Create Gaussian Mask
h = exp(-(X.^2 + Y.^2) / (2*sigma*sigma));
%// Normalize so that total area (sum of all weights) is 1
h = h / sum(h(:));
tuning_curve = filter2(h,tuning_curve);



return