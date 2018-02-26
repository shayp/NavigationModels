clear all;
load('C:\projects\NavigationModels\GLM\rawDataForLearning\11025-19050503\data_for_cell_1.mat')
numBins = 6;
%load('C:\projects\NavigationModels\GLM\rawDataForLearning\11025-19050503\history_simulated_data_cell_1.mat')
spikeT = find(spiketrain);
diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
phase = phase * 180 / pi;
ind =  isi > 125;
phaseSpike = phase(spikeT);
edges = 0:60:360;

[mecPhaseSpikesHist, ~] = histcounts(phaseSpike(ind), edges);

%histogram(phaseSpike(ind), edges);
%  figure();
%  hist(phase, 0:0.3:2*pi);

load('C:\projects\NavigationModels\GLM\rawDataForLearning\11025-19050503\history_simulated_data_cell_1_phase.mat')
spikeT = find(spiketrain);

diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
ind =  isi > 125;
phaseSpike = phase(spikeT);
[historyPhaseSpikesHist, ~] = histcounts(phaseSpike(ind), edges);
load('C:\projects\NavigationModels\GLM\rawDataForLearning\11025-19050503\history_simulated_data_cell_1.mat')
spikeT = find(spiketrain);

diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
ind =  isi > 125;
phaseSpike = phase(spikeT);
[historyNoPhaseSpikesHist, ~] = histcounts(phaseSpike(ind), edges);
load('C:\projects\NavigationModels\GLM\rawDataForLearning\11025-19050503\simulated_data_cell_1.mat')
spikeT = find(spiketrain);

diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
ind =  isi > 125;
phaseSpike = phase(spikeT);
[NoPhaseSpikesHist, ~] = histcounts(phaseSpike(ind), edges);
figure();
b = bar(edges(1:end - 1)',[mecPhaseSpikesHist / sum(mecPhaseSpikesHist); historyPhaseSpikesHist / sum(historyPhaseSpikesHist); historyNoPhaseSpikesHist / sum(historyNoPhaseSpikesHist); NoPhaseSpikesHist / sum(NoPhaseSpikesHist)]');
xlabel('Angle');
ylabel('Pr (Theta phase / Spike)');
title('Phase locking');
legend('MEC data', 'History & theta phase', 'History','Theta phase');
b(1).FaceColor = 'k';
b(2).FaceColor = 'r';
b(3).FaceColor = 'b';
b(4).FaceColor = [0.5 0.5 0.5];