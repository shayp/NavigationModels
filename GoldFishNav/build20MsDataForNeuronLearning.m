function build20MsDataForNeuronLearning(neuronNumber)
load('All_Cells.mat');
tenMinutes = 60 * 10 * 1000;
ChoosedNeuron = neurons(neuronNumber);
sampleRate = 50;
dt = 1 / sampleRate;
windowSize = 20;
boxSize = [140 20];
lengthOfExp1ms = round((ChoosedNeuron.Time(end) - ChoosedNeuron.Time(1)) * 1000);
lengthOfExp20ms = ceil(lengthOfExp1ms / windowSize);
spiketrain = zeros(lengthOfExp20ms, 1);
post = ChoosedNeuron.Time - ChoosedNeuron.Time(1);
SpikeTime = round((ChoosedNeuron.SpikeTime - ChoosedNeuron.Time(1)) * 1000);
t20msTimeScale = post(1):dt:post(end);
posx = interp1(post, ChoosedNeuron.X, t20msTimeScale)';
posy = interp1(post, ChoosedNeuron.Y, t20msTimeScale)';
headDirection =  interp1(post, ChoosedNeuron.Orient, t20msTimeScale)';
headDirection = headDirection + pi;
spiketrain1ms = double(ismember(1:lengthOfExp1ms, SpikeTime));

for i = 1:lengthOfExp20ms - 1
    nextJump = min(i * windowSize, lengthOfExp20ms);
    spiketrain(i) = sum(spiketrain1ms((i - 1) * windowSize + 1:i * windowSize));
end
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

%  figure();
% plot(posx, posy, '-', posx(spikeInd), posy(spikeInd), '*');
save(['../GLM/rawDataForLearning/data_for_cell_' num2str(neuronNumber)], 'boxSize', 'post', 'SpikeTime',...
    'posx', 'posy', 'sampleRate', 'headDirection', 'spiketrain', 'dt');
end