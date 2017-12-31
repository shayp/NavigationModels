function response = simulateResponsePillow(stimulus, tuningCurves, learnedParams, fCoupling,  numOfCoupledNeurons, couplingData, dt)

simulationLength = length(stimulus);
response = zeros(simulationLength, 1);
baseValue = zeros(simulationLength, 1);
historyValue = zeros(simulationLength, 1);
if fCoupling
    sumOfHistory = sum(learnedParams.spikeHistory);
end
nbinsPerEval = 2;  % Default number of bins to update for each spike

baseValue = stimulus * tuningCurves' + learnedParams.biasParam;

if fCoupling
    spikeHistoryFilterLength = length(learnedParams.spikeHistory);
    for j = 1:numOfCoupledNeurons
        baseValue = baseValue + conv(couplingData.data(j).spiketrain, learnedParams.couplingFilters(:,j), 'same');
    end
end

rprev = 0;
nsp =0;
tspnext = exprnd(1);
currentBin= 1;
while currentBin <= simulationLength
    iinxt = currentBin:min(currentBin+nbinsPerEval-1,simulationLength);
    rrnxt =  exp(baseValue(iinxt) + historyValue(iinxt)) * dt; % Cond Intensity

    rrcum = cumsum(rrnxt) + rprev;  % Cumulative intensity
    if (tspnext >= rrcum(end)) % No spike in this window
            currentBin = iinxt(end)+1;
            rprev = rrcum(end);
    else % Spike!
        ispk =  iinxt(find(rrcum>=tspnext, 1, 'first'));
        nsp = nsp + 1;
        response(ispk) = 1;
        % Record this spike
        if fCoupling
            mxi = min(simulationLength, ispk+spikeHistoryFilterLength); % determine bins for adding h current
            iiPostSpk = ispk+1:mxi; % time bins affected by post-spike kernel

            if ~isempty(iiPostSpk)
                if ((sumOfHistory > 0 && (sum(historyValue(iiPostSpk))  > 8 * sumOfHistory)) || ...
                    (sumOfHistory < 0 && (sum(historyValue(iiPostSpk))  < sumOfHistory / 8)))

                    historyValue(iiPostSpk) = learnedParams.spikeHistory(1:length(iiPostSpk));
                else
                    historyValue(iiPostSpk) = learnedParams.spikeHistory(1:length(iiPostSpk));
                    %historyValue(iiPostSpk) = historyValue(iiPostSpk) + learnedParams.spikeHistory(1:length(iiPostSpk));
                end
            end
        end
        tspnext = exprnd(1);  % draw next spike time
        rprev = 0; % reset integrated intensity
        currentBin = ispk+1;  % Move to next bin
        % --  Update # of samples per iter ---
        muISI = currentBin/nsp;
        nbinsPerEval = max(20, round(1.5*muISI)); 
    end
end

end


