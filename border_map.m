function [bordergrid, borderBins, border] = border_map(pos, nbins, boxSize)
xBorder = [0 boxSize(1)];
yBorder = [0 boxSize(2)];

borderBins = linspace(0, 4, nbins);
% store grid
bordergrid = zeros(length(pos), nbins);
border = zeros(length(pos), 1);
% loop over positions
for idx = 1:length(pos)
    
    % figure out the position index
    [xBorder, xcoor] = min(abs(pos(idx,1) - xBorder));
    [yBorder, ycoor] = min(abs(pos(idx,2)- yBorder));
    
   lengthFromBorder = min(xBorder, yBorder);
   [~, indexInCurve] = min(abs(lengthFromBorder - borderBins));
   border(idx) = lengthFromBorder;
   if lengthFromBorder < 4
        bordergrid(idx, indexInCurve) = 1;
   end
end

end