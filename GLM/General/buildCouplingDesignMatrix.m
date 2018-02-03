function [couplingDesignMatrix] = buildCouplingDesignMatrix(numOfBaseVectors, baseVectors,spikeTrain, timeBeforeSpike, acausalInteraction)

    % calculate the  base vectors
    [lengthOFBaseVectors,~] = size(baseVectors);
    
    % Do convolution and remove extra bins
    Y = conv2(spikeTrain,baseVectors,'full');
    if acausalInteraction 
        Y = [Y(timeBeforeSpike:end - lengthOFBaseVectors + timeBeforeSpike,:)];
    else
        Y = [zeros(1,numOfBaseVectors); Y(1:end - lengthOFBaseVectors,:)];
    end
    couplingDesignMatrix = Y;
end