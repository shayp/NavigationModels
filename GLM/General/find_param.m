%% function to find the right parameters given the model type
function [param_pos,param_hd,param_speed, param_speedHD] = find_param(param,modelType,numPos,numHD, numSpeed, numSpeedHD)

param_pos = []; param_hd = []; param_speed = []; param_speedHD = [];

if all(modelType == [1 0 0 0]) 
    param_pos = param;
elseif all(modelType == [0 1 0 0]) 
    param_hd = param;
elseif all(modelType == [0 0 1 0]) 
    param_speed = param;
elseif all(modelType == [0 0 0 1]) 
    param_speedHD = param;
    
elseif all(modelType == [1 1 0 0])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
elseif all(modelType == [1 0 1 0 ]) 
    param_pos = param(1:numPos);
    param_speed = param(numPos+1:numPos+numSpeed);
elseif all(modelType == [1 0 0 1]) 
    param_pos = param(1:numPos);
    param_speedHD = param(numPos+1:numPos+numSpeedHD);
elseif all(modelType == [0 1 1 0]) 
    param_hd = param(1:numHD);
    param_speed = param(numHD+1:numHD+numSpeed);
elseif all(modelType == [0 1 0 1]) 
    param_hd = param(1:numHD);
    param_speedHD = param(numHD+1:numHD+numSpeedHD);
elseif all(modelType == [0 0 1 1]) 
    param_speed = param(1:numSpeed);
    param_speedHD = param(numSpeed+1:numSpeed+numSpeedHD);
    
elseif all(modelType == [1 1 1 0])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_speed = param(numPos+numHD+1:numPos+numHD+numSpeed);
elseif all(modelType == [1 1 0 1])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_speedHD = param(numPos+numHD+1:numPos+numHD+numSpeedHD);
elseif all(modelType == [1 0 1 1])
    param_pos = param(1:numPos);
    param_speed = param(numPos+1:numPos+numSpeed);
    param_speedHD = param(numPos+numSpeed+1:numPos+numSpeed+numSpeedHD);
 elseif all(modelType == [0 1 1 1])
    param_hd = param(1:numHD);
    param_speed = param(numHD+1:numHD+numSpeed);
    param_speedHD = param(numHD+numSpeed+1:numHD+numSpeed+numSpeedHD);
elseif all(modelType == [1 1 1 1])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_speed = param(numPos+numHD+1:numPos+numHD+numSpeed);
    param_speedHD = param(numPos+numHD+numSpeed+1:numPos+numHD+numSpeed+numSpeedHD);
end
    