load('All_Cells.mat');
numOfNeurons = length(neurons);

for i = 1:numOfNeurons
    i
buildDataForNeuronLearning(i);
end