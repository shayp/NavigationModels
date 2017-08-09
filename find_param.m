%% function to find the right parameters given the model type
function [param_pos,param_hd,param_spd, param_velx, param_border] = find_param(param,modelType,numPos,numHD, numSpd, numVelX, numBorder)

param_pos = []; param_hd = []; param_spd = []; param_velx = []; param_border = [];

if all(modelType == [1 0 0 0 0]) 
    param_pos = param;
elseif all(modelType == [0 1 0 0 0]) 
    param_hd = param;
elseif all(modelType == [0 0 1 0 0]) 
    param_spd = param;
elseif all(modelType == [0 0 0 1 0]) 
    param_velx = param;
elseif all(modelType == [0 0 0 0 1]) 
    param_border = param;
elseif all(modelType == [1 1 0 0 0])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
elseif all(modelType == [1 0 1 0 0 ]) 
    param_pos = param(1:numPos);
    param_spd = param(numPos+1:numPos+numSpd);
elseif all(modelType == [1 0 0 1 0]) 
    param_pos = param(1:numPos);
    param_velx = param(numPos+1:numPos+numVelX);
elseif all(modelType == [1 0 0 0 1]) 
    param_pos = param(1:numPos);
    param_border = param(numPos+1:numPos+numBorder);
elseif all(modelType == [0 1 1 0 0]) 
    param_hd = param(1:numHD);
    param_spd = param(numHD+1:numHD+numSpd);
elseif all(modelType == [0 1 0 1 0]) 
    param_hd = param(1:numHD);
    param_velx = param(numHD+1:numHD+numVelX);
elseif all(modelType == [0 1 0 0 1]) 
    param_hd = param(1:numHD);
    param_border = param(numHD+1:numHD+numBorder);
elseif all(modelType == [0 0 1 1 0]) 
    param_spd = param(1:numSpd);
    param_velx = param(numSpd+1:numSpd+numVelX);
elseif all(modelType == [0 0 1 0 1]) 
    param_spd = param(1:numSpd);
    param_border = param(numSpd+1:numSpd+numBorder);
elseif all(modelType == [0 0 0 1 1]) 
    param_velx = param(1:numVelX);
    param_border = param(numVelX+1:numVelX+numBorder);  

elseif all(modelType == [1 1 1 0 0])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_spd = param(numPos+numHD+1:numPos+numHD+numSpd);
elseif all(modelType == [1 1 0 1 0])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_velx = param(numPos+numHD+1:numPos+numHD+numVelX);
elseif all(modelType == [1 1 0 0 1])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_border = param(numPos+numHD+1:numPos+numHD+numBorder);
elseif all(modelType == [1 0 1 1 0])
    param_pos = param(1:numPos);
    param_spd = param(numPos+1:numPos+numSpd);
    param_velx = param(numPos+numSpd+1:numPos+numSpd+numVelX);
elseif all(modelType == [1 0 1 0 1])
    param_pos = param(1:numPos);
    param_spd = param(numPos+1:numPos+numSpd);
    param_border = param(numPos+numSpd+1:numPos+numSpd+numBorder);
elseif all(modelType == [1 0 0 1 1])
    param_pos = param(1:numPos);
    param_velx = param(numPos+1:numPos+numVelX);
    param_border = param(numPos+numVelX+1:numPos+numVelX+numBorder);
elseif all(modelType == [0 1 1 1 0])
    param_hd = param(1:numHD);
    param_spd = param(numHD+1:numHD+numSpd);
    param_velx = param(numHD+numSpd+1:numHD+numSpd+numVelX);
elseif all(modelType == [0 1 1 0 1])
    param_hd = param(1:numHD);
    param_spd = param(numHD+1:numHD+numSpd);
    param_border = param(numHD+numSpd+1:numHD+numSpd+numBorder);
 elseif all(modelType == [0 1 0 1 1])
    param_hd = param(1:numHD);
    param_velx = param(numHD+1:numHD+numVelX);
    param_border = param(numHD+numVelX+1:numHD+numVelX+numBorder);
elseif all(modelType == [0 0 1 1 1])
    param_spd = param(1:numSpd);
    param_velx = param(numSpd+1:numSpd+numVelX);
    param_border = param(numSpd+numVelX+1:numSpd+numVelX+numBorder);
    
elseif all(modelType == [1 1 1 1 0])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_spd = param(numPos+numHD+1:numPos+numHD+numSpd);
    param_velx = param(numPos+numHD+numSpd+1:numPos+numHD+numSpd+numVelX);
elseif all(modelType == [1 1 1 0 1])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_spd = param(numPos+numHD+1:numPos+numHD+numSpd);
    param_border = param(numPos+numHD+numSpd+1:numPos+numHD+numSpd+numBorder);
elseif all(modelType == [1 1 0 1 1])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_velx = param(numPos+numHD+1:numPos+numHD+numVelX);
    param_border = param(numPos+numHD+numVelX+1:numPos+numHD+numVelX+numBorder);
elseif all(modelType == [1 0 1 1 1])
    param_pos = param(1:numPos);
    param_spd = param(numPos+1:numPos+numSpd);
    param_velx = param(numPos+numSpd+1:numPos+numSpd+numVelX);
    param_border = param(numPos+numSpd+numVelX+1:numPos+numSpd+numVelX+numBorder);
elseif all(modelType == [0 1 1 1 1])
    param_hd = param(1:numHD);
    param_spd = param(numHD+1:numHD+numSpd);
    param_velx = param(numHD+numSpd+1:numHD+numSpd+numVelX);
    param_border = param(numHD+numSpd+numVelX+1:numHD+numSpd+numVelX+numBorder);
elseif all(modelType == [1 1 1 1 1])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_spd = param(numPos+numHD+1:numPos+numHD+numSpd);
    param_velx = param(numPos+numHD+numSpd+1:numPos+numHD+numSpd+numVelX);
    param_border = param(numPos+numHD+numSpd+numVelX+1:numPos+numHD+numSpd+numVelX+numBorder);
end
    