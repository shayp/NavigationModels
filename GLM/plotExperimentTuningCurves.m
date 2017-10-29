function plotExperimentTuningCurves(config, features, pos_curve, hd_curve, vel_curve, border_curve, neuronNumber)
% create x-axis vectors
hd_vector =  linspace(0, 2 * pi, config.numOfHeadDirectionParams);
velXAxis = linspace(-config.maxVelocityXAxis, config.maxVelocityXAxis, config.numOfVelocityAxisParams);
velYAxis = linspace(config.maxVelocityYAxis, -config.maxVelocityYAxis, config.numOfVelocityAxisParams);

posXAxes = linspace(0, config.boxSize(1), config.numOfPositionAxisParams);
posYAxes = linspace(config.boxSize(2),0, config.numOfPositionAxisParams);
% plot the tuning curves
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
subplot(2,2,1)
imagesc(posXAxes, fliplr(posYAxes), pos_curve); colorbar
%set(gca,'YTickLabel',{num2str(posYAxes)})
title('Experiment position curve')
xlabel('X Dim(cms)')
ylabel('Y Dim(cms)')
    
subplot(2,2,2)
plot(hd_vector,hd_curve,'k','linewidth',3)
box off
axis([0 2*pi -inf inf])
xlabel('direction angle')
ylabel('Spikes/s');
title('Experiment head direction curve')

subplot(2,2,3)
imagesc(velXAxis, fliplr(velYAxis), vel_curve); colorbar
%set(gca,'YTickLabel',{num2str(velYAxis)})
title('Experiment Velocity curve');
xlabel('dx/dt(cm/s)')
ylabel('dy/dt(cm/s)')


subplot(2,2,4)
plot(features.borderBins,border_curve,'k','linewidth',3)
box off
xlabel('distance from border(cm)')
ylabel('Spikes/s');
title('Experiment border curve')

savefig(['./Graphs/Neuron_' num2str(neuronNumber) 'expeimentCurves']);

drawnow;
end