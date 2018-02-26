function [learnedParams, fTheta] = getLearnedParameters(modelParams, modelType, config, kFoldParams, historyBaseVectors, numOfCoupledNeurons, couplingBaseVectors)

learnedParams.biasParam = modelParams(1);
numFolds = size(kFoldParams,1);
if config.fCoupling

    couplingParamsLength = config.numOfCouplingParams * numOfCoupledNeurons;
   
    % Set spike history filter
    learnedParams.spikeHistory = mean(historyBaseVectors * kFoldParams(:, 2:1 + config.numOfHistoryParams)', 2);
   
    if numOfCoupledNeurons > 0
        % Set coupling fiilters
        kFoldcouplingParams = reshape(kFoldParams(:,2 + config.numOfHistoryParams:couplingParamsLength + config.numOfHistoryParams + 1), numFolds, config.numOfCouplingParams, numOfCoupledNeurons);
        couplingParams = reshape(modelParams(2 + config.numOfHistoryParams:couplingParamsLength + config.numOfHistoryParams + 1), config.numOfCouplingParams, numOfCoupledNeurons);

        for i = 1:numOfCoupledNeurons
            learnedParams.couplingFilters(:,i) = mean(couplingBaseVectors * kFoldcouplingParams(:,:, i)', 2);
        end
    end
    
    % Set tuning params
    tuningParams = modelParams(2 + config.numOfHistoryParams + couplingParamsLength:end);
else
    % Set tuning params
    tuningParams = modelParams(2:end);
end
fTheta = 0;
learnedParams.allTuningParams = tuningParams;
% if sum(config.thetaMask & modelType) > 0
%     fTheta = 1;
%     learnedParams.thetaParam = tuningParams(end - config.numOfTheta + 1:end);
%     tuningParams = tuningParams(1:end - config.numOfTheta);
% end
learnedParams.tuningParams = tuningParams;
learnedParams.modelType = modelType;
end