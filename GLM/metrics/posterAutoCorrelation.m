clear all;
networkName = '11025-19050503';
neuronNumber = 1;
load(['rawDataForLearning/' networkName '/data_for_cell_' num2str(neuronNumber)]);
spikeExp = find(spiketrain);  

load(['rawDataForLearning/' networkName '/simulated_data_cell_'  num2str(neuronNumber)]);
spikeNoHistory = find(spiketrain);

load(['rawDataForLearning/' networkName '/history_simulated_data_cell_'  num2str(neuronNumber)]);
spikeHistory = find(spiketrain);

load(['rawDataForLearning/' networkName '/coupled_simulated_data_cell_'  num2str(neuronNumber)]);
spikeCoupled = find(spiketrain);

load(['rawDataForLearning/' networkName '/history_simulated_data_cell_'  num2str(neuronNumber) '_phase']);
spikeHistTheta = find(spiketrain);
T = -205.5:10:205.5;
Tout = -0.2:0.01:0.2;
[corrReal] = MyCrossCorrMS(spikeExp,spikeExp, T);
[corrNoHistory] = MyCrossCorrMS(spikeNoHistory,spikeNoHistory,T);
[corrHistory] = MyCrossCorrMS(spikeHistory,spikeHistory, T);
[corrCoupled] = MyCrossCorrMS(spikeCoupled,spikeCoupled, T);
[corrspikeHistTheta] = MyCrossCorrMS(spikeHistTheta,spikeHistTheta, T);

figure();
p=plot(Tout, corrReal,'-k',Tout, corrspikeHistTheta,'-r', Tout,corrHistory,'-b',Tout,corrNoHistory,'-y', 'lineWidth', 3);
p(4).Color=[0.5 0.5 0.5];
p(1).Color='Black';
legend('MEC data', 'History & theta phase', 'History', 'Theta phase');
xlabel('time (seconds)');
ylabel('Auto correlation');

