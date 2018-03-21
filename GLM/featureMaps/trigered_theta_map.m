function [theta_grid,dirVec] = trigered_theta_map(thetaPhase,nbins)

numOfHistoryParams = 20;
window = 125;
theta_grid = zeros(length(thetaPhase),nbins + numOfHistoryParams);
normTheta = thetaPhase - mean(thetaPhase);
% Set bins
dirVec = 2*pi/nbins/2:2*pi/nbins:2*pi-2*pi/nbins/2;

for i = 1:numel(thetaPhase)

    % figure out the theta index
    [~, idx] = min(abs(thetaPhase(i)-dirVec));
    theta_grid(i,idx) = 1;
    
    if i > window
        theta_grid(i, nbins + 1:end) =  double(sum(theta_grid(i - window:i - 1,1:nbins)) > 0);
        theta_grid(i, nbins + idx) = 0;
    end
end

% transform to sparse vector
theta_grid = sparse(theta_grid);
return