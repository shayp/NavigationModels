BIN = 1;
FilterSize=2; %in cm
FilterSize=FilterSize/2;
ind = -FilterSize/BIN : FilterSize/BIN; % 
[X Y] = meshgrid(ind, ind);
sigma=0.8; %in cm;
sigma=sigma/BIN;
%// Create Gaussian Mask
h = exp(-(X.^2 + Y.^2) / (2*sigma*sigma));

%// Normalize so that total area (sum of all weights) is 1
h = h / sum(h(:));
h
imagesc(h);
colorbar;