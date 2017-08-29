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
param_selected_model = param{selected_model};
[varExplain, correlation, mse, smooth_fr_exp, smooth_fr_sim] =  estimateModelPerformance(spiketrain, A{selected_model}, param_selected_model, dt, filter);
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
subplot(3,4,9:12)
timeBins = linspace(dt, length(smooth_fr_exp) * dt,length(smooth_fr_exp));
plot(timeBins, smooth_fr_exp, timeBins, smooth_fr_sim);
xlabel('time(s)')
ylabel('Spikes/s');
legend('Experiment firing rate', 'GLM Firing rate');
title(['Neuron - ' num2str(neuronNumber) ' \{Num of spikes: ' num2str(sum(spiketrain))  ' , Variance explained: ' num2str(varExplain * 100,2) '%, R: ' num2str(correlation,2) ', mse: ' num2str(mse,3) '\}']);
drawnow;
if correlation >= 0.4 
savefig(['./Graphs/TuningCurve_sig_' num2str(neuronNumber)]);
else
    savefig(['./Graphs/TuningCurve_notSig_' num2str(neuronNumber)]);
end