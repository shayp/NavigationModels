clear all;
neuronNumber = 3;
networkName = '11025-20050501';
load(['C:\projects\NavigationModels\GLM\rawDataForLearning\' networkName '\data_for_cell_' num2str(neuronNumber)])
peak = 100;
numBins = 6;
spikeT = find(spiketrain);
diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
figure();
z = hist(isi,1:1:5000);
z = cumsum(z);
plot(z / z(end))
xlim([0 100]);
phase = phase * 180 / pi;
ind =  isi > peak;
phaseSpike = phase(spikeT);
edges = 0:60:360;

[mecPhaseSpikesHist, ~] = histcounts(phaseSpike(ind), edges);

%histogram(phaseSpike(ind), edges);
%  figure();
%  hist(phase, 0:0.3:2*pi);

load(['C:\projects\NavigationModels\GLM\rawDataForLearning\' networkName '\history_simulated_data_cell_' num2str(neuronNumber)])
spikeT = find(spiketrain);

diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
ind =  isi > peak;
phaseSpike = phase(spikeT);
[historySpikesHist, ~] = histcounts(phaseSpike(ind), edges);

load(['C:\projects\NavigationModels\GLM\rawDataForLearning\' networkName '\coupled_simulated_data_cell_' num2str(neuronNumber)])
spikeT = find(spiketrain);

diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
ind =  isi > peak;
phaseSpike = phase(spikeT);
[NoPhaseSpikesHist, ~] = histcounts(phaseSpike(ind), edges);
figure();
b = bar(edges(1:end - 1)',[mecPhaseSpikesHist / sum(mecPhaseSpikesHist); historySpikesHist / sum(historySpikesHist); NoPhaseSpikesHist / sum(NoPhaseSpikesHist)]');
xlabel('Angle');
ylabel('Pr (Theta phase / Spike)');
title('Phase locking');
legend('MEC data', 'History','single');
b(1).FaceColor = 'k';
b(2).FaceColor = 'r';
b(3).FaceColor = 'b';
