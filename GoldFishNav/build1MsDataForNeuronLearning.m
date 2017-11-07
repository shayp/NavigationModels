function build1MsDataForNeuronLearning(neuronNumber)
load('All_Cells.mat');
tenMinutes = 60 * 10 * 1000;
ChoosedNeuron = neurons(neuronNumber);

boxSize = [140 20];
lengthOfExp = round((ChoosedNeuron.Time(end) - ChoosedNeuron.Time(1)) * 1000);
post = ChoosedNeuron.Time - ChoosedNeuron.Time(1);
SpikeTime = round((ChoosedNeuron.SpikeTime - ChoosedNeuron.Time(1)) * 1000);
t1msTimeScale = post(1):0.001:post(end);

posx = interp1(post, ChoosedNeuron.X, t1msTimeScale)';

posy = interp1(post, ChoosedNeuron.Y, t1msTimeScale)';
sampleRate = 1000;
headDirection =  interp1(post, ChoosedNeuron.Orient, t1msTimeScale)';
headDirection = headDirection + pi;
spiketrain = double(ismember(1:lengthOfExp, SpikeTime))';

% if length(spiketrain) > tenMinutes
%     spiketrain = spiketrain(1:tenMinutes);
%     posx = posx(1:tenMinutes);
%     posy = posy(1:tenMinutes);
%     headDirection = headDirection(1:tenMinutes);
% 
% end

nanspikedIndexes = find(isnan(spiketrain));
nanPosX = find(isnan(posx));
nanPosY = find(isnan(posy));
nanHD = find(isnan(headDirection));

nanInd = [nanspikedIndexes; nanPosX; nanPosY; nanHD];
nanInd = unique(nanInd);
spiketrain(nanInd) = [];
posx(nanInd) = [];
posy(nanInd) = [];
headDirection(nanInd) = [];

spikeInd = find(spiketrain);

dt = 1/ sampleRate;
% figure();
% plot(posx, posy, '-', posx(spikeInd), posy(spikeInd), '*');
save(['../GLM/rawDataForLearning/data_for_cell_' num2str(neuronNumber)], 'boxSize', 'post', 'SpikeTime',...
    'posx', 'posy', 'sampleRate', 'headDirection', 'spiketrain', 'dt');
end