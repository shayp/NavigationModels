
folderPath = 'all_data/';
allDir = dir(folderPath);
numOfVars = numel(allDir);

for i = 1:numOfVars
    if allDir(i).isdir == 1
        buildDataOfNetwork(strcat(allDir(i).name), strcat(folderPath, allDir(i).name, '/'));
    end
end
    