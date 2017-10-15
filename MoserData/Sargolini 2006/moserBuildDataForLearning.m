function moserBuildDataForLearning(neuronNumber)

load([num2str(neuronNumber) '.mat']);
boxSize = [100 100];

post = t -t(1);
lengthOfExp = length(post);
SpikeTime = ts -t(1);
x1 = x1 + 50;
x2 = x2 + 50;
y1 = y1 + 50;
y2 = y2 + 50;
posx = x1;
posy = y1;
sampleRate = post(2) - post(1);
headDirection = atan2(y2-y1,x2-x1)+pi/2;
headDirection(headDirection < 0) = headDirection(headDirection<0)+2*pi; % go from 0 to 2*pi, without any negative numbers
headDirection(isnan(headDirection))= 0;
spiketrain = zeros(lengthOfExp, 1);

for i = 1:length(SpikeTime)
    [~, wantedIndex] = min(abs(post - SpikeTime(i)));
    spiketrain(wantedIndex) = spiketrain(wantedIndex) + 1;
end

figure();
spikedInd = find(spiketrain);

plot(posx, posy, posx(spikedInd), posy(spikedInd), '*');
xlim([0 100]);
ylim([0 100]);
savefig(['./trajectory_neuron_' num2str(neuronNumber)]);
save(['../../GLM/rawDataForLearning/data_for_cell_' num2str(neuronNumber)], 'boxSize', 'post', 'SpikeTime', 'posx', 'posy', 'sampleRate', 'headDirection', 'spiketrain');
end