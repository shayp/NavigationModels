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
T = -205.5:10:205.5;
Tout = -200:10:200;
[corrReal] = MyCrossCorrMS(spikeExp,spikeExp, T);
[corrNoHistory] = MyCrossCorrMS(spikeNoHistory,spikeNoHistory,T);
[corrHistory] = MyCrossCorrMS(spikeHistory,spikeHistory, T);
[corrCoupled] = MyCrossCorrMS(spikeCoupled,spikeCoupled, T);

figure();
plot(Tout, corrReal,'-k',Tout, corrNoHistory,'-b',Tout, corrHistory,'-r', 'lineWidth', 3);
legend('MEC data', 'No history', 'History');
xlabel('time (ms)');
ylabel('Auto correlation');
%title('Auto correlation');
%ylim([0 1]);

[corrRealExp] = MyCrossCorrMS(spikeExp,spikeExp, T);
[corrNoHistoryExp] = MyCrossCorrMS(spikeNoHistory,spikeExp,T);
[corrHistoryExp] = MyCrossCorrMS(spikeHistory, spikeExp, T);
[corrCoupledExp] = MyCrossCorrMS(spikeCoupled,spikeExp, T);

% subplot(2,1,2);
% plot(Tout, corrNoHistoryExp,Tout, corrHistoryExp, Tout, corrCoupledExp,'lineWidth', 2);
% legend('No history', 'history', 'Coupled');
% xlabel('time (ms)');
% ylabel('Auto correlation');
% title('Auto correlation');
