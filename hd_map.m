function [hd_grid,dirVec, headDirection] = hd_map(headDirection,nbins)

headDirection = headDirection + pi;

hd_grid = zeros(length(headDirection),nbins);
dirVec = 2*pi/nbins/2:2*pi/nbins:2*pi-2*pi/nbins/2;

for i = 1:numel(headDirection)
    
    % figure out the hd index
    [~, idx] = min(abs(headDirection(i)-dirVec));
    hd_grid(i,idx) = 1;
  
end

return