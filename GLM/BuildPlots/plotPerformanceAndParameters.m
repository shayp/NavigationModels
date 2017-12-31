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
scale_factor = exp(modelParams.biasParam);
if numel(modelParams.pos_param) == config.numOfPositionParams
    currentIndex = currentIndex + 1;
    pos_response = scale_factor*exp(modelParams.pos_param);
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
    hd_response = scale_factor * exp(modelParams.hd_param);
    subplot(numOfRows,2,currentIndex)
    polarplot([hd_vector hd_vector(1)],[hd_response hd_response(1)],'k','linewidth',2);
    title('Learned head direction curve');
end


if numel(modelParams.speed_param) == config.numOfSpeedBins
    currentIndex = currentIndex + 1;
    % compute the scale factors

    % compute the model-derived response profiles
    speed_response = scale_factor*exp(modelParams.speed_param);
    subplot(numOfRows,2,currentIndex)
    plot(speedBins, speed_response,'k','linewidth',3);
    axis square
    title('Learned speed curve');
    xlabel('speed (cm/s)')
    ylabel('spikes/s')
    box off
end

if numel(modelParams.speedHD_param) == config.numOfHDSpeedBins
    currentIndex = currentIndex + 1;

    % compute the model-derived response profiles
    speedHD_response = scale_factor*exp(modelParams.speedHD_param);
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
    numOfPlots = 2;
    figure();
    currentIndex =  1;
    historyLen = length(modelParams.spikeHistory);
    timeSeriesHistory = linspace(1 * config.dt, historyLen * config.dt, historyLen);
    dashline = ones(historyLen,1);
    subplot(2 ,1,1)
    plot(timeSeriesHistory, exp(modelParams.spikeHistory), timeSeriesHistory, dashline, '--r');
    title('Spike history filter');
    xlabel('time (seconds)')
    ylabel('Intensity');
    if numOfCoupledNeurons > 0
        couplingLen = length(modelParams.couplingFilters(:,1));
        timeSeriesCoupling = linspace(1 * config.dt, couplingLen * config.dt, couplingLen);
        dashline = ones(couplingLen,1);
        subplot(2 ,1,2)
        legendLabels = strtrim(cellstr(num2str(coupledNeurons'))');

        semilogy(timeSeriesCoupling, exp(modelParams.couplingFilters), timeSeriesCoupling, dashline, '--r')
        xlabel('time (seconds)')
        ylabel('Intensity');
        title('Coupling filters');
        legend(legendLabels, 'Location', 'bestoutside');
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