clear all;
networkName = '11207-21060503';
neuron1 = 8;
neuron2 = 13;
load(['../rawDataForLearning/' networkName '/data_for_cell_' num2str(neuron1)]);
spikeExp1 = find(spiketrain);  
length(spikeExp1)
load(['../rawDataForLearning/' networkName '/fullyCoupled_'  num2str(neuron1)]);
fullyCoupled1 = find(spiketrain);

load(['../rawDataForLearning/' networkName '/history_simulated_data_cell_'  num2str(neuron1)]);
spikeHistory1 = find(spiketrain);

load(['../rawDataForLearning/' networkName '/coupled_simulated_data_cell_'  num2str(neuron1)]);
spikeCoupled1 = find(spiketrain);


load(['../rawDataForLearning/' networkName '/data_for_cell_' num2str(neuron2)]);
spikeExp2 = find(spiketrain);  
length(spikeExp2)
load(['../rawDataForLearning/' networkName '/fullyCoupled_'  num2str(neuron2)]);
fullyCoupled2 = find(spiketrain);

load(['../rawDataForLearning/' networkName '/history_simulated_data_cell_'  num2str(neuron2)]);
spikeHistory2 = find(spiketrain);

load(['../rawDataForLearning/' networkName '/coupled_simulated_data_cell_'  num2str(neuron2)]);
spikeCoupled2 = find(spiketrain);
 T = -305.5:10:305.5;
 Tout = -300:10:300;

[corrReal1] = MyCrossCorrMS(spikeExp1,spikeExp2, T);
[corrHistory1] = MyCrossCorrMS(spikeExp1,spikeHistory2,T);
[corrCoupled1] = MyCrossCorrMS(spikeExp1,spikeCoupled2, T);
[corrFully1] = MyCrossCorrMS(fullyCoupled1,fullyCoupled2,T);
[corrReal2] = MyCrossCorrMS(spikeExp2,spikeExp1, T);
[corrHistory2] = MyCrossCorrMS(spikeExp2, spikeHistory1, T);
[corrCoupled2] = MyCrossCorrMS(spikeExp2,spikeCoupled1, T);
[corrFully2] = MyCrossCorrMS(fullyCoupled2,fullyCoupled1,T);
corrHistoryOnly = MyCrossCorrMS(spikeHistory1,spikeHistory2,T);
% load(['rawDataForLearning/' networkName '/fully_simulated_'  num2str(neuron1)]);
% fullySimulated1 = find(spiketrain);

% load(['rawDataForLearning/' networkName '/fully_simulated_'  num2str(neuron2)]);
% fullySimulated2 = find(spiketrain);
% 
% [corrFully1] = MyCrossCorrMS(fullySimulated1,fullySimulated2, T);
% [corrFully2] = MyCrossCorrMS(fullySimulated2,fullySimulated1, T);

% figure();
% 
% plot(Tout, corrReal2,'-k', Tout, corrCoupled2 ,'-r', Tout, corrHistory2,'-b',Tout,corrFully2, 'lineWidth', 3);
% legend('Experiment',['Coupled - Separately, neuron ' num2str(neuron1)], 'History');
% 
% xlabel('time (ms)');
% ylabel('Cross correlation');
% title(['Cross correlation - First side']);
% %ylim([0 inf]);
% axis square;
% 
% figure();
% 
% plot(Tout, corrReal1,'-k', Tout, corrCoupled1 ,'-r', Tout, corrHistory1,'-b',Tout,corrFully1,'lineWidth', 3);
% legend('Experiment', ['Coupled - Separately, neuron ' num2str(neuron2)], 'History');
% 
% xlabel('time (ms)');
% ylabel('Cross correlation');
% title(['Cross correlation - Second side']);
% axis square;


figure();

plot(Tout, corrReal1,'-k', Tout, corrFully1 ,'-r', Tout, corrHistoryOnly,'-b','lineWidth', 3);
legend('Experiment','Coupled', 'History');

xlabel('time (ms)');
ylabel('Cross correlation');
title(['Cross correlation']);
axis square;
%ylim([0 inf]);





