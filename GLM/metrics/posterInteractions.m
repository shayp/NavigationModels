sessionName = '11025-19050503';
neurons = [3];
dt = 1/1000;
psthdt = 1/50;
folderPath = strcat('C:\projects\NavigationModels\GLM\Graphs\', sessionName);
bestFilePath = [folderPath '\Neuron_' num2str(neurons(1)) '_Coupled_Results_best_causal'];
accausalbestFilePath = [folderPath '\Neuron_' num2str(neurons(1)) '_Coupled_Results_best_notcausal'];

load(accausalbestFilePath);
acausalCoupling = modelParams.couplingFilters;
acausalT = linspace(-40 * dt, (length(acausalCoupling) - 40) * dt, length(acausalCoupling));

load(bestFilePath);
causalCoupling = modelParams.couplingFilters;
causalT = linspace(1 * dt, (length(causalCoupling)) * dt, length(causalCoupling));

figure();
t = ones(length(acausalCoupling),1);
p = plot(acausalT, exp(acausalCoupling), '-r', causalT, exp(causalCoupling), 'linewidth',3);
p(2).Color = [0.5 0.5 0.5];
xlim([-40 * dt 42* dt]);
ylim([0 2]);
legend('acausal interaction','causal interaction');
hold on;
plot(acausalT, t,'--k','linewidth',3);
hold off;
xlabel('Lag from spike (seconds)');
ylabel('Gain');
