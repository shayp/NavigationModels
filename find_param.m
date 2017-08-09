%% function to find the right parameters given the model type
function [param_pos,param_hd,param_vel, param_border] = find_param(param,modelType,numPos,numHD, numVel, numBorder)

param_pos = []; param_hd = []; param_vel = []; param_border = [];

if all(modelType == [1 0 0 0]) 
    param_pos = param;
elseif all(modelType == [0 1 0 0]) 
    param_hd = param;
elseif all(modelType == [0 0 1 0]) 
    param_vel = param;
elseif all(modelType == [0 0 0 1]) 
    param_border = param;
    
elseif all(modelType == [1 1 0 0])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
elseif all(modelType == [1 0 1 0 ]) 
    param_pos = param(1:numPos);
    param_vel = param(numPos+1:numPos+numVel);
elseif all(modelType == [1 0 0 1]) 
    param_pos = param(1:numPos);
    param_border = param(numPos+1:numPos+numBorder);
elseif all(modelType == [0 1 1 0]) 
    param_hd = param(1:numHD);
    param_vel = param(numHD+1:numHD+numVel);
elseif all(modelType == [0 1 0 1]) 
    param_hd = param(1:numHD);
    param_border = param(numHD+1:numHD+numBorder);
elseif all(modelType == [0 0 1 1]) 
    param_vel = param(1:numVel);
    param_border = param(numVel+1:numVel+numBorder);
    
elseif all(modelType == [1 1 1 0])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_vel = param(numPos+numHD+1:numPos+numHD+numVel);
elseif all(modelType == [1 1 0 1])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_border = param(numPos+numHD+1:numPos+numHD+numBorder);
elseif all(modelType == [1 0 1 1])
    param_pos = param(1:numPos);
    param_vel = param(numPos+1:numPos+numVel);
    param_border = param(numPos+numVel+1:numPos+numVel+numBorder);
 elseif all(modelType == [0 1 1 1])
    param_hd = param(1:numHD);
    param_vel = param(numHD+1:numHD+numVel);
    param_border = param(numHD+numVel+1:numHD+numVel+numBorder);
elseif all(modelType == [1 1 1 1])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_vel = param(numPos+numHD+1:numPos+numHD+numVel);
    param_border = param(numPos+numHD+numVel+1:numPos+numHD+numVel+numBorder);
end
    