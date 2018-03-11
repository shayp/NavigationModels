function [theta_grid,dirVec] = theta_map(thetaPhase,nbins)

theta_grid = zeros(length(thetaPhase),nbins);

% Set bins
dirVec = 2*pi/nbins/2:2*pi/nbins:2*pi-2*pi/nbins/2;

for i = 1:numel(thetaPhase)
    
    % figure out the theta index
    [~, idx] = min(abs(thetaPhase(i)-dirVec));
    theta_grid(i,idx) = 1;
end

% transform to sparse vector
theta_grid = sparse(theta_grid);
return