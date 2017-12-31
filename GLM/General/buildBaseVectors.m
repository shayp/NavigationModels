function baseVectors = buildBaseVectors(numOfBaseVectors)
matrixLen = (1 + numOfBaseVectors) * round(numOfBaseVectors / 2);
baseVectors = zeros(matrixLen, numOfBaseVectors);
%baseVectors = diag(ones(numOfBaseVectors,1));
counter = 0;
for i = 1:numOfBaseVectors
    baseVectors(counter + 1:counter + i, i) =  baseVectors(counter + 1:counter + i, i) + 1; 
    counter = counter + i;
end
if matrixLen > counter
    baseVectors(counter + 1:end,end) = baseVectors(counter + 1:end,end) + 1;
end
end