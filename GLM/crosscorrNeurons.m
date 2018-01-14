clear all;
networkName = '11025-19050503';
neuron1 = 1;
neuron2 = 3;
load(['rawDataForLearning/' networkName '/data_for_cell_' num2str(neuron1)]);
spikeExp1 = find(spiketrain);  

load(['rawDataForLearning/' networkName '/simulated_data_cell_'  num2str(neuron1)]);
spikeNoHistory1 = find(spiketrain);

load(['rawDataForLearning/' networkName '/history_simulated_data_cell_'  num2str(neuron1)]);
spikeHistory1 = find(spiketrain);

load(['rawDataForLearning/' networkName '/coupled_simulated_data_cell_'  num2str(neuron1)]);
spikeCoupled1 = find(spiketrain);


load(['rawDataForLearning/' networkName '/data_for_cell_' num2str(neuron2)]);
spikeExp2 = find(spiketrain);  

load(['rawDataForLearning/' networkName '/simulated_data_cell_'  num2str(neuron2)]);
spikeNoHistory2 = find(spiketrain);

load(['rawDataForLearning/' networkName '/history_simulated_data_cell_'  num2str(neuron2)]);
spikeHistory2 = find(spiketrain);

load(['rawDataForLearning/' networkName '/coupled_simulated_data_cell_'  num2str(neuron2)]);
spikeCoupled2 = find(spiketrain);
 T = -205.5:10:205.5;
 Tout = -200:10:200;
%T = -200.5:1:200.5;
%Tout = -200:1:200;
[corrReal1] = MyCrossCorrMS(spikeExp1,spikeExp2, T);
[corrNoHistory1] = MyCrossCorrMS(spikeExp1,spikeNoHistory2, T);
[corrHistory1] = MyCrossCorrMS(spikeExp1,spikeHistory2,T);
[corrCoupled1] = MyCrossCorrMS(spikeExp1,spikeCoupled2, T);

[corrReal2] = MyCrossCorrMS(spikeExp2,spikeExp1, T);
[corrNoHistory2] = MyCrossCorrMS(spikeExp2,spikeNoHistory1, T);
[corrHistory2] = MyCrossCorrMS(spikeExp2, spikeHistory1, T);
[corrCoupled2] = MyCrossCorrMS(spikeExp2,spikeCoupled1, T);

[corrReal3] = MyCrossCorrMS(spikeExp1,spikeExp2, T);
[corrNoHistory3] = MyCrossCorrMS(spikeNoHistory1,spikeNoHistory2, T);
[corrHistory3] = MyCrossCorrMS(spikeHistory1,spikeHistory2,T);
[corrCoupled3] = MyCrossCorrMS(spikeCoupled1,spikeCoupled2, T);

figure();
subplot(1,2,1);
plot(Tout, corrReal2,Tout, corrHistory2, Tout, corrCoupled2,'lineWidth', 2);
legend('Real', 'history', 'Coupled');

xlabel('time (ms)');
ylabel('Cross correlation');
title(['Cross correlation - Neuron ' num2str(neuron1) ' simulated']);
%ylim([0 0.3]);
ylim([0 inf]);

subplot(1,2,2);


plot(Tout, corrReal1,Tout, corrHistory1, Tout, corrCoupled1,'lineWidth', 2);
legend('Real', 'history', 'Coupled');
xlabel('time (ms)');
ylabel('Cross correlation');
title(['Cross correlation - Neuron ' num2str(neuron2) ' simulated']);
ylim([0 inf]);

%ylim([0 0.3]);
% figure();
% 
% plot(Tout, corrReal3,Tout, corrHistory3, Tout, corrCoupled3,'lineWidth', 2);
% legend('Real', 'history', 'Coupled');
% 
% xlabel('time (ms)');
% ylabel('Cross correlation');
% title('Cross correlation');
% ylim([0 0.2]);
