addpath('General');
historyPeaks = [0.02 0.1];
b = 0.00001;
[~, ~, learningData.historyBaseVectors] = buildBaseVectorsForPostSpikeAndCoupling(4, 0.02, historyPeaks, b, 0);

figure();
plot(learningData.historyBaseVectors);
