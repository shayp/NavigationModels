function [firingRate] = simulateCoupledNetworkResponse(neuronParams,  dt, simulationLength, thetaGrid, isiToCount)

history1Len = length(neuronParams(1).history);
history2Len = length(neuronParams(2).history);

coupling1Len = length(neuronParams(1).couplingFilter);
coupling2Len = length(neuronParams(2).couplingFilter);

baseValue = zeros(simulationLength,2);
lambdas = zeros(simulationLength,2);
historyValue = zeros(simulationLength,2);

firingRate = zeros(simulationLength,2);

baseValue(:,1) = baseValue(:,1) + neuronParams(1).stimulus * neuronParams(1).tuningParams' + neuronParams(1).bias;
baseValue(:,2) = baseValue(:,2) + neuronParams(2).stimulus * neuronParams(2).tuningParams' + neuronParams(2).bias;

spikeInd1 = 0;
spikeInd2 = 0;
tspnext1 = exprnd(1);
tspnext2 = exprnd(1);
rprev1 = 0;
rprev2 = 0;
nCount1 = 0;

for i  = 1:simulationLength - 1
    if (neuronParams(1).fTheta && (i - spikeInd1 > isiToCount))
        baseValue(i,1) =  baseValue(i,1) + neuronParams(1).thetaParam * thetaGrid(i,:)';
    end
    
    if (neuronParams(2).fTheta && (i - spikeInd2 > isiToCount))
        baseValue(i,2) =  baseValue(i,2) + neuronParams(2).thetaParam * thetaGrid(i,:)';
    end
    
    curentLambda1 = min(1,exp(baseValue(i,1) + historyValue(i,1)) * dt);
    curentLambda2 = min(1,exp(baseValue(i,2)+ historyValue(i,2)) * dt);

    lambdas(i,1) = curentLambda1;
    lambdas(i,2) = curentLambda2;

%     
    rrcum1 = curentLambda1 + rprev1;  % Cumulative intensity
    rrcum2 = curentLambda2 + rprev2;  % Cumulative intensity
    if (tspnext1 >= rrcum1) % No spike in this window
        rprev1 = rrcum1;
    else
        tspnext1 = exprnd(1);
        firingRate(i,1) = 1;
        rprev1 = 0;
        spikeInd1 = i;
        nextStep = min(history1Len, simulationLength - i - 1);
        if max(historyValue(i + 1:i + nextStep,1)) < 5
            historyValue(i + 1:i + nextStep,1) = historyValue(i + 1:i + nextStep,1) + neuronParams(1).history(1:nextStep);
        else
            historyValue(i + 1:i + nextStep,1) =  neuronParams(1).history(1:nextStep);
        end
    end
    
    if (tspnext2 >= rrcum2) % No spike in this window
        rprev2 = rrcum2;
    else
        tspnext2 = exprnd(1);
        spikeInd2 = i;
        rprev2 = 0;
        firingRate(i,2) = 1;
        
        nextStep = min(history2Len, simulationLength - i - 1);
        if max(historyValue(i + 1:i + nextStep,2)) < 5
            historyValue(i + 1:i + nextStep,2) = historyValue(i + 1:i + nextStep,2) + neuronParams(2).history(1:nextStep);
        else
            historyValue(i + 1:i + nextStep,2) = neuronParams(2).history(1:nextStep);
        end
    end
    
    if spikeInd1 == i
        nextStep = min(coupling2Len, simulationLength - i - 1);
        historyValue(i + 1:i + nextStep,2) = historyValue(i + 1:i + nextStep,2) + neuronParams(2).couplingFilter(1:nextStep);
    end
    
    if spikeInd2 == i
        nextStep = min(coupling1Len, simulationLength - i - 1);
        historyValue(i + 1:i + nextStep,1) = historyValue(i + 1:i + nextStep,1) + neuronParams(1).couplingFilter(1:nextStep);
    end
end
for i = 1:2
    spikeInd = find(firingRate(:,i));
    closeInd = find(diff(spikeInd) < 2);
    firingRate(spikeInd(closeInd + 1),i) = 0;
end
time = linspace(dt, simulationLength * dt, simulationLength);
spikeT2 = find(firingRate(:,2));
spikeT1Rea2 = find(neuronParams(2).spiketrain);

% figure();
% subplot(4,1,1);
% tmp1 = ones(length(spikeT2),1);
% tmp2 = ones(length(spikeT1Rea2),1);
% plot(time, lambdas(:,2), spikeT2* dt, lambdas(spikeT2,2), '.b', spikeT1Rea2* dt, lambdas(spikeT1Rea2,2), '.r');
% title('lambda');
% subplot(4,1,2);
% plot(time, baseValue(:,2),  spikeT2* dt, baseValue(spikeT2,2), '.b', spikeT1Rea2* dt, baseValue(spikeT1Rea2, 2), '.r');
% title('stimulus');
% subplot(4,1,3);
% plot(time, historyValue(:,2), spikeT2* dt, historyValue(spikeT2,2), '.b', spikeT1Rea2* dt, historyValue(spikeT1Rea2,2), '.r');
% title('history');
% subplot(4,1,4);
% plot(time, cumsum(firingRate(:,2))/sum(firingRate(:,2)) ,'-k',time, cumsum(neuronParams(2).spiketrain)/sum(neuronParams(2).spiketrain), '-r');
% title('cumultive firing rate');

end