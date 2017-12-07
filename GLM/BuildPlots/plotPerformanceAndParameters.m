%% Description
% This will plot the results of all the preceding analyses: the model
% performance, the model-derived tuning curves, and the firing rate tuning
% curves.
function plotPerformanceAndParameters(config, modelParams, modelMetrics, expFiringRate, ...
    simFiringRate, neuronNumber, titleEnd, numOfCoupledNeurons, ISI,expISI,  sessionName, modelFiringRate, validationData, coupledNeurons)

currentIndex = 0;
numOfRows = ceil(modelParams.numOfFilters / 2);

hd_vector =  linspace(0, 2 * pi, config.numOfHeadDirectionParams);
speedBins = linspace(0, config.maxSpeed, config.numOfSpeedBins);

posXAxes = linspace(0, config.boxSize(1), config.numOfPositionAxisParams);
posYAxes = linspace(config.boxSize(2),0, config.numOfPositionAxisParams);
speedHDBins = linspace(0, config.maxSpeed, config.numOfHDSpeedBins);
figure();
if numel(modelParams.pos_param) == config.numOfPositionParams
    currentIndex = currentIndex + 1;
    scale_factor_pos = exp(modelParams.biasParam)*mean(exp(modelParams.hd_param))*mean(exp(modelParams.speed_param))*mean(exp(modelParams.speed_param));
    pos_response = scale_factor_pos*exp(modelParams.pos_param);
    subplot(numOfRows,2,currentIndex)
    imagesc(posXAxes, fliplr(posYAxes),reshape(pos_response,config.numOfPositionAxisParams,config.numOfPositionAxisParams)); colorbar;
    axis square
    colormap jet;
    title('Learned position curve');
    xlabel('X Dim(cms)')
    ylabel('Y Dim(cms)')
end

if  numel(modelParams.hd_param) == config.numOfHeadDirectionParams
    currentIndex = currentIndex + 1;
    scale_factor_hd = exp(modelParams.biasParam)*mean(exp(modelParams.pos_param))*mean(exp(modelParams.speed_param))*mean(exp(modelParams.speed_param));
    hd_response = scale_factor_hd * exp(modelParams.hd_param);
    subplot(numOfRows,2,currentIndex)
    plot(hd_vector,hd_response,'k','linewidth',3)
    title('Learned head direction curve');
    xlabel('angle')
    axis square
    axis([0 2*pi -inf inf])
    box off
    xlabel('angle ')
    ylabel('Spikes/s');
end


if numel(modelParams.speed_param) == config.numOfSpeedBins
    currentIndex = currentIndex + 1;
    % compute the scale factors
    scale_factor_speed = exp(modelParams.biasParam)*mean(exp(modelParams.pos_param))*mean(exp(modelParams.hd_param))*mean(exp(modelParams.speed_param));

    % compute the model-derived response profiles
    speed_response = scale_factor_speed*exp(modelParams.speed_param);
    subplot(numOfRows,2,currentIndex)
    plot(speedBins, speed_response);
    axis square
    title('Learned speed curve');
    xlabel('speed (cm/s)')
    ylabel('spikes/s')
    box off
end

if numel(modelParams.speedHD_param) == config.numOfHDSpeedBins
    currentIndex = currentIndex + 1;
    % compute the scale factors
    scale_factor_speedHD = exp(modelParams.biasParam)*mean(exp(modelParams.pos_param))*mean(exp(modelParams.hd_param))*mean(exp(modelParams.speed_param));

    % compute the model-derived response profiles
    speedHD_response = scale_factor_speedHD*exp(modelParams.speedHD_param);
    subplot(numOfRows,2,currentIndex)
    plot(speedHDBins,speedHD_response,'k','linewidth',3)
    title('Learned velocity curve');
    xlabel('direction speed (cm/s)')
    ylabel('Spikes/s');
    box off
    axis square
end

if config.fCoupling == 1
    if numOfCoupledNeurons > 0
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_Coupled_ParametersLearned_' titleEnd]);
    else
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_history_ParametersLearned_' titleEnd]);
    end
else
    savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_NoHistory_ParametersLearned_' titleEnd]);
end

if config.fCoupling
    numOfPlots = numOfCoupledNeurons + 1;
    figure();
    currentIndex =  1;
    historyLen = length(modelParams.spikeHistory);
    timeSeriesHistory = linspace(1 * config.dt, historyLen * config.dt, historyLen);
    subplot(ceil(numOfPlots / 2) ,2,currentIndex)
    plot(timeSeriesHistory, exp(modelParams.spikeHistory));
    title('Spike history filter');
    xlabel('time (seconds)')
    ylabel('Intensity');
    for j = 1:numOfCoupledNeurons
        currentIndex = currentIndex + 1;
        subplot(ceil(numOfPlots / 2) ,2,currentIndex)
        couplingLen = length(modelParams.couplingFilters(:,j));
        timeSeriesCoupling = linspace(1 * config.dt, couplingLen * config.dt, couplingLen);
        plot(timeSeriesCoupling, exp(modelParams.couplingFilters(:,j)));
        title(['Coupling filter - Neuron ' num2str(coupledNeurons(j))]);
        xlabel('time (seconds)')
        ylabel('Intensity');
    end
    
    if numOfCoupledNeurons > 0
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_Coupled_interactionLearned_' titleEnd]);
    else
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_history_interactionLearned_' titleEnd]);
    end

end

%% compute and plot the model performances
figure();
subplot(2,1,1);
timeBins = linspace(config.psthdt, length(expFiringRate) * config.psthdt,length(expFiringRate));
plot(timeBins, expFiringRate / config.psthdt, timeBins, simFiringRate / config.psthdt);
xlabel('time (seconds)')
ylabel('Spikes/s');
title('Firing rate');
legend(['Experiment'],...
    ['Model ' ' , Explained variance: ' num2str(modelMetrics.varExplain * 100,2) '%, R: ' num2str(modelMetrics.correlation,2)]);
subplot(2,1,2);
plot(config.dt:config.dt:length(expISI)* config.dt, expISI, ISI.simISITimes, ISI.simISIPr);
xlabel('time (seconds)')
xlim([0 0.05]);
title('ISI');
ylabel('ISI Pr');
legend('Experiment','Model');
mkdir(['./Graphs/' sessionName '/']);

if config.fCoupling == 1
    if numOfCoupledNeurons > 0
        save(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_Coupled_Results_' titleEnd], 'modelParams', 'modelMetrics');
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_Coupled_ModelResponse_' titleEnd]);
    else
        save(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_history_Results_' titleEnd], 'modelParams', 'modelMetrics');
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_history_ModelResponse_' titleEnd]);
    end
else
    save(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_NoHistory_Results_' titleEnd], 'modelParams', 'modelMetrics');
    savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_NoHistory_ModelResponse_' titleEnd]);
end

drawnow;
end