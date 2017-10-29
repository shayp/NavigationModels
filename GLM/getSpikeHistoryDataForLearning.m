function designMatrix = getSpikeHistoryDataForLearning(config, learningData, numOfCoupledNeurons, couplingData)

designMatrix = buildSpikeHistoryDesignMatrix(config.numOfHistoryParams, learningData.historyBaseVectors, learningData.spiketrain);

for i = 1:numOfCoupledNeurons
    currCouplingMatrix = buildSpikeHistoryDesignMatrix(config.numOfCouplingParams, learningData.couplingBaseVectors,couplingData.data(i).spiketrain);
    designMatrix = [designMatrix currCouplingMatrix];
end

end