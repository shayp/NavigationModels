function [response, lambdas] = simulateResponsePillow(stimulus, tuningCurves, learnedParams, fCoupling,  numOfCoupledNeurons, couplingData, dt, config, fTheta, thetaGrid,fPlot,realSpikes)

simulationLength = size(stimulus, 1);
response = zeros(simulationLength, 1);
lambdas = zeros(simulationLength, 1);
baseValue = zeros(simulationLength, 1);
historyValue = zeros(simulationLength, 1);
lambdas =  zeros(simulationLength, 1);
mixedStimulus = zeros(simulationLength, 1);
if fCoupling
    sumOfHistory = sum(learnedParams.spikeHistory);
end

nbinsPerEval = 1;

baseValue = stimulus * tuningCurves' + learnedParams.biasParam;

if fCoupling
    spikeHistoryFilterLength = length(learnedParams.spikeHistory);
    for j = 1:numOfCoupledNeurons
        coupledConv = conv2(couplingData.data(j).spiketrain, learnedParams.couplingFilters(:,j),'full');
        if config.acausalInteraction
        coupledConv = [coupledConv(config.timeBeforeSpike:end - length(learnedParams.couplingFilters(:,j)) + config.timeBeforeSpike)];
        else 
            coupledConv = [0; coupledConv(1:end - length(learnedParams.couplingFilters(:,j)))];
        end
        baseValue = baseValue + coupledConv;
    end
end

rprev = 0;
nsp =0;
tspnext = exprnd(1);
currentBin= 1;
spikeInd = 0;

while currentBin < simulationLength 
     if (fTheta && currentBin - spikeInd > config.isiToCount)
        baseValue(currentBin) =  baseValue(currentBin) + learnedParams.thetaParam * thetaGrid(currentBin,:)';
    end
    iinxt = currentBin:min(currentBin+nbinsPerEval-1,simulationLength);
    mixedStimulus(iinxt) = baseValue(iinxt) + historyValue(iinxt);
    rnxt=  exp(mixedStimulus(iinxt)) * dt; % Cond Intensity
    rnxt = min(1, rnxt);
    lambdas(iinxt) = rnxt;

    rrcum = lambdas(iinxt) + rprev;  % Cumulative intensity
    if (tspnext >= rrcum) % No spike in this window
            currentBin = iinxt(end)+1;
            rprev = rrcum;
    else % Spike!
        ispk =  iinxt(find(rrcum>=tspnext, 1, 'first'));
        nsp = nsp + 1;
        response(ispk) = 1;
        spikeInd = ispk;
        % Record this spike
        if fCoupling
            mxi = min(simulationLength, ispk+spikeHistoryFilterLength); % determine bins for adding h current
            iiPostSpk = ispk+1:mxi; % time bins affected by post-spike kernel
            if max(historyValue(iiPostSpk)) > 5
                historyValue(iiPostSpk) =  learnedParams.spikeHistory(1:length(iiPostSpk));
            else
                historyValue(iiPostSpk) = historyValue(iiPostSpk) + learnedParams.spikeHistory(1:length(iiPostSpk));
            end

        end
        tspnext = exprnd(1);  % draw next spike time
        rprev = 0; % reset integrated intensity
        currentBin = ispk+1;  % Move to next bin
        % --  Update # of samples per iter ---
        muISI = currentBin/nsp;
        %nbinsPerEval = max(3, round(1.5*muISI)); 
    end
end
if  fCoupling
    spikeInd = find(response);
    closeInd = find(diff(spikeInd) < 2);
    response(spikeInd(closeInd + 1)) = 0;
end
if fPlot
    figure();
    subplot(6,1,1);
    tmp = ones(sum(response), 1);
    tmp2 = ones(sum(realSpikes), 1);

    real = find(realSpikes);
    time = linspace(dt, simulationLength * dt, simulationLength);
    spiketimes = find(response);
    plot(spiketimes * dt + dt/2, tmp, '.k', real* dt, tmp2, '.r');
    title(['spike train, exp:  ' num2str(sum(realSpikes)) ' , sim:  ' num2str(sum(response))]);
    subplot(6,1,2);
    plot(time, baseValue,'-k', spiketimes * dt, baseValue(spiketimes), '.b',real * dt, baseValue(real), '.r');
    title('stimulus');
    subplot(6,1,3);
    plot(time, historyValue,'-k', spiketimes * dt, historyValue(spiketimes), '.b',real * dt, historyValue(real), '.r');
    title('spike history');

    subplot(6,1,4);
    plot(time, lambdas,'-k', spiketimes * dt, lambdas(spiketimes), '.b',real * dt, lambdas(real), '.r');
    title('lambda');
    subplot(6,1,5);
    plot(time, mixedStimulus,'-k', spiketimes * dt, mixedStimulus(spiketimes), '.b',real * dt, mixedStimulus(real), '.r');
    title('mixedStimulus');
    subplot(6,1,6);
    plot(time, cumsum(response),'-k', time , cumsum(realSpikes), '-r');
    title('Cumulative spikes');
    drawnow;
    %ylim([0 0.3]);
end
end


