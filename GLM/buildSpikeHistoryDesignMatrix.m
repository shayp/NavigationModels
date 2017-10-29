function [spikeHistoryDesignMatrix] = buildSpikeHistoryDesignMatrix(numOfBaseVectors, baseVectors,spikeTrain)

    % calculate the  base vectors
    [lengthOFBaseVectors,~] = size(baseVectors);
    % Do convolution and remove extra bins
    Y = conv2(spikeTrain,baseVectors,'full');
    Y = [zeros(1,numOfBaseVectors); Y(1:end - lengthOFBaseVectors,:)];
    spikeHistoryDesignMatrix = Y;
end