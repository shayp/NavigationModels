%% Description
% This will plot the results of all the preceding analyses: the model
% performance, the model-derived tuning curves, and the firing rate tuning
% curves.

%% plot the tuning curves
% show parameters from the full model

% create x-axis vectors
hd_vector =  linspace(0, 2 * pi, n_dir_bins);
velXAxis = linspace(-Max_Speed_X, Max_Speed_X, n_vel_bins);
velYAxis = linspace(Max_Speed_X, -Max_Speed_X, n_vel_bins);

posXAxes = linspace(0, boxSize(1), n_pos_bins);
posYAxes = linspace(boxSize(2),0, n_pos_bins);
% plot the tuning curves
figure();
subplot(3,4,1)
imagesc(posXAxes, fliplr(posYAxes), pos_curve); colorbar
%set(gca,'YTickLabel',{num2str(posYAxes)})
title('Position')
xlabel('X Dim(cms)')
ylabel('Y Dim(cms)')
    
subplot(3,4,2)
plot(hd_vector,hd_curve,'k','linewidth',3)
box off
axis([0 2*pi -inf inf])
xlabel('direction angle')
ylabel('Spikes/s');
title('Head direction')

subplot(3,4,3)
imagesc(velXAxis, fliplr(velYAxis), vel_curve); colorbar
%set(gca,'YTickLabel',{num2str(velYAxis)})

xlabel('dx/dt(cm/s)')
ylabel('dy/dt(cm/s)')

subplot(3,4,4)
plot(borderBins,border_curve,'k','linewidth',3)
box off
xlabel('Distance from border(cm)')
ylabel('Spikes/s');
title('Border tuning curve')
drawnow;
%% compute and plot the model-derived response profiles
if noModelSelected
    disp(' No model selected :0');
end

param_selected_model = param{selected_model};
[varExplain, correlation, mse] =  estimateModelPerformance(spiketrain, A{selected_model}, param_selected_model, dt, filter);
[pos_param,hd_param, vel_param, border_param] = find_param(param_selected_model,modelType{selected_model}, numPos, numHD, numVel, numBorder);
if numel(pos_param) ~= numPos
    pos_param = 0;
end
if numel(hd_param) ~= numHD
    hd_param = 0;
end
if numel(vel_param) ~= numVel
    vel_param = 0;
end
if numel(border_param) ~= numBorder
    border_param = 0;
end
if numel(pos_param) == numPos
    scale_factor_pos = mean(exp(hd_param))*mean(exp(vel_param))*mean(exp(border_param))* sampleRate;
    pos_response = scale_factor_pos*exp(pos_param);
    subplot(3,4,5)
    imagesc(posXAxes, fliplr(posYAxes),reshape(pos_response,n_pos_bins,n_pos_bins)); axis on; colorbar;
    %set(gca,'YTickLabel',{num2str(posYAxes)})
    xlabel('X Dim(cms)')
    ylabel('Y Dim(cms)')
end

if  numel(hd_param) == numHD
    scale_factor_hd =mean(exp(pos_param))*mean(exp(vel_param))*mean(exp(border_param))* sampleRate;
    hd_response = scale_factor_hd*exp(hd_param);
    subplot(3,4,6)
    plot(hd_vector,hd_response,'k','linewidth',3)
    xlabel('direction angle')
    box off
    xlabel('angle ')
    ylabel('Spikes/s');
end


if numel(vel_param) == numVel
    % compute the scale factors
    scale_factor_vel = mean(exp(pos_param))*mean(exp(hd_param))*mean(exp(border_param)) * sampleRate;

    % compute the model-derived response profiles
    vel_response = scale_factor_vel*exp(vel_param);
    subplot(3,4,7)
    imagesc(velXAxis, fliplr(velYAxis),reshape(vel_response,n_vel_bins,n_vel_bins)); axis on; colorbar;
    %set(gca,'YTickLabel',{num2str(velYAxis)})
    xlabel('dx/dt(cm/s)')
    ylabel('dy/dt(cm/s)')
    box off
end

if numel(border_param) == numBorder
    % compute the scale factors
    scale_factor_Border = mean(exp(pos_param))*mean(exp(hd_param))*mean(exp(vel_param))* sampleRate;

    % compute the model-derived response profiles
    border_response = scale_factor_Border*exp(border_param);
    subplot(3,4,8)
    plot(borderBins,border_response,'k','linewidth',3)
    xlabel('Distance from border')
    ylabel('Spikes/s');
    box off
end

%% compute and plot the model performances

% ordering:
% pos&hd&spd&theta / pos&hd&spd / pos&hd&th / pos&spd&th / hd&spd&th / pos&hd /
% pos&spd / pos&th/ hd&spd / hd&theta / spd&theta / pos / hd / speed/ theta
LLH_values = LLH_values(all(~isnan(LLH_values),2),:);
LLH_increase_mean = nanmean(LLH_values);
LLH_increase_sem = std(LLH_values)/sqrt(numFolds);
subplot(3,4,9:12)

errorbar(LLH_increase_mean,LLH_increase_sem,'ok','linewidth',3)
hold on
 meanLL = zeros(numModels + 1,1);
% meanLL = meanLL + median(LLH_increase_mean);
 plot(0.5:numModels + 0.5,meanLL,'--b','linewidth',2)

if noModelSelected
    plot(selected_model,LLH_increase_mean(selected_model),'.g','markersize',25)
    legend('Model performance', 'Baseline','Selected model(Not signifcant)', 'Location','bestoutside')
else
    plot(selected_model,LLH_increase_mean(selected_model),'.r','markersize',25)
    legend('Model performance', 'Baseline','Selected model', 'Location','bestoutside')
end
hold off
box off
set(gca,'fontsize',10)
set(gca,'XLim',[0 numModels + 1]); set(gca,'XTick',1:numModels)
set(gca,'XTickLabel',{'phvb', 'phv', 'phb', 'pvb', 'hvb','ph', 'pv','pb','hv', 'hb', 'vb','p','h','v','b'});
ylim([(median(LLH_increase_mean) - 3) (median(LLH_increase_mean) + 3)]);
%[varExplain, correlation, mse] 
title(['Neuron ' num2str(neuronNumber) ' - p value: ' num2str(pval_baseline,2) ' Variance explained: ' num2str(varExplain * 100,2) '% R: ' num2str(correlation,2) ' mse: ' num2str(mse,3)]);
drawnow;

savefig(['./Graphs/TuningCurve_' num2str(neuronNumber)]);
