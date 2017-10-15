%% Description
% This will plot the results of all the preceding analyses: the model
% performance, the model-derived tuning curves, and the firing rate tuning
% curves.

%% plot the tuning curves
% show parameters from the full model

% create x-axis vectors
hd_vector =  linspace(0, 2 * pi, n_dir_bins);
velXAxis = linspace(-Max_Speed_X, Max_Speed_X, n_vel_bins);
velYAxis = linspace(Max_Speed_Y, -Max_Speed_Y, n_vel_bins);

posXAxes = linspace(0, boxSize(1), n_pos_bins);
posYAxes = linspace(boxSize(2),0, n_pos_bins);
% plot the tuning curves
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
subplot(3,4,1)
imagesc(posXAxes, fliplr(posYAxes), pos_curve); colorbar
%set(gca,'YTickLabel',{num2str(posYAxes)})
title('Experiment position curve')
xlabel('X Dim(cms)')
ylabel('Y Dim(cms)')
    
subplot(3,4,2)
plot(hd_vector,hd_curve,'k','linewidth',3)
box off
axis([0 2*pi -inf inf])
xlabel('direction angle')
ylabel('Spikes/s');
title('Experiment head direction curve')

subplot(3,4,3)
imagesc(velXAxis, fliplr(velYAxis), vel_curve); colorbar
%set(gca,'YTickLabel',{num2str(velYAxis)})
title('Experiment Velocity curve');
xlabel('dx/dt(cm/s)')
ylabel('dy/dt(cm/s)')


subplot(3,4,4)
plot(borderBins,border_curve,'k','linewidth',3)
box off
xlabel('distance from border(cm)')
ylabel('Spikes/s');
title('Experiment border curve')
drawnow;
%% compute and plot the model-derived response profiles
param1_selected_model = param{top1};
[top1_varExplain, top1_correlation, top1_mse, smooth_fr_exp, top1_smooth_fr_sim] =  estimateModelPerformance(spiketrain, A{top1}, param1_selected_model, dt, filter);
[pos_param,hd_param, vel_param, border_param] = find_param(param1_selected_model,modelType{top1}, numPos, numHD, numVel, numBorder);
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
    subplot(4,4,5)
    imagesc(posXAxes, fliplr(posYAxes),reshape(pos_response,n_pos_bins,n_pos_bins)); axis on; colorbar;
    title('Learned position curve');
    %set(gca,'YTickLabel',{num2str(posYAxes)})
    xlabel('X Dim(cms)')
    ylabel('Y Dim(cms)')
end

if  numel(hd_param) == numHD
    scale_factor_hd =mean(exp(pos_param))*mean(exp(vel_param))*mean(exp(border_param))* sampleRate;
    hd_response = scale_factor_hd*exp(hd_param);
    subplot(4,4,6)
    plot(hd_vector,hd_response,'k','linewidth',3)
    title('Learned head direction curve');
    xlabel('angle')
    axis([0 2*pi -inf inf])

    box off
    xlabel('angle ')
    ylabel('Spikes/s');
end


if numel(vel_param) == numVel
    % compute the scale factors
    scale_factor_vel = mean(exp(pos_param))*mean(exp(hd_param))*mean(exp(border_param)) * sampleRate;

    % compute the model-derived response profiles
    vel_response = scale_factor_vel*exp(vel_param);
    subplot(4,4,7)
    imagesc(velXAxis, fliplr(velYAxis),reshape(vel_response,n_vel_bins,n_vel_bins)); axis on; colorbar;
    %set(gca,'YTickLabel',{num2str(velYAxis)})
    title('Learned velocity curve');
    xlabel('dx/dt(cm/s)')
    ylabel('dy/dt(cm/s)')
    box off
end

if numel(border_param) == numBorder
    % compute the scale factors
    scale_factor_Border = mean(exp(pos_param))*mean(exp(hd_param))*mean(exp(vel_param))* sampleRate;

    % compute the model-derived response profiles
    border_response = scale_factor_Border*exp(border_param);
    subplot(4,4,8)
    plot(borderBins,border_response,'k','linewidth',3)
    title('Learned border curve');
    xlabel('distance from border')
    ylabel('Spikes/s');
    box off
end


% ################# top 2 #################
param_selected_model = param{selected_model};
[top_varExplain, top_correlation, top_mse, smooth_fr_exp, top_smooth_fr_sim] =  estimateModelPerformance(spiketrain, A{selected_model}, param_selected_model, dt, filter);
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
    subplot(4,4,9)
    imagesc(posXAxes, fliplr(posYAxes),reshape(pos_response,n_pos_bins,n_pos_bins)); axis on; colorbar;
    title('Learned position curve');
    %set(gca,'YTickLabel',{num2str(posYAxes)})
    xlabel('X Dim(cms)')
    ylabel('Y Dim(cms)')
end

if  numel(hd_param) == numHD
    scale_factor_hd = mean(exp(pos_param))*mean(exp(vel_param))*mean(exp(border_param))* sampleRate;
    hd_response = scale_factor_hd*exp(hd_param);
    subplot(4,4,10)
    plot(hd_vector,hd_response,'k','linewidth',3)
    title('Learned head direction curve');
    xlabel('angle')
    axis([0 2*pi -inf inf])

    box off
    xlabel('angle ')
    ylabel('Spikes/s');
end


if numel(vel_param) == numVel
    % compute the scale factors
    scale_factor_vel = mean(exp(pos_param))*mean(exp(hd_param))*mean(exp(border_param)) * sampleRate;

    % compute the model-derived response profiles
    vel_response = scale_factor_vel*exp(vel_param);
    subplot(4,4,11)
    imagesc(velXAxis, fliplr(velYAxis),reshape(vel_response,n_vel_bins,n_vel_bins)); axis on; colorbar;
    %set(gca,'YTickLabel',{num2str(velYAxis)})
    title('Learned velocity curve');
    xlabel('dx/dt(cm/s)')
    ylabel('dy/dt(cm/s)')
    box off
end

if numel(border_param) == numBorder
    % compute the scale factors
    scale_factor_Border = mean(exp(pos_param))*mean(exp(hd_param))*mean(exp(vel_param))* sampleRate;

    % compute the model-derived response profiles
    border_response = scale_factor_Border*exp(border_param);
    subplot(4,4,12)
    plot(borderBins,border_response,'k','linewidth',3)
    title('Learned border curve');
    xlabel('distance from border')
    ylabel('Spikes/s');
    box off
end



minVel = 0;
% maxVelExp = max(max(vel_curve));
% maxVelSim = max(max(vel_response));
% subplot(4,4,3)
% caxis([minVel max(maxVelExp,maxVelSim)]);
% subplot(4,4,7)
% caxis([minVel max(maxVelExp,maxVelSim)]);
%% compute and plot the model performances
subplot(4,4,13:16)
timeBins = linspace(dt, length(smooth_fr_exp) * dt,length(smooth_fr_exp));
timeBins = timeBins / 60;
plot(timeBins, smooth_fr_exp, timeBins, top1_smooth_fr_sim, timeBins, top_smooth_fr_sim);
xlabel('time (minutes)')
ylabel('Spikes/s');
legend(['Experiment'],...
    ['One tuning curve ' ' , Explained variance: ' num2str(top1_varExplain * 100,2) '%, R: ' num2str(top1_correlation,2)],...
     ['Best explneation tuning curve' ' , Explained variance: ' num2str(top_varExplain * 100,2) '%, R: ' num2str(top_correlation,2)]);
drawnow;
if top_correlation >= 0.4 
savefig(['./Graphs/TuningCurve_sig_' num2str(neuronNumber)]);
else
    savefig(['./Graphs/TuningCurve_notSig_' num2str(neuronNumber)]);
end