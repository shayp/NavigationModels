load('All_Cells.mat');
numOfNeurons = length(neurons);

for i = 50:92
    i
build1MsDataForNeuronLearning(i);
end