function [spikeHistoryDesignMatrix] = buildSpikeHistoryDesignMatrix(numOfBaseVectors, baseVectors,spikeTrain)

    % calculate the  base vectors
    [lengthOFBaseVectors,~] = size(baseVectors);
    
    % Do convolution and remove extra bins, shift one been for time after
    % spike
    spikeHistoryDesignMatrix = conv2(spikeTrain,baseVectors,'full');
    spikeHistoryDesignMatrix = [zeros(1,numOfBaseVectors); spikeHistoryDesignMatrix(1:end - lengthOFBaseVectors,:)];
end