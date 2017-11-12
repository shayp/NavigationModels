load('All_Cells.mat');
numOfNeurons = length(neurons);

for i = 1:92
    i
build20MsDataForNeuronLearning(i);
end