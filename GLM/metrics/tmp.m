networkName = '11025-19050503';
neuron1 = 1;
load(['../rawDataForLearning/' networkName '/data_for_cell_' num2str(neuron1)]);
spiketimes = find(spiketrain);
%spiketimes = spiketimes(1:20);
%spiketimes = spiketimes(1:1000);
plot3(posx, posy, 1:length(posx), '-k', posx(spiketimes), posy(spiketimes), spiketimes, '.r');
