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

mse_values = reshape(testFit_mat(:,4),numFolds,numModels);

% 
[~, selected_model] = min(nanmean(mse_values,1));

% % find the best single model
% singleModels = 12:15;
% [~,top1] = min(nanmean(mse_values(:,singleModels))); top1 = top1 + singleModels(1)-1;
% 
% % find the best double model that includes the single model
% if top1 == 12 % P -> PH, PV, PB
%     [~,top2] = min(nanmean(mse_values(:,[6 7 8])));
%     vec = [6 7 8]; top2 = vec(top2);
% elseif top1 == 13 % H -> PH, HV, HB
%     [~,top2] = min(nanmean(mse_values(:,[6 9 10])));
%     vec = [6 9 10]; top2 = vec(top2);
% elseif top1 == 14 % V -> PV, HV, VB
%     [~,top2] = min(nanmean(mse_values(:,[7 9 11])));
%     vec = [7 9 11]; top2 = vec(top2);
% elseif top1 == 15 % B -> PB, HB, VB
%     [~,top2] = min(nanmean(mse_values(:,[8 10 11])));
%     vec = [8 10 11]; top2 = vec(top2);
% end
% 
% if top2 == 6 % PH -> PHV, PHB
%     [~,top3] = min(nanmean(mse_values(:,[2 3])));
%     vec = [2 3]; top3 = vec(top3);
% elseif top2 == 7 % PV -> PHV,  PVB
%     [~,top3] = min(nanmean(mse_values(:,[2 4])));
%     vec = [2 4]; top3 = vec(top3);
% elseif top2 == 8 % PB -> PHB,  PVB
%     [~,top3] = min(nanmean(mse_values(:,[3 4])));
%     vec = [3 4]; top3 = vec(top3);
% elseif top2 == 9 % HV -> PHV,  HVB
%     [~,top3] = min(nanmean(mse_values(:,[2 5])));
%     vec = [2 5]; top3 = vec(top3);
% elseif top2 == 10 % HB -> PHB, HVB
%     [~,top3] = min(nanmean(mse_values(:,[3 5])));
%     vec = [3 5]; top3 = vec(top3);
% elseif top2 == 11 % VB -> PVB, HVB,
%     [~,top3] = min(nanmean(mse_values(:,[4 5])));
%     vec = [4 5]; top3 = vec(top3);
% end
% 
% top4 = 1;
% FVE1 = mse_values(:,top1);
% FVE2 = mse_values(:,top2);
% FVE3 = mse_values(:,top3);
% FVE4 = mse_values(:,top4);
% 
% [p_fve_12,~] = signrank(FVE2,FVE1,'tail','right');
% [p_fve_23,~] = signrank(FVE3,FVE2,'tail','right');
% [p_fve_34,~] = signrank(FVE4,FVE3,'tail','right');
% % p_llh_12
% % p_llh_23
% % p_llh_34
% if p_fve_12 < 0.05 % double model is sig. better
%     if p_fve_23 < 0.05  % triple model is sig. better
%         if p_fve_34 < 0.05
%             selected_model = top4;             
%         else
%             selected_model = top3;
%         end
%     else
%         selected_model = top2;
%     end
% else
%     selected_model = top1;
% end

% % re-set if selected model is not above baseline
% pval_baseline = signrank(mse_values(:,selected_model),[],'tail','right')
% noModelSelected = false;
% if pval_baseline > 0.1
%     arr = [top1 top2 top3 top4 top5];
%     [~, index] = min(nanmean(fve_values(:,arr)));
%     selected_model = arr(index);
%     fve_values(:,selected_model)
%     pval_baseline = signrank(fve_values(:,selected_model),[],'tail','right')
%     if pval_baseline > 0.1
%         noModelSelected = true;
%     end
% end
