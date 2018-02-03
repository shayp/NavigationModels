function designMatrix = getSpikeHistoryDataForLearning(config, learningData, numOfCoupledNeurons, couplingData)

designMatrix = buildSpikeHistoryDesignMatrix(config.numOfHistoryParams, learningData.historyBaseVectors, learningData.spiketrain);

for i = 1:numOfCoupledNeurons
    currCouplingMatrix = buildCouplingDesignMatrix(config.numOfCouplingParams, learningData.couplingBaseVectors,couplingData.data(i).spiketrain, config.timeBeforeSpike, config.acausalInteraction);
    designMatrix = [designMatrix currCouplingMatrix];
end

end