function [speed_grid, speedVec, speed, velX_grid, velXVec, velx] = speed_map(posx,posy,nSpeedBins, nVelXBins)

%compute velocity
sampleRate = 8;
velx = diff([posx(1); posx]); vely = diff([posy(1); posy]); % add the extra just to make the vectors the same size
speed = sqrt(velx.^2+vely.^2)*sampleRate; 

maxSpeed = 40;
velx = velx * sampleRate;
speed(speed>maxSpeed) = maxSpeed; %send everything over 50 cm/s to 50 cm/s
velx(velx > maxSpeed) = maxSpeed;
velx(velx < -maxSpeed) = -maxSpeed;

speedVec = maxSpeed/nSpeedBins/2:maxSpeed/nSpeedBins:maxSpeed-maxSpeed/nSpeedBins/2;
velXVec = -maxSpeed + maxSpeed/nVelXBins: 2* maxSpeed/nVelXBins: maxSpeed-maxSpeed/nVelXBins;
speed_grid = zeros(numel(posx),numel(speedVec));
velX_grid = zeros(numel(posx),numel(velXVec));

for i = 1:numel(posx)

    % figure out the speed index
    [~, idx] = min(abs(speed(i)-speedVec));
    speed_grid(i,idx) = 1;
    
    % figure out the speed index
    [~, idx] = min(abs(velx(i)-velXVec));
    velX_grid(i,idx) = 1;
end

return