function [refreactoryPeriod, ISIPeak] =  getRefractoryPeriodForNeurons(spiketrain, dt)

    ISI =  diff(find(spiketrain));
    maxISI = max(ISI);
    ISIPr = zeros(maxISI, 1);
    for j = 1:maxISI
        ISIPr(j) = sum(ISI == j);
    end
    ISIPr = ISIPr / sum(ISIPr);
     wantedIndexes = find(ISIPr >= 0.005);
     if isempty(wantedIndexes)
         wantedIndex = 2;
     else
        wantedIndex = wantedIndexes(1) - 1;
     end
     
    
    refreactoryPeriod = max(1,wantedIndex);
    
    [~, ISIPeak] = max(ISIPr);
    if ISIPeak <= refreactoryPeriod
        ISIPeak = refreactoryPeriod + 1;
    end
    
    ISIPeak = ISIPeak * dt;
    refreactoryPeriod = refreactoryPeriod * dt;
    
end