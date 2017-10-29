function [metrics, smoothPsthExp, smoothPsthSim, ISI] = ...
    estimateModelPerformance(dt,realFiringRate, modelFiringRate, smoothingFilter, windowSize)

simulationLength = length(realFiringRate)
simNumOfSpikes = sum(modelFiringRate)
expNumOfSpikes = sum(realFiringRate)

psthLength = ceil(simulationLength / windowSize);
psthSim = zeros(psthLength, 1);
psthExp = zeros(psthLength, 1);

% Bin the spike rate (PSTH)
for j = 1:psthLength
    currentChange = min(simulationLength, j * windowSize);
    psthSim(j) = sum(modelFiringRate((j-1) * windowSize + 1: currentChange));
    psthExp(j) = sum(realFiringRate((j-1) * windowSize + 1: currentChange));
end


% smooth firing rate
smoothPsthExp = conv(psthExp, smoothingFilter,'same');
smoothPsthSim = conv(psthSim, smoothingFilter,'same'); 

[vecCorrelation, vecLegs] = xcorr(smoothPsthExp,smoothPsthSim);
[~, index] = max(vecCorrelation);
Leg =  vecLegs(index)
corr(smoothPsthExp, circshift(smoothPsthSim,Leg),'type','Pearson')
% smoothPsthSim = circshift(smoothPsthSim,Leg);

% compare between test fr and model fr
sse = sum((smoothPsthSim - smoothPsthExp).^2);
sst = sum((smoothPsthExp - mean(smoothPsthExp)).^2);
metrics.varExplain = 1-(sse/sst);
metrics.correlation = corr(smoothPsthExp, smoothPsthSim,'type','Pearson');
metrics.mse = nanmean((smoothPsthSim - smoothPsthExp).^2);

expISI = diff(find(realFiringRate));

maxExpISI = max(expISI);
expISIPr = zeros(maxExpISI, 1);
for j = 1:maxExpISI
    expISIPr(j) = sum(expISI == j);
end
expISIPr = expISIPr / sum(expISIPr);
expISITimes = linspace(1 * dt, maxExpISI * dt, maxExpISI);

ISI.expISIPr = expISIPr;
ISI.expISITimes = expISITimes;
end