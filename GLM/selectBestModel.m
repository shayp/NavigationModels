%% Description
% This code will implement forward feature selection in order to determine
% the simplest model that best describes neural spiking. First, the
% highest-performing single-variable model is identified. Then, the
% highest-perfmoring double-variable model that includes the
% single-variable model is identified. This continues until the full model
% is identified. Next, statistical tests are applied to see if including
% extra variables significantly improves model performance. The first time
% that including variable does NOT signficantly improve performance, the
% procedure is stopped and the model at that point is recorded as the
% selected model.

% the model indexing scheme:
% phs, ph, ps, hs, p,  h,  s
% 1      2    3    4    5    6  7   8   9   10  11  12  13  14  15
function [top1, selectedModel] = selectBestModel(testFit,numFolds, numModels)

testFit_mat = cell2mat(testFit);

LL_values = reshape(testFit_mat(:,3),numFolds,numModels);
% 
[maxGlobal, selectedModel] = max(nanmean(LL_values,1));

% % find the best single model
singleModels = 12:15;
[max1, top1] = max(nanmean(LL_values(:,singleModels))); top1 = top1 + singleModels(1)-1;
max1
% 
% find the best double model that includes the single model
 if top1 == 12 % P -> PH, PV, PB
     [~,top2] = max(nanmean(LL_values(:,[6 7 8])));
     vec = [6 7 8]; top2 = vec(top2);
 elseif top1 == 13 % H -> PH, HV, HB
     [~,top2] = max(nanmean(LL_values(:,[6 9 10])));
     vec = [6 9 10]; top2 = vec(top2);
 elseif top1 == 14 % V -> PV, HV, VB
     [~,top2] = max(nanmean(LL_values(:,[7 9 11])));
     vec = [7 9 11]; top2 = vec(top2);
 elseif top1 == 15 % B -> PB, HB, VB
     [~,top2] = max(nanmean(LL_values(:,[8 10 11])));
     vec = [8 10 11]; top2 = vec(top2);
end
 
if top2 == 6 % PH -> PHV, PHB
     [~,top3] = max(nanmean(LL_values(:,[2 3])));
     vec = [2 3]; top3 = vec(top3);
 elseif top2 == 7 % PV -> PHV,  PVB
     [~,top3] = max(nanmean(LL_values(:,[2 4])));
     vec = [2 4]; top3 = vec(top3);
 elseif top2 == 8 % PB -> PHB,  PVB
     [~,top3] = max(nanmean(LL_values(:,[3 4])));
     vec = [3 4]; top3 = vec(top3);
 elseif top2 == 9 % HV -> PHV,  HVB
     [~,top3] = max(nanmean(LL_values(:,[2 5])));
     vec = [2 5]; top3 = vec(top3);
 elseif top2 == 10 % HB -> PHB, HVB
     [~,top3] = max(nanmean(LL_values(:,[3 5])));
     vec = [3 5]; top3 = vec(top3);
 elseif top2 == 11 % VB -> PVB, HVB,
     [~,top3] = max(nanmean(LL_values(:,[4 5])));
     vec = [4 5]; top3 = vec(top3);
end
%  
 top4 = 1;
 LL_values(isnan(LL_values)) = -10;

LL1 = LL_values(:,top1);
LL2 = LL_values(:,top2);
LL3 = LL_values(:,top3);
LL4 = LL_values(:,top4);


 [p_LL_12,~] = signrank(LL2,LL1,'tail','right');
 [p_LL_23,~] = signrank(LL3,LL2,'tail','right');
 [p_LL_34,~] = signrank(LL4,LL3,'tail','right');

if p_LL_12 < 0.05 % double model is sig. better
    if p_LL_23 < 0.05  % triple model is sig. better
        if p_LL_34 < 0.05
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
[maxGlobal, selectedModel] = max(nanmean(LL_values,1));

end
