clear all;  
numOfNeurons = 92;

%%
for i = 1:numOfNeurons
    disp(['************************ Neuron ' num2str(i) ' ************************']);
    GetNeuronStatistics(['./rawDataForLearning/data_for_cell_' num2str(i)]);
end

%%
for i = 1:numOfNeurons
    disp(['************************ Neuron ' num2str(i) ' ************************']);
    run_me(['./rawDataForLearning/data_for_cell_' num2str(i)], i);
end