%% Description
% This will plot the results of all the preceding analyses: the model
% performance, the model-derived tuning curves, and the firing rate tuning
% curves.

%% plot the tuning curves
% show parameters from the full model

% create x-axis vectors
hd_vector = 2*pi/n_dir_bins/2:2*pi/n_dir_bins:2*pi - 2*pi/n_dir_bins/2;
speed_vector = linspace(0, 40,length(speed_curve));
velx_vector = linspace(-40, 40, length(velx_curve));
% plot the tuning curves
figure();
subplot(3,5,1)
imagesc(pos_curve); colorbar
axis off
title('Position')
ylabel('Spikes/s');

subplot(3,5,2)
plot(hd_vector,hd_curve,'k','linewidth',3)
box off
axis([0 2*pi -inf inf])
xlabel('direction angle')
ylabel('Spikes/s');
title('Head direction')
subplot(3,5,3)
plot(speed_vector,speed_curve,'k','linewidth',3)
box off
xlabel('Running speed')
ylabel('Spikes/s');
axis([0 40 -inf inf])
title('Speed')
subplot(3,5,4)
plot(velx_vector,velx_curve,'k','linewidth',3)
box off
xlabel('Velocity (dv/dt)')
ylabel('Spikes/s');
title('Velocity')
subplot(3,5,5)

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
[pos_param,hd_param,speed_param, velx_param, border_param] = find_param(param_selected_model,modelType{selected_model}, numPos, numHD, numSpd, numVelX, numBorder);
% posNanInd =find(isnan(pos_param));
% pos_param(posNanInd) = -100;
% hdNanInd =find(isnan(hd_param));
% hd_param(hdNanInd) = -100;
% speedNanInd =find(isnan(speed_param));
% speed_param(speedNanInd) = -100;

if numel(pos_param) ~= numPos
    pos_param = 0;
end
if numel(hd_param) ~= numHD
    hd_param = 0;
end
if numel(speed_param) ~= numSpd
    speed_param = 0;
end
if numel(velx_param) ~= numVelX
    velx_param = 0;
end
if numel(border_param) ~= numBorder
    border_param = 0;
end
if numel(pos_param) == numPos
    scale_factor_pos = mean(exp(speed_param))*mean(exp(hd_param))*mean(exp(velx_param))*mean(exp(border_param))/ sampleRate;
    pos_response = scale_factor_pos*exp(pos_param);
    subplot(3,5,6)
    imagesc(reshape(pos_response,n_pos_bins,n_pos_bins)); axis on; colorbar;
end

if  numel(hd_param) == numHD
    scale_factor_hd = mean(exp(speed_param))*mean(exp(pos_param))*mean(exp(velx_param))*mean(exp(border_param))/ sampleRate;
    hd_response = scale_factor_hd*exp(hd_param);
    subplot(3,5,7)
    plot(hd_vector,hd_response,'k','linewidth',3)
    xlabel('direction angle')
    box off
    xlabel('angle ')
    ylabel('Spikes/s');
end

if numel(speed_param) == numSpd
    % compute the scale factors
    scale_factor_spd = mean(exp(pos_param))*mean(exp(hd_param))*mean(exp(velx_param))*mean(exp(border_param))/ sampleRate;

    % compute the model-derived response profiles
    speed_response = scale_factor_spd*exp(speed_param);
    subplot(3,5,8)
    plot(speed_vector,speed_response,'k','linewidth',3)
    xlabel('Running speed (cm/s)')
    ylabel('Spikes/s');
    box off
    xlim([0 limitSppedToPlot]);
end

if numel(velx_param) == numVelX
    % compute the scale factors
    scale_factor_velx = mean(exp(pos_param))*mean(exp(hd_param))*mean(exp(speed_param))*mean(exp(border_param))/ sampleRate;

    % compute the model-derived response profiles
    velx_response = scale_factor_velx*exp(velx_param);
    subplot(3,5,9)
    plot(velx_vector,velx_response,'k','linewidth',3)
    xlabel('Velocity')
    ylabel('Spikes/s');
    box off
end

if numel(border_param) == numBorder
    % compute the scale factors
    scale_factor_Border = mean(exp(pos_param))*mean(exp(hd_param))*mean(exp(speed_param))*mean(exp(velx_param))/ sampleRate;

    % compute the model-derived response profiles
    border_response = scale_factor_Border*exp(border_param);
    subplot(3,5,10)
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
subplot(3,5,11:15)

errorbar(LLH_increase_mean,LLH_increase_sem,'ok','linewidth',3)
hold on
 meanLL = zeros(32,1);
 meanLL = meanLL + median(LLH_increase_mean);
 plot(0.5:31.5,meanLL,'--b','linewidth',2)

if noModelSelected
    plot(selected_model,LLH_increase_mean(selected_model),'.g','markersize',25)
    legend('Model performance', 'Median','Selected model(Not signifcant)', 'Location','bestoutside')
else
    plot(selected_model,LLH_increase_mean(selected_model),'.r','markersize',25)
    legend('Model performance', 'Median','Selected model', 'Location','bestoutside')
end
hold off
box off
set(gca,'fontsize',10)
set(gca,'XLim',[0 32]); set(gca,'XTick',1:31)
set(gca,'XTickLabel',{'phsvb', 'phsv', 'phsb', 'phvb', 'psvb', 'hsvb', 'phs', 'phv', 'phb', 'psv','psb', 'pvb','hsv','hsb', 'hvb','svb','ph', 'ps', 'pv','pb','hs','hv', 'hb', 'sv', 'sb', 'vb','p','h','s','v','b'});
ylim([(median(LLH_increase_mean) - 3) (median(LLH_increase_mean) + 3)]);
%[varExplain, correlation, mse] 
title(['Neuron ' num2str(neuronNumber) ': Variance explained - ' num2str(varExplain * 100,2) '% R - ' num2str(correlation,2) ' mse - ' num2str(mse,3)]);
drawnow;

if noModelSelected
    savefig(['./Graphs/NotSig_TuningCurve_' num2str(neuronNumber)]);
else
    savefig(['./Graphs/Sig_TuningCurve_' num2str(neuronNumber)]);
end