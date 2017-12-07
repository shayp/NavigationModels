function [speedHDGrid, speedHDBins, speedHD] = speedHD_map(headDirection, posx, posy, nbins, maxSpeed, hdVec, dt)
hdValues = linspace(0, 2 * pi, length(hdVec));
[~,hdLimit] = max(hdVec);

velx = diff([posx(1); posx]);
vely = diff([posy(1); posy]); 
speed = sqrt(velx.^2+vely.^2) / dt;

hdPeak = hdValues(hdLimit);
hdInd =[];
if (hdPeak + pi / 10 < 2* pi && hdPeak - pi / 10 > 0)
    hdInd = find(headDirection >  hdPeak - pi / 10 & headDirection < hdPeak + pi / 10);
elseif (hdPeak + pi / 10 < 2* pi)
    hdInd = find(headDirection > 2 * pi + (hdPeak - pi / 10)  | headDirection < hdPeak + pi / 10);
else
    hdInd = find(headDirection < (hdPeak + pi / 10) - 2 * pi  | headDirection >  hdPeak - pi / 10);
end
    

speedHDBins = linspace(0, maxSpeed, nbins);
% store grid
speedHDGrid = zeros(length(headDirection), nbins);
speedHD = zeros(length(headDirection), 1);
% loop over positions
for idx = 1:length(hdInd)
    [~, xcoor] = min(abs(speed(hdInd(idx)) - speedHDBins));
    speedHDGrid(hdInd(idx), xcoor) = 1;
    speedHD(hdInd(idx)) = speedHDBins(xcoor);
end
speedHDGrid = sparse(speedHDGrid);
end