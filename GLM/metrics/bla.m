clear all;
addpath('General');
dt = 0.001;
[~, ~, couplingBaseVectors] = buildBaseVectorsForPostSpikeAndCoupling(15, 1/1000, [0.004 0.15], 0.02, 0.001);
%[~, ~, couplingBaseVectors] = buildBaseVectorsForPostSpikeAndCoupling(5, 1/1000, [0.001 0.03], 1, 0);

figure();
lenOfVec  = size(couplingBaseVectors,1);
time = linspace(dt, lenOfVec * dt, lenOfVec);
plot(time, couplingBaseVectors);
title('coupling base vectors');
xlabel('time (seconds)');

% 
% [~, ~, historygBaseVectors] = buildBaseVectorsForPostSpikeAndCoupling(20, 1/1000, [0.003 0.17],0.02, 0.002);
% figure();
% lenOfVec  = size(historygBaseVectors,1);
% time = linspace(dt, lenOfVec * dt, lenOfVec);
% plot(time, historygBaseVectors);
% title('History base vectors');
% xlabel('time (seconds)');

% files = dir('Graphs/11138-07040501/Neuron_*_history_Results_single.mat');
% numNeurons = length(files)
% dt = 1/1000;
% timehist = linspace(dt, 200 * dt, 200);
% hist = zeros(200,numNeurons);
% for i = 1:numNeurons
%     load(['Graphs/11138-07040501/Neuron_' num2str(i) '_history_Results_single.mat']);
%     hist(1:length(modelParams.spikeHistory),i) = modelParams.spikeHistory;
% end
% 
% figure();
% x = zeros(length(timehist),1);
% plot(timehist, exp(hist),timehist, exp(x), '--r', 'linewidth', 1);
% xlabel('time (sec)');
% ylim([0 6]);
% xlim([0 150 * dt]);
% secondSpiketrain = spiketrain;
% 
% corr2(firstSpiketrain, secondSpiketrain);
% windowsize = 40;
% dataLength = ceil(length(firstSpiketrain) / windowsize);
% data = zeros(dataLength, 2);
% for i = 1:dataLength - 1
%     data(i,1) = sum(firstSpiketrain(1 + windowsize * (i - 1): windowsize * i));
%     data(i,2) = sum(secondSpiketrain(1 + windowsize * (i - 1): windowsize * i));
% end

% data = data / windowsize;
% data(:,2) = 1 - data(:,2);
% [vecCorrelation, vecLegs] = xcorr(firstSpiketrain,secondSpiketrain);
% [~, index] = max(vecCorrelation);
% Leg =  vecLegs(index)
% %Leg = 3;
% pearson = corr(firstSpiketrain, circshift(secondSpiketrain,Leg),'type','Pearson')
% figure();
% dt = 1/1000;
% firstSpikeTimes = find(firstSpiketrain);
% firstSpikeOnes = ones(length(firstSpikeTimes), 1);
% secondSpikeTimes = find(secondSpiketrain);
% secondSpikeOnes = 1.1 * ones(length(secondSpikeTimes), 1);
% plot(dt *(firstSpikeTimes), firstSpikeOnes, '.b',dt * secondSpikeTimes , secondSpikeOnes,  '.g');
% legend('1','2');
% xlabel('time (sec)');
% ylim([0.9 1.2]);
% xlim([1 10]);