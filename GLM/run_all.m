clear all;  
numOfNeurons = 92;

%%
for i = 1:numOfNeurons
    disp(['************************ Neuron ' num2str(i) ' ************************']);
    GetNeuronStatistics(['./rawDataForLearning/data_for_cell_' num2str(i)]);
end

%% Building featurs
for i = 1:numOfNeurons
    disp(['************************ Neuron ' num2str(i) ' ************************']);
    run_me(['./rawDataForLearning/data_for_cell_' num2str(i)], i, 0, ['../NeuralNetwork/rawDataForLearning/params_for_cell_' num2str(i)]);
end
%% Learning
for i = 501:517
    disp(['************************ Neuron ' num2str(i) ' ************************']);
    run_me(['./rawDataForLearning/data_for_cell_' num2str(i)], i, 1,  ['../NeuralNetwork/rawDataForLearning/params_for_cell_' num2str(i)]);
end