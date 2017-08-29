function GetNeuronStatistics(path)
load(path)
dt = post(4)-post(3);
maxSpikesInBin = max(spiketrain);
spikesInBin = zeros(maxSpikesInBin,1);
for i = 1:maxSpikesInBin
    spikesInBin(i) = sum(spiketrain == i);
end
numOfSpikedBins = length(find(spiketrain))
ISI = diff(find(spiketrain));
maxISI = max(ISI);
ISIPr = zeros(maxISI, 1);
for j = 1:maxISI
    ISIPr(j) = sum(ISI == j);
end
ISIPr = ISIPr ./ numOfSpikedBins;
figure();
ISITimes = linspace(dt, maxISI * dt, maxISI);
subplot(2,1,1);
plot(ISITimes, ISIPr);
xlim([0 1]);
xlabel('time (s)');
ylabel('Pr(spike)');
title('Inter spike interval');
subplot(2,1,2);
bar(spikesInBin);
ylabel('# Occurrences');
title('Spikes In time bin');
drawnow;
end

