function [top1, selectedModel, scores] = selectBestModelBySimulation(modelInd, modelTypes, modelParams, numOfRepeats, config, historyBaseVectors, simFeatures, simspiketrain,kFoldParams, numOfCoupledNeurons,couplingBaseVectors, couplingData)

scores = nan(numOfRepeats, config.numModels);
mean_fr = nanmean(simspiketrain);
validationLength = length(simspiketrain);
foldLength = ceil(validationLength / numOfRepeats);
for i = modelInd
    'current model '
    i
    modelParam = modelParams{i};
    modelType = modelTypes{i};
    kfoldParam = kFoldParams{i};
    [learnedParam, fTheta] = getLearnedParameters(modelParam, modelType, config, kfoldParam, historyBaseVectors,...
        numOfCoupledNeurons, couplingBaseVectors);
    stimulus = getStimulusByModelNumber(i, simFeatures.posgrid, simFeatures.hdgrid,...
        simFeatures.speedgrid, simFeatures.thetaGrid);

    for j = 1:numOfRepeats
        cuurStep = min(j * foldLength,validationLength);
        currspiketrain = simspiketrain((j-1) * foldLength + 1:cuurStep,:);
        mean_fr = nanmean(currspiketrain);
        log_llh_mean = nansum(mean_fr - currspiketrain .* log(mean_fr) + log(factorial(currspiketrain))) / sum(currspiketrain);
        currStimulus = stimulus((j-1) * foldLength + 1:cuurStep,:);
        currThetaGrid = simFeatures.thetaGrid((j-1) * foldLength + 1:cuurStep,:);
        currCoupling = couplingData;
        for k = 1:numOfCoupledNeurons
            currCoupling.data(k).spiketrain = currCoupling.data(k).spiketrain((j-1) * foldLength + 1:cuurStep);
        end
        [~, modelLambdas] = simulateResponsePillow(currStimulus, learnedParam.tuningParams, learnedParam, config.fCoupling, numOfCoupledNeurons, currCoupling, config.dt, config, fTheta, currThetaGrid,0, []);   
        log_llh_model = nansum(modelLambdas - currspiketrain.*log(modelLambdas) + log(factorial(currspiketrain))) / sum(currspiketrain);
        log_llh = log(2) * (-log_llh_model + log_llh_mean);
        scores(j,i) = log_llh;
    end
end


% % find the best single model
singleModels = 12:15;
[max1, top1] = max(nanmean(scores(:,singleModels))); top1 = top1 + singleModels(1)-1;
scores
% 
% find the best double model that includes the single model
 if top1 == 12 % P -> PH, PV, PB
     [~,top2] = max(nanmean(scores(:,[6 7 8])));
     vec = [6 7 8]; top2 = vec(top2);
 elseif top1 == 13 % H -> PH, HV, HB
     [~,top2] = max(nanmean(scores(:,[6 9 10])));
     vec = [6 9 10]; top2 = vec(top2);
 elseif top1 == 14 % V -> PV, HV, VB
     [~,top2] = max(nanmean(scores(:,[7 9 11])));
     vec = [7 9 11]; top2 = vec(top2);
 elseif top1 == 15 % B -> PB, HB, VB
     [~,top2] = max(nanmean(scores(:,[8 10 11])));
     vec = [8 10 11]; top2 = vec(top2);
end
 
if top2 == 6 % PH -> PHV, PHB
     [~,top3] = max(nanmean(scores(:,[2 3])));
     vec = [2 3]; top3 = vec(top3);
 elseif top2 == 7 % PV -> PHV,  PVB
     [~,top3] = max(nanmean(scores(:,[2 4])));
     vec = [2 4]; top3 = vec(top3);
 elseif top2 == 8 % PB -> PHB,  PVB
     [~,top3] = max(nanmean(scores(:,[3 4])));
     vec = [3 4]; top3 = vec(top3);
 elseif top2 == 9 % HV -> PHV,  HVB
     [~,top3] = max(nanmean(scores(:,[2 5])));
     vec = [2 5]; top3 = vec(top3);
 elseif top2 == 10 % HB -> PHB, HVB
     [~,top3] = max(nanmean(scores(:,[3 5])));
     vec = [3 5]; top3 = vec(top3);
 elseif top2 == 11 % VB -> PVB, HVB,
     [~,top3] = max(nanmean(scores(:,[4 5])));
     vec = [4 5]; top3 = vec(top3);
end
%  
 top4 = 1;
 scores(isnan(scores)) = -1;

LL1 = scores(:,top1);
LL2 = scores(:,top2);
LL3 = scores(:,top3);
LL4 = scores(:,top4);


 [p_LL_12,~] = signrank(LL2,LL1,'tail','right');
 p_LL_12
 [p_LL_23,~] = signrank(LL3,LL2,'tail','right');
 p_LL_23
 [p_LL_34,~] = signrank(LL4,LL3,'tail','right');
p_LL_34
if p_LL_12 < 0.1 % double model is sig. better
    if p_LL_23 < 0.1  % triple model is sig. better
        if p_LL_34 < 0.1
            selectedModel = top4;
        else
            selectedModel = top3;
        end
    else
        selectedModel = top2;
    end
else
    selectedModel = top1;
end
%[maxGlobal, selectedModel] = max(nanmean(scores,1));

end
