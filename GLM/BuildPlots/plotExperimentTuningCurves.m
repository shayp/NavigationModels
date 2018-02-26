function plotExperimentTuningCurves(config, features, pos_curve, hd_curve, speed_curve, theta_curve, neuronNumber, learningData, sessionName, mean_fr)
% create x-axis vectors
hd_vector =  linspace(0, 2 * pi, config.numOfHeadDirectionParams);
speedBins = config.speedVec;
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
spikedInd = find(learningData.spiketrain);
subplot(3,2,1);
plot(learningData.posx, learningData.posy,'-k', learningData.posx(spikedInd), learningData.posy(spikedInd), '.r');
axis square
title(['trajectory - mean firing rate ' num2str(mean_fr) ' Hz']);
xlim([0 100]);
ylim([0 100]);

posXAxes = linspace(0, config.boxSize(1), config.numOfPositionAxisParams);
posYAxes = linspace(config.boxSize(2),0, config.numOfPositionAxisParams);
% plot the tuning curves
subplot(3,2,2)
imagesc(posXAxes, fliplr(posYAxes), pos_curve); colorbar
colormap jet;
axis square
box off;
%set(gca,'YTickLabel',{num2str(posYAxes)})
title('Experiment position curve')
xlabel('X Dim(cms)')
ylabel('Y Dim(cms)')
    
subplot(3,2,3)
polarplot([hd_vector hd_vector(1)],[hd_curve; hd_curve(1)],'k','linewidth',1)
title('Experiment head direction curve')

subplot(3,2,4)
size(speed_curve)
size(speedBins)
plot(speedBins, speed_curve,'k','linewidth',3); 
axis square
box off;

title('Experiment speed curve');
xlabel('speed (cm/s)')
ylabel('Spikes/s');


subplot(3,2,5)
polarplot([features.thetaVec features.thetaVec(1)],[theta_curve; theta_curve(1)],'k','linewidth',3)

title('Experiment theta curve')
mkdir(['./Graphs/' sessionName]);
savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) 'expeimentCurves']);

drawnow;
end