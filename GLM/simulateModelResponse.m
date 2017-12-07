function firingRate = simulateModelResponse(stimulus, tuningCurves, learnedParams, fCoupling,  numOfCoupledNeurons, couplingData, dt)
simulationLength = size(stimulus, 1);
historyValue = zeros(simulationLength, 1);
firingRate = zeros(simulationLength, 1);
lambdas = zeros(simulationLength, 1);
baseValue = stimulus * tuningCurves' + learnedParams.biasParam;

if fCoupling
    spikeHistoryFilterLength = length(learnedParams.spikeHistory);
    for j = 1:numOfCoupledNeurons
        baseValue = baseValue + conv(couplingData.data(j).spiketrain, learnedParams.couplingFilters(:,j), 'same');
    end
end

for i = 1:simulationLength - 1
    curentLambda = exp(baseValue(i) + historyValue(i)) * dt;
    lambdas(i) = curentLambda;
    sample = poissrnd(curentLambda, 1, 1);
    if sample > 0
        firingRate(i) = sample;
        if fCoupling
            nextStep = min(spikeHistoryFilterLength, simulationLength - i - 1);
            if max(historyValue(i + 1:i+ nextStep)) > 7
                historyValue(i + 1:i+ nextStep) = learnedParams.spikeHistory(1:nextStep);
                i
            else
                historyValue(i + 1:i+ nextStep) = historyValue(i + 1:i+ nextStep) + learnedParams.spikeHistory(1:nextStep);
            end
        end
    end
end

numOfSpikes = sum(firingRate);
% figure();
% subplot(2,1,1);
% hist(lambdas);
% subplot(2,1,2);
% hist(baseValue);

end