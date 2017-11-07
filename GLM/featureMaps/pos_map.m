function [posgrid, xBins, yBins] = pos_map(pos, nbins, boxSize)

xBins = linspace(0, boxSize(1), nbins);
yBins = linspace(0, boxSize(2), nbins);
% store grid
posgrid = zeros(length(pos), nbins * nbins);
% loop over positions
for idx = 1:length(pos)
    
    % figure out the position index
    [~, xcoor] = min(abs(pos(idx,1)-xBins));
    [~, ycoor] = min(abs(pos(idx,2)-yBins));
    
    bin_idx = sub2ind([nbins nbins],nbins  - ycoor + 1, xcoor);
    posgrid(idx, bin_idx) = 1;
    
end
posgrid = sparse(posgrid);
end