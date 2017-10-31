function [psth] =  computePSTH(spiketrain, windowSize)
spikeTrainLength = length(spiketrain);
psthLength = ceil(spikeTrainLength / windowSize);
psth = zeros(psthLength, 1);

% Bin the spike rate (PSTH)
for j = 1:psthLength
    currentChange = min(spikeTrainLength, j * windowSize);
    psth(j) = sum(spiketrain((j-1) * windowSize + 1: currentChange));
end
end