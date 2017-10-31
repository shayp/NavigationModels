%% Description
% This will plot the results of all the preceding analyses: the model
% performance, the model-derived tuning curves, and the firing rate tuning
% curves.
function plotPerformanceAndParameters(config, modelParams, modelMetrics, expFiringRate, ...
    simFiringRate, neuronNumber, titleEnd, numOfCoupledNeurons, ISI)

currentIndex = 0;
numOfRows = ceil(modelParams.numOfFilters / 2);

hd_vector =  linspace(0, 2 * pi, config.numOfHeadDirectionParams);
velXAxis = linspace(-config.maxVelocityXAxis, config.maxVelocityXAxis, config.numOfVelocityAxisParams);
velYAxis = linspace(config.maxVelocityYAxis, -config.maxVelocityYAxis, config.numOfVelocityAxisParams);

posXAxes = linspace(0, config.boxSize(1), config.numOfPositionAxisParams);
posYAxes = linspace(config.boxSize(2),0, config.numOfPositionAxisParams);
borderBins = linspace(0, config.maxDistanceFromBorder, config.numOfDistanceFromBorderParams);
figure();
if numel(modelParams.pos_param) == config.numOfPositionParams
    currentIndex = currentIndex + 1;
    scale_factor_pos = exp(modelParams.biasParam)*mean(exp(modelParams.hd_param))*mean(exp(modelParams.vel_param))*mean(exp(modelParams.border_param));
    pos_response = scale_factor_pos*exp(modelParams.pos_param) / config.dt;
    subplot(numOfRows,2,currentIndex)
    imagesc(posXAxes, fliplr(posYAxes),reshape(pos_response,config.numOfPositionAxisParams,config.numOfPositionAxisParams)); axis on; colorbar;
    title('Learned position curve');
    xlabel('X Dim(cms)')
    ylabel('Y Dim(cms)')
end

if  numel(modelParams.hd_param) == config.numOfHeadDirectionParams
    currentIndex = currentIndex + 1;
    scale_factor_hd = exp(modelParams.biasParam)*mean(exp(modelParams.pos_param))*mean(exp(modelParams.vel_param))*mean(exp(modelParams.border_param));
    hd_response = scale_factor_hd * exp(modelParams.hd_param) / config.dt;
    subplot(numOfRows,2,currentIndex)
    plot(hd_vector,hd_response,'k','linewidth',3)
    title('Learned head direction curve');
    xlabel('angle')
    axis([0 2*pi -inf inf])
    box off
    xlabel('angle ')
    ylabel('Spikes/s');
end


if numel(modelParams.vel_param) == config.numOfVelocityParams
    currentIndex = currentIndex + 1;
    % compute the scale factors
    scale_factor_vel = exp(modelParams.biasParam)*mean(exp(modelParams.pos_param))*mean(exp(modelParams.hd_param))*mean(exp(modelParams.border_param));

    % compute the model-derived response profiles
    vel_response = scale_factor_vel*exp(modelParams.vel_param) / config.dt;
    subplot(numOfRows,2,currentIndex)
    imagesc(velXAxis, fliplr(velYAxis),reshape(vel_response, config.numOfVelocityAxisParams, config.numOfVelocityAxisParams)); axis on; colorbar;
    title('Learned velocity curve');
    xlabel('dx/dt(cm/s)')
    ylabel('dy/dt(cm/s)')
    box off
end

if numel(modelParams.border_param) == config.numOfDistanceFromBorderParams
    currentIndex = currentIndex + 1;
    % compute the scale factors
    scale_factor_Border = exp(modelParams.biasParam)*mean(exp(modelParams.pos_param))*mean(exp(modelParams.hd_param))*mean(exp(modelParams.vel_param));

    % compute the model-derived response profiles
    border_response = scale_factor_Border*exp(modelParams.border_param) / config.dt;
    subplot(numOfRows,2,currentIndex)
    plot(borderBins,border_response,'k','linewidth',3)
    title('Learned border curve');
    xlabel('distance from border')
    ylabel('Spikes/s');
    box off
end
if config.fCoupling
    currentIndex = currentIndex + 1;
    historyLen = length(modelParams.spikeHistory);
    timeSeriesHistory = linspace(1 * config.dt, historyLen * config.dt, historyLen);
    subplot(numOfRows,2,currentIndex)
    plot(timeSeriesHistory, exp(modelParams.spikeHistory));
    title('Spike history filter');
    xlabel('time (seconds)')
    ylabel('Intensity');
    for j = 1:numOfCoupledNeurons
        currentIndex = currentIndex + 1;
        subplot(numOfRows,2,currentIndex)
        couplingLen = length(modelParams.couplingFilters(:,j));
        timeSeriesCoupling = linspace(1 * config.dt, couplingLen * config.dt, couplingLen);
        plot(timeSeriesCoupling, exp(modelParams.couplingFilters(:,j)));
        title('Coupling filter');
        xlabel('time (seconds)')
        ylabel('Intensity');
    end
end
savefig(['./Graphs/Neuron_' num2str(neuronNumber) '_ParametersLearned_' titleEnd]);

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
plot(ISI.expISITimes, ISI.expISIPr, ISI.simISITimes, ISI.simISIPr);
xlabel('time (seconds)')
title('ISI');
ylabel('ISI Pr');
legend('Experiment','Model');
savefig(['./Graphs/Neuron_' num2str(neuronNumber) 'ModelResponse_' titleEnd]);

drawnow;
end