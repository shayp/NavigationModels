function [theta_grid,dirVec] = theta_map(thetaPhase,nbins)

theta_grid = zeros(length(thetaPhase),nbins);
dirVec = linspace(0, 2 * pi, nbins);

for i = 1:numel(thetaPhase)
    
    % figure out the hd index
    [~, idx] = min(abs(thetaPhase(i)-dirVec));
    theta_grid(i,idx) = 1;
  
end
theta_grid = sparse(theta_grid);
return