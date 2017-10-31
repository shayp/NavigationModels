function [hd_grid,dirVec] = hd_map(headDirection,nbins)

hd_grid = zeros(length(headDirection),nbins);
dirVec = linspace(0, 2 * pi, nbins);

for i = 1:numel(headDirection)
    
    % figure out the hd index
    [~, idx] = min(abs(headDirection(i)-dirVec));
    hd_grid(i,idx) = 1;
  
end

return