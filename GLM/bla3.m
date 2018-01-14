clear all;
load('C:\projects\NavigationModels\GLM\rawDataForLearning\11265-09020601\data_for_cell_8.mat')
load('C:\projects\NavigationModels\GLM\rawDataForLearning\11265-09020601\history_simulated_data_cell_8.mat')

%load('C:\projects\NavigationModels\GLM\rawDataForLearning\11025-19050503\history_simulated_data_cell_1.mat')
spikeT = find(spiketrain);
diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
ind =  isi > 2;
phaseSpike = phase(spikeT);
figure();
[vals, edges] = histcounts(phaseSpike(ind), 5);
bar(edges(1:end - 1), vals / sum(vals));
 ylim([0 1]);
%histogram(phaseSpike(ind), edges);
%  figure();
%  hist(phase, 0:0.3:2*pi);
