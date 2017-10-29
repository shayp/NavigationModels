function [vel_grid, velx, vely, velXVec, velYVec] = vel_map(posx,posy,nVelXBins, nVelYBins, sampleRate, maxSpeedX, maxSpeedY)

numOfBins = nVelXBins * nVelYBins;

% add the extra just to make the vectors the same size
velx = diff([posx(1); posx]);
vely = diff([posy(1); posy]); 

velx = velx * sampleRate;
vely = vely * sampleRate;

% Remove high and low speed
velx(velx > maxSpeedX) = maxSpeedX;
velx(velx < -maxSpeedX) = -maxSpeedX;
vely(vely > maxSpeedY) = maxSpeedY;
vely(vely < -maxSpeedY) = -maxSpeedY;


% Create discrete bins
velXVec = linspace(-maxSpeedX, maxSpeedX, nVelXBins);
velYVec = linspace(-maxSpeedY, maxSpeedY, nVelYBins);

vel_grid = zeros(numel(posx),numOfBins);

for i = 1:numel(posx)

    % figure out the position index
    [~, xcoor] = min(abs(velx(i) - velXVec));
    [~, ycoor] = min(abs(vely(i) - velYVec));
    
    bin_idx = sub2ind([nVelYBins nVelXBins],nVelYBins  - ycoor + 1, xcoor);
    vel_grid(i, bin_idx) = 1;
end

return