% compute position matrix
[posgrid, xBins, yBins] = pos_map([posx posy], n_pos_bins, boxSize);

% compute head direction matrix
[hdgrid,hdVec, headDirection] = hd_map(headDirection,n_dir_bins);

%Compute border matrix
[bordergrid, borderBins, border] = border_map([posx posy], n_border_bins, boxSize, maxDistanceFromBorder);

% compute veocity matrix
[velgrid, velx, vely, velXVec, velYVec] = vel_map(posx,posy, numVelX, numVelY, sampleRate, Max_Speed_X, Max_Speed_Y);
save(saveParamsPath, 'posx', 'posy', 'boxSize', 'headDirection', 'border','velx', 'vely', 'sampleRate', 'spiketrain');