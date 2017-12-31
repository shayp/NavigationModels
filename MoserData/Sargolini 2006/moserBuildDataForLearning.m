function moserBuildDataForLearning(neuronSpikesPath, poitionPath, sessionName, neuronNumber, neuronName)

load(neuronSpikesPath);
load(poitionPath);

boxSize = [100 100];
nans = [find(isnan(posx)); find(isnan(posy)); find(isnan(posx2)); find(isnan(posy2))];
maxNan = 0;
posx(nans) = [];
posx2(nans) = [];
posy(nans) = [];
posy2(nans) = [];

posx = posx + 50;
posx2 = posx2 + 50;
posy = posy + 50;
posy2 = posy2 + 50;
dtStimulus = 0.02;
sampleRate = 1000;
dtSpike = 1 / sampleRate;
lengthOfStimulusMs = length(posx) * dtStimulus;
posx = interp1(dtStimulus:dtStimulus:lengthOfStimulusMs, posx, dtSpike:dtSpike:lengthOfStimulusMs);
posx2 = interp1(dtStimulus:dtStimulus:lengthOfStimulusMs, posx2, dtSpike:dtSpike:lengthOfStimulusMs);
posy = interp1(dtStimulus:dtStimulus:lengthOfStimulusMs, posy, dtSpike:dtSpike:lengthOfStimulusMs);
posy2 = interp1(dtStimulus:dtStimulus:lengthOfStimulusMs, posy2, dtSpike:dtSpike:lengthOfStimulusMs);
posx = posx(20:end - 2);
posx2 = posx2(20:end - 2);
posy = posy(20:end - 2);
posy2 = posy2(20:end - 2);
posx = posx';
posy = posy';
posx2 = posx2';
posy2 = posy2';
lengthOfExp = length(posx);

headDirection = atan2(posy2-posy,posx2-posx)+pi/2;
headDirection(headDirection < 0) = headDirection(headDirection<0)+2*pi; % go from 0 to 2*pi, without any negative numbers

spiketrain = zeros(lengthOfExp, 1);

spikeTimes = floor(cellTS * 1000) - 20;
spiketrain = double(ismember(1:lengthOfExp, spikeTimes))';

%figure();
 spikedInd = find(spiketrain);

% plot(posx, posy, posx(spikedInd), posy(spikedInd), '*');
% title(['neuron: ' num2str(neuronNumber)]);
% xlim([0 100]);
% ylim([0 100]);
% drawnow;
%savefig(['./trajectory_neuron_' num2str(neuronNumber)]);
mkdir(['../../GLM/rawDataForLearning/'  sessionName]);
save(['../../GLM/rawDataForLearning/'  sessionName '/data_for_cell_'  num2str(neuronNumber)], 'boxSize', 'post', 'posx', 'posy', 'sampleRate', 'headDirection', 'spiketrain');
save(['../../GLM/rawDataForLearning/'  sessionName '/'  num2str(neuronNumber) '_' neuronName], 'boxSize', 'post', 'posx', 'posy', 'sampleRate', 'headDirection', 'spiketrain');

end