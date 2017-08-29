%% Description of run_me
function run_me(path, neuronNumber, fLearn, saveParamsPath)
% This script is segmented into several parts. First, the data (an
% example cell) is loaded. Then, 15 LN models are fit to the
% cell's spike train. Each model uses information about 
% position, head direction, running speed, theta phase,
% or some combination thereof, to predict a section of the
% spike train. Model fitting and model performance is computed through
% 10-fold cross-validation, and the minimization procedure is carried out
% through fminunc. Next, a forward-search procedure is
% implemented to find the simplest 'best' model describing this spike
% train. Following this, the firing rate tuning curves are computed, and
% these - along with the model-derived response profiles and the model
% performance and results of the selection procedure are plotted.

% Code as implemented in Hardcastle, Maheswaranthan, Ganguli, Giocomo,
% Neuron 2017
% V1: Kiah Hardcastle, March 16, 2017


%% Clear the workspace and load the data
% load the data
fprintf('(1/7) Loading data from example cell \n')
load (path)
if(sum(spiketrain) < 40)
    disp('Not enougth spiking neurons');
    return;
end
%% Define parameters
fprintf('(2/7) define global params\n')

defineParameters
%% Build featureMaps
fprintf('(3/7) build feature maps\n')
buildFeatureMaps

%% Learning
if (fLearn == 1)
    % fit the model
    fprintf('(4/7) Fitting all linear-nonlinear (LN) models\n')
    fit_all_ln_models

    % find the simplest model that best describes the spike train
    fprintf('(5/7) Performing forward model selection\n')
    select_best_model

    % Compute the firing-rate tuning curves
    fprintf('(6/7) Computing tuning curves\n')
    compute_all_tuning_curves

    % plot the results
    fprintf('(7/7) Plotting performance and parameters\n') 
    plot_performance_and_parameters
end
end