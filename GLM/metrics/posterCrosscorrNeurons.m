clear all;
networkName = '11025-19050503';
neuron1 = 1;
neuron2 = 3;
load(['rawDataForLearning/' networkName '/data_for_cell_' num2str(neuron1)]);
spikeExp1 = find(spiketrain);  

load(['rawDataForLearning/' networkName '/history_simulated_data_cell_'  num2str(neuron1)]);
spikeHistory1 = find(spiketrain);

load(['rawDataForLearning/' networkName '/coupled_simulated_data_cell_'  num2str(neuron1) '_causal']);
spikeCoupled1 = find(spiketrain);

load(['rawDataForLearning/' networkName '/coupled_simulated_data_cell_'  num2str(neuron1) '_notcausal']);
spikeCoupled1acausal1 = find(spiketrain);

load(['rawDataForLearning/' networkName '/validation_fully_simulated_' num2str(neuron1)]);
validation1 = find(spiketrain);  

load(['rawDataForLearning/' networkName '/data_for_cell_' num2str(neuron2)]);
spikeExp2 = find(spiketrain);  



load(['rawDataForLearning/' networkName '/history_simulated_data_cell_'  num2str(neuron2)]);
spikeHistory2 = find(spiketrain);

load(['rawDataForLearning/' networkName '/coupled_simulated_data_cell_'  num2str(neuron2) '_causal']);
spikeCoupled2 = find(spiketrain);

load(['rawDataForLearning/' networkName '/coupled_simulated_data_cell_'  num2str(neuron2) '_notcausal']);
spikeCoupled1acausal2 = find(spiketrain);

load(['rawDataForLearning/' networkName '/validation_fully_simulated_' num2str(neuron2)]);
validation2 = find(spiketrain);  

 T = -105.5:10:105.5;
 Tout = -0.1:0.01:0.1;
%T = -200.5:1:200.5;
%Tout = -200:1:200;
[corrReal1] = MyCrossCorrMS(spikeExp1,spikeExp2, T);
[corrHistory1] = MyCrossCorrMS(spikeExp1,spikeHistory2,T);
[corrCoupled1] = MyCrossCorrMS(spikeExp1,spikeCoupled2, T);
[corrCoupledacausal1] = MyCrossCorrMS(spikeExp1,spikeCoupled1acausal2, T);
[validationCorr] = MyCrossCorrMS(validation1,validation2, T);


[corrReal2] = MyCrossCorrMS(spikeExp2,spikeExp1, T);
[corrHistory2] = MyCrossCorrMS(spikeExp2, spikeHistory1, T);
[corrCoupled2] = MyCrossCorrMS(spikeExp2,spikeCoupled1, T);
[corrCoupledacausal2] = MyCrossCorrMS(spikeExp2,spikeCoupled1acausal1, T);

figure();

p = plot(Tout, corrReal2,'-k', Tout, corrCoupledacausal2,'-r', Tout, corrCoupled2,Tout, corrHistory2,'-b','lineWidth', 3);
legend('MEC data','Acausal interaction','Causal interaction', 'History');
p(3).Color = [0.5 0.5 0.5];
xlabel('Lag (seconds)');
%title('Cross correlation');
ylim([0.03 0.2]);
%ylim([0 inf]);

figure();

p = plot(Tout, corrReal1,'-k', Tout, corrCoupledacausal1,'-r', Tout, corrCoupled1,Tout, corrHistory1,'-b','lineWidth', 3);
legend('MEC data','Acausal interaction','Causal interaction', 'History');
p(3).Color = [0.5 0.5 0.5];
xlabel('Lag (seconds)');
%title('Cross correlation');
ylim([0.03 0.2]);

figure();
p = plot(Tout, corrReal1,'-k', Tout, corrCoupledacausal1,'-r', Tout, corrCoupled1,Tout, corrHistory1,'-b', Tout, validationCorr,'lineWidth', 3);
legend('MEC data','Acausal interaction','Causal interaction', 'History', 'fully simulated');




