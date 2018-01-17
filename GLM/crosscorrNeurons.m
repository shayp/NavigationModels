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
 T = -105.5:10:105.5;
 Tout = -100:10:100;
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

load(['rawDataForLearning/' networkName '/fully_simulated_'  num2str(neuron1)]);
fullySimulated1 = find(spiketrain);

load(['rawDataForLearning/' networkName '/fully_simulated_'  num2str(neuron2)]);
fullySimulated2 = find(spiketrain);

[corrFully1] = MyCrossCorrMS(fullySimulated1,fullySimulated2, T);
[corrFully2] = MyCrossCorrMS(fullySimulated2,fullySimulated1, T);

figure();

plot(Tout, corrReal2,Tout,corrFully2, Tout, corrCoupled2 , Tout, corrHistory2,'lineWidth', 2);
legend('Experiment','Coupled - Simultaneously', ['Coupled - Separately, neuron ' num2str(neuron1)], 'History');

xlabel('time (ms)');
ylabel('Cross correlation');
title(['Cross correlation - First side']);
ylim([0 0.3]);
%ylim([0 inf]);

figure();

plot(Tout, corrReal1,Tout,corrFully1, Tout, corrCoupled1 , Tout, corrHistory1,'lineWidth', 2);
legend('Experiment','Coupled - Simultaneously', ['Coupled - Separately, neuron ' num2str(neuron2)], 'History');

xlabel('time (ms)');
ylabel('Cross correlation');
title(['Cross correlation - Second side']);
ylim([0 0.3]);

%ylim([0 inf]);





