function [speed_grid, speed, speedBins] = speed_map(posx,posy, sampleRate, maxSpeed, numOfSpeedBins,speedBins)


% add the extra just to make the vectors the same size
velx = diff([posx(1); posx]);
vely = diff([posy(1); posy]); 

speed = sqrt(velx.^2+vely.^2) * sampleRate;


speed_grid = zeros(numel(posx),numOfSpeedBins);

for i = 1:numel(posx)

    % figure out the position index
    [~, id] = min(abs(speed(i) - speedBins));
    
    speed_grid(i, id) = 1;
end
speed_grid = sparse(speed_grid);
return