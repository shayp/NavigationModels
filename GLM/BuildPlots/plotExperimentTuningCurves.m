function plotExperimentTuningCurves(config, features, pos_curve, hd_curve, speed_curve, speedHD_curve, neuronNumber, learningData, sessionName)
% create x-axis vectors
hd_vector =  linspace(0, 2 * pi, config.numOfHeadDirectionParams);
speedBins = linspace(0, config.maxSpeed, config.numOfSpeedBins);
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
spikedInd = find(learningData.spiketrain);
subplot(3,2,1);
plot(learningData.posx, learningData.posy,'-k', learningData.posx(spikedInd), learningData.posy(spikedInd), '.r');
axis square
title('trajectory');
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
plot(speedBins, speed_curve,'k','linewidth',3); 
axis square
box off;

title('Experiment speed curve');
xlabel('speed (cm/s)')
ylabel('Spikes/s');


subplot(3,2,5)
plot(features.speedHDBins,speedHD_curve,'k','linewidth',3)
box off
axis square
xlabel('direction speed (cm/s)')
ylabel('Spikes/s');
title('Experiment velocity curve')
mkdir(['./Graphs/' sessionName]);
savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) 'expeimentCurves']);

drawnow;
end