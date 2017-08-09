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


testFit_mat = cell2mat(testFit);

LLH_values = reshape(testFit_mat(:,3),numFolds,numModels);



% find the best single model
singleModels = 27:31;
[~,top1] = max(nanmean(LLH_values(:,singleModels))); top1 = top1 + singleModels(1)-1;

% find the best double model that includes the single model
if top1 == 27 % P -> PH, PS, PV, PB
    [~,top2] = max(nanmean(LLH_values(:,[17 18 19 20])));
    vec = [17 18 19 20]; top2 = vec(top2);
elseif top1 == 28 % H -> PH, HS, HV, HB
    [~,top2] = max(nanmean(LLH_values(:,[17 21 22 23])));
    vec = [17 21 22 23]; top2 = vec(top2);
elseif top1 == 29 % S -> PS, HS, SV, SB
    [~,top2] = max(nanmean(LLH_values(:,[18 21 24 25])));
    vec = [18 21 24 25]; top2 = vec(top2);
elseif top1 == 30 % V -> PV, HV, SV, VB
    [~,top2] = max(nanmean(LLH_values(:,[19 22 24 26])));
    vec = [19 22 24 26]; top2 = vec(top2);
elseif top1 == 31 % B -> PB, HB, SB, VB
    [~,top2] = max(nanmean(LLH_values(:,[20 23 25 26])));
    vec = [20 23 25 26]; top2 = vec(top2);
end

if top2 == 17 % PH -> PHS, PHV, PHB
    [~,top3] = max(nanmean(LLH_values(:,[7 8 9])));
    vec = [7 8 9]; top3 = vec(top3);
elseif top2 == 18 % PS -> PHS, PSV, PSB
    [~,top3] = max(nanmean(LLH_values(:,[7 10 11])));
    vec = [7 10 11]; top3 = vec(top3);
elseif top2 == 19 % PV -> PHV, PSV, PVB
    [~,top3] = max(nanmean(LLH_values(:,[8 10 12])));
    vec = [8 10 12]; top3 = vec(top3);
elseif top2 == 20 % PB -> PHB, PSB, PVB
    [~,top3] = max(nanmean(LLH_values(:,[9 11 12])));
    vec = [9 11 12]; top3 = vec(top3);
elseif top2 == 21 % HS -> PHS, HSV, HSB
    [~,top3] = max(nanmean(LLH_values(:,[7 13 14])));
    vec = [7 13 14]; top3 = vec(top3);
elseif top2 == 22 % HV -> PHV, HSV, HVB
    [~,top3] = max(nanmean(LLH_values(:,[8 13 15])));
    vec = [8 13 15]; top3 = vec(top3);
elseif top2 == 23 % HB -> PHB, HSB, HVB
    [~,top3] = max(nanmean(LLH_values(:,[9 14 15])));
    vec = [9 14 15]; top3 = vec(top3);
elseif top2 == 24 % SV -> PSV, HSV, SVB
    [~,top3] = max(nanmean(LLH_values(:,[10 13 16])));
    vec = [10 13 16]; top3 = vec(top3);
elseif top2 == 25 % SB -> PSB, HSB, SVB
    [~,top3] = max(nanmean(LLH_values(:,[11 14 16])));
    vec = [11 14 16]; top3 = vec(top3);
elseif top2 == 26 % VB -> PVB, HVB, SVB
    [~,top3] = max(nanmean(LLH_values(:,[12 15 16])));
    vec = [12 15 16]; top3 = vec(top3);
end

if top3 == 7 % PHS -> PHSV, PHSB
    [~,top4] = max(nanmean(LLH_values(:,[2 3])));
    vec = [2 3]; top4 = vec(top4);
elseif top3 == 8 % PHV -> PHSV, PHVB
    [~,top4] = max(nanmean(LLH_values(:,[2 4])));
    vec = [2 4]; top4 = vec(top4);
elseif top3 == 9 % PHB -> PHSB, PHVB
    [~,top4] = max(nanmean(LLH_values(:,[3 4])));
    vec = [3 4]; top4 = vec(top4);
elseif top3 == 10 % PSV -> PHSV, PSVB
    [~,top4] = max(nanmean(LLH_values(:,[2 5])));
    vec = [2 5]; top4 = vec(top4);
elseif top3 == 11 % PSB -> PHSB, PSVB
    [~,top4] = max(nanmean(LLH_values(:,[3 5])));
    vec = [3 5]; top4 = vec(top4);
elseif top3 == 12 % PVB -> PHVB, PSVB
    [~,top4] = max(nanmean(LLH_values(:,[4 5])));
    vec = [4 5]; top4 = vec(top4);
elseif top3 == 13 % HSV -> PHSV, HSVB
    [~,top4] = max(nanmean(LLH_values(:,[2 6])));
    vec = [2 6]; top4 = vec(top4);
elseif top3 == 14 % HSB -> PHSB, HSVB
    [~,top4] = max(nanmean(LLH_values(:,[3 6])));
    vec = [3 6]; top4 = vec(top4);
elseif top3 == 15 % HVB -> PHVB, HSVB
    [~,top4] = max(nanmean(LLH_values(:,[4 6])));
    vec = [4 6]; top4 = vec(top4);
elseif top3 == 16 % SVB -> PSVB, HSVB
    [~,top4] = max(nanmean(LLH_values(:,[5 6])));
    vec = [5 6]; top4 = vec(top4);
end


top5 = 1;
LLH1 = LLH_values(:,top1);
LLH2 = LLH_values(:,top2);
LLH3 = LLH_values(:,top3);
LLH4 = LLH_values(:,top4);
LLH5 = LLH_values(:,top5);

[p_llh_12,~] = signrank(LLH2,LLH1,'tail','right');
[p_llh_23,~] = signrank(LLH3,LLH2,'tail','right');
[p_llh_34,~] = signrank(LLH4,LLH3,'tail','right');
[p_llh_45,~] = signrank(LLH5,LLH4,'tail','right');

if p_llh_12 < 0.05 % double model is sig. better
    if p_llh_23 < 0.05  % triple model is sig. better
        if p_llh_34 < 0.05
            if p_llh_45 < 0.05
                selected_model = top5;             
            else
                selected_model = top4;
            end
        else
            selected_model = top3;
        end
    else
        selected_model = top2;
    end
else
    selected_model = top1;
end


% re-set if selected model is not above baseline
% pval_baseline = signrank(LLH_values(:,selected_model),[],'tail','right')
noModelSelected = false;
% if pval_baseline > 0.1
%     arr = [top1 top2 top3 top4 top5];
%     [~, index] = max(nanmean(LLH_values(:,arr)));
%     selected_model = arr(index);
%     LLH_values(:,selected_model)
%     pval_baseline = signrank(LLH_values(:,selected_model),[],'tail','right')
%     if pval_baseline > 0.1
%         noModelSelected = true;
%     end
% end
