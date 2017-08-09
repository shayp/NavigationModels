function [posgrid, xBins, yBins] = pos_map(pos, nbins, boxSize)

xBins = boxSize(1)/nbins/2:boxSize(1)/nbins:boxSize(1) - boxSize(1)/nbins/2;
yBins = boxSize(2)/nbins/2:boxSize(2)/nbins:boxSize(2) - boxSize(2)/nbins/2;
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

end