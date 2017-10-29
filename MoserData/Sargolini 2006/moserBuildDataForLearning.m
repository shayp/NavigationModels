function moserBuildDataForLearning(neuronNumber)

load([num2str(neuronNumber) '.mat']);
boxSize = [100 100];

post = t;
nans = [find(isnan(x1)) find(isnan(x2)) find(isnan(y1)) find(isnan(y2))]
maxNan = 0;
x1(nans) = [];
x2(nans) = [];
y1(nans) = [];
y2(nans) = [];

x1 = x1 + 50;
x2 = x2 + 50;
y1 = y1 + 50;
y2 = y2 + 50;
dtStimulus = 0.02;
sampleRate = 1000;
dtSpike = 1 / sampleRate;
lengthOfStimulusMs = length(x1) * dtStimulus;
x1 = interp1(dtStimulus:dtStimulus:lengthOfStimulusMs, x1, dtSpike:dtSpike:lengthOfStimulusMs);
x2 = interp1(dtStimulus:dtStimulus:lengthOfStimulusMs, x2, dtSpike:dtSpike:lengthOfStimulusMs);
y1 = interp1(dtStimulus:dtStimulus:lengthOfStimulusMs, y1, dtSpike:dtSpike:lengthOfStimulusMs);
y2 = interp1(dtStimulus:dtStimulus:lengthOfStimulusMs, y2, dtSpike:dtSpike:lengthOfStimulusMs);
x1 = x1(20:end - 2);
x2 = x2(20:end - 2);
y1 = y1(20:end - 2);
y2 = y2(20:end - 2);
posx = x1';
posy = y1';
lengthOfExp = length(posx);

headDirection = atan2(y2-y1,x2-x1)+pi/2;
headDirection(headDirection < 0) = headDirection(headDirection<0)+2*pi; % go from 0 to 2*pi, without any negative numbers

spiketrain = zeros(lengthOfExp, 1);

spikeTimes = floor(ts * 1000) - 20;
spiketrain = double(ismember(1:lengthOfExp, spikeTimes))';

% figure();
 spikedInd = find(spiketrain);
 length(spikedInd)
% 
% plot(posx, posy, posx(spikedInd), posy(spikedInd), '*');
% xlim([0 100]);
% ylim([0 100]);
% savefig(['./trajectory_neuron_' num2str(neuronNumber)]);
save(['../../GLM/rawDataForLearning/data_for_cell_' num2str(neuronNumber)], 'boxSize', 'post', 'posx', 'posy', 'sampleRate', 'headDirection', 'spiketrain');
end