function buildDataForNeuronLearning(neuronNumber)
% description of variables included:
% boxSize = length (in cm) of one side of the square box
% post = vector of time (seconds) at every 20 ms time bin
% spiketrain = vector of the # of spikes in each 20 ms time bin
% posx = x-position of left LED every 20 ms
% posx2 = x-position of right LED every 20 ms
% posx_c = x-position in middle of LEDs
% posy = y-position of left LED every 20 ms
% posy2 = y-posiiton of right LED every 20 ms
% posy_c = y-position in middle of LEDs
% filt_eeg = local field potential, filtered for theta frequency (4-12 Hz)
% eeg_sample_rate = sample rate of filt_eeg (250 Hz)
% sampleRate = sampling rate of neural data and behavioral variable (50Hz)
load('All_Cells.mat');

ChoosedNeuron = neurons(neuronNumber);

boxSize = [140 20];
post = ChoosedNeuron.Time - ChoosedNeuron.Time(1);
lengthOfExp = length(post);
SpikeTime = ChoosedNeuron.SpikeTime - ChoosedNeuron.Time(1);
posx = ChoosedNeuron.X';
posy = ChoosedNeuron.Y';
sampleRate = 1/8;
headDirection = ChoosedNeuron.Orient';
% TimeBetweenRecords = mean(diff(ChoosedNeuron.Time));
% IndexesToResolve =  find(diff(ChoosedNeuron.Time) > TimeBetweenRecords);
% IndexesToResolve(1) = [];
spiketrain = zeros(lengthOfExp, 1);

for i = 1:length(SpikeTime)
    [~, wantedIndex] = min(abs(post - SpikeTime(i)));
    spiketrain(wantedIndex) = spiketrain(wantedIndex) + 1;
end
% figure();
spikedIndexes = find(spiketrain);
firstindex = max(spikedIndexes(1) - 10, 1);
lastIndex = min(lengthOfExp, spikedIndexes(end) + 10);
spiketrain = spiketrain(firstindex:lastIndex);
posx = posx(firstindex:lastIndex);
posy = posy(firstindex:lastIndex);
headDirection = headDirection(firstindex:lastIndex);
save(['../GLM/rawDataForLearning/data_for_cell_' num2str(neuronNumber)], 'boxSize', 'post', 'SpikeTime', 'posx', 'posy', 'sampleRate', 'headDirection', 'spiketrain');
% plot(diff(ChoosedNeuron.Time));
end