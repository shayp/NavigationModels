function learnedParams = getLearnedParameters(modelParams, modelType, config, kFoldParams, historyBaseVectors, numOfCoupledNeurons,...
    couplingBaseVectors)

% Get bias param
learnedParams.biasParam = modelParams(1);

% Get num of folds
numFolds = size(kFoldParams,1);

% If we used history/coupling in learning mode, the parameters are combined
% in a different way
if config.fCoupling

    % Caclulate the number of coupling params(can be zero - only history)
    couplingParamsLength = config.numOfCouplingParams * numOfCoupledNeurons;
   
    % Set spike history filter by first getting a filter for each fold and
    % then calculating the mean
    learnedParams.spikeHistory = mean(historyBaseVectors * kFoldParams(:, 2:1 + config.numOfHistoryParams)', 2);
   
    % If we have coupling filters
    if numOfCoupledNeurons > 0

        % Reshape the k-fold coupling params to a shape
        % of K X paramsLength X numOfCoupledNeurons
        kFoldcouplingParams = reshape(kFoldParams(:,2 + config.numOfHistoryParams:couplingParamsLength + config.numOfHistoryParams + 1),...
            numFolds, config.numOfCouplingParams, numOfCoupledNeurons);
        
        % Run for each coupled neuron
        for i = 1:numOfCoupledNeurons
            
            % Get  k-folds coupling filter for the coupled neuron
            learnedParams.kFoldsCoupling = couplingBaseVectors * kFoldcouplingParams(:,:, i)';
            
            % Set coupling fiilters by first getting a filter for each fold and
            % then calculating the mean
            learnedParams.couplingFilters(:,i) = mean(couplingBaseVectors * kFoldcouplingParams(:,:, i)', 2);
        end
    end
    
    % Set stimulus params
    stimulusParams = modelParams(2 + config.numOfHistoryParams + couplingParamsLength:end);
else
    % Set stimulus params
    stimulusParams = modelParams(2:end);
end

% Set learned params 
learnedParams.allTuningParams = stimulusParams;
learnedParams.tuningParams = stimulusParams;
learnedParams.modelType = modelType;
end