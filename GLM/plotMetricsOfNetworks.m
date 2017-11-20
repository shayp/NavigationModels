clear all;
baseFolder = 'Graphs';
slash = '/';
networkDirs = dir(baseFolder);

numOfRegEx = 6;
regex{1}  ='Neuron_*_NoHistory_Results_single.mat';
regex{2} = 'Neuron_*_NoHistory_Results_best.mat';
regex{3} = 'Neuron_*_History_Results_single.mat';
regex{4} = 'Neuron_*_History_Results_best.mat';
regex{5} = 'Neuron_*_Coupled_Results_single.mat';
regex{6} = 'Neuron_*_Coupled_Results_best.mat';

correlation = {};
varExplain = {};
mse = {};
cellsIndex = 0;
for i = 1:length(networkDirs)
    if networkDirs(i).isdir
        currentNetwork = networkDirs(i).name;
        currentyPath = strcat(baseFolder,slash, currentNetwork);
        for j = 1:6
            currentFiles = dir(strcat(currentyPath,slash, regex{j}));
            numOfNeurons = length(currentFiles);
            for k = 1:numOfNeurons
                filePath = strcat(currentyPath, slash, currentFiles(k).name);
                load(filePath);
                correlation{j, cellsIndex + k} = modelMetrics.correlation;
                varExplain{j, cellsIndex + k} = modelMetrics.varExplain;
                mse{j, cellsIndex + k} = modelMetrics.mse;

            end
        end
        cellsIndex = cellsIndex + numOfNeurons;
    end
end
cellsIndex

corrMat = cell2mat(correlation);
mseMat = cell2mat(mse);
varExplainMat = cell2mat(varExplain);
varExplainMat = varExplainMat * 100;
[~, numOfNeurons] = size(corrMat);
meanCorr = mean(corrMat,2);
stdCorr = std(corrMat') / sqrt(numOfNeurons);

meanMSE = mean(mseMat,2);
stdMSE = std(mseMat') / sqrt(numOfNeurons);

meanVarExp = mean(varExplainMat,2);
stdVarExp = std(varExplainMat') / sqrt(numOfNeurons);

figure();
subplot(3,1,1);
errorbar(meanCorr, stdCorr,'ok','linewidth',3);
hold on;
plot(0.5:6.5,mean(meanCorr) * ones(7,1),'--b','linewidth',2)
hold off;
box off
set(gca,'fontsize',14)
set(gca,'XLim',[0 7]); set(gca,'XTick',1:6)
set(gca,'XTickLabel',{'NoHistory Single','NoHistory Best','History Single','History Best','Coupled single','Coupled Best'});
ylabel('Pearson correlation');
title(' Pearson correlation');

subplot(3,1,2);
errorbar(meanMSE, stdMSE,'ok','linewidth',3);hold on;
hold on;
plot(0.5:6.5,mean(meanMSE) * ones(7,1),'--b','linewidth',2)
hold off;
box off
set(gca,'fontsize',14)
set(gca,'XLim',[0 7]); set(gca,'XTick',1:6)
set(gca,'XTickLabel',{'NoHistory Single','NoHistory Best','History Single','History Best','Coupled single','Coupled Best'});
ylabel('Mean squred error');
title(' Mean squred error');

subplot(3,1,3);
errorbar(meanVarExp, stdVarExp,'ok','linewidth',3);
hold on;
plot(0.5:6.5,mean(meanVarExp) * ones(7,1),'--b','linewidth',2)
hold off;
box off
set(gca,'fontsize',14)
set(gca,'XLim',[0 7]); set(gca,'XTick',1:6)
set(gca,'XTickLabel',{'NoHistory Single','NoHistory Best','History Single','History Best','Coupled single','Coupled Best'});
ylabel('Explained variance');
title('Fraction of explained variance');
