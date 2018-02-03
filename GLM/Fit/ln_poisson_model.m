function [f, df, hessian] = ln_poisson_model(param,data,modelType, config, numOfCouplingParams)

tuningFeatures = data{1}; % subset of A
designMatrix = data{2};
spikeTrain = data{3}; % number of spikes
biasParam = param(1);

% roughness regularizer weight - note: these are tuned using the sum of f,
% and thus have decreasing influence with increasing amounts of data
b_pos = 4e0; b_hd = 5e-3;  b_speed = 5e1; b_Theta =5e-2;
%b_pos = 10e0; b_hd = 5e-3;  b_speed = 5e-3; b_Theta =5e-4;

if config.fCoupling
   spikeHistoryParam = param(2:1 + numOfCouplingParams); 
   tuningParams = param(2 + numOfCouplingParams:end);
   linerProjection = tuningFeatures * tuningParams + designMatrix * spikeHistoryParam + biasParam;
else
    tuningParams = param(2:end);
    linerProjection = tuningFeatures * tuningParams + biasParam;
end

firingRate = exp(linerProjection);

% Negative Log likelihood
ll_Trm0 = sum(firingRate)* config.dt;
ll_Trm1 = -spikeTrain' * linerProjection;
logLL = ll_Trm0 + ll_Trm1;

% derivatives

dlTuning0 = firingRate' * tuningFeatures;
dlTuning1 = spikeTrain' * tuningFeatures;
dlTuningParams = (dlTuning0 * config.dt - dlTuning1)';
dlBias = sum(firingRate) * config.dt - sum(spikeTrain);

dlHistory = [];
if config.fCoupling
    dlHistory0 = firingRate' * designMatrix;
    dlHistory1 = spikeTrain' * designMatrix;
    dlHistory = (dlHistory0 * config.dt - dlHistory1)';
end

ratediag = spdiags(firingRate,0, length(spikeTrain), length(spikeTrain));

HTuning = (tuningFeatures' * (bsxfun(@times,tuningFeatures,firingRate))) *  config.dt; 
HBias = sum(firingRate) *  config.dt;
HTuningBias = (sum(ratediag,1) * tuningFeatures)' *  config.dt;

if config.fCoupling
    HHistory = (designMatrix' * (bsxfun(@times,designMatrix,firingRate))) * config.dt;
    HTuningHistory = ((designMatrix' * ratediag) * tuningFeatures)' *  config.dt;
    HHistoryBias = (firingRate' * designMatrix)' *  config.dt;
else
    HHistory = [];
    HTuningHistory = [];
    HHistoryBias = [];
end

%% find the P, H, S, or T parameters and compute their roughness penalties

% initialize parameter-relevant variables
J_pos = 0; J_pos_g = []; J_pos_h = []; 
J_hd = 0; J_hd_g = []; J_hd_h = [];  
J_speed = 0; J_speed_g = []; J_speed_h = [];  
J_theta = 0; J_theta_g = []; J_theta_h = [];  
% find the parameters
[param_pos,param_hd,param_speed, param_theta] = find_param(tuningParams, modelType, config.numOfPositionParams,config.numOfHeadDirectionParams, config.numOfSpeedBins, config.numOfTheta);

% compute the contribution for f, df, and the hessian
if ~isempty(param_pos)
    [J_pos,J_pos_g,J_pos_h] = rough_penalty_2d(param_pos,b_pos);
end

if ~isempty(param_hd)
    [J_hd,J_hd_g,J_hd_h] = rough_penalty_1d_circ(param_hd,b_hd);
end

if ~isempty(param_speed)
    [J_speed,J_speed_g,J_speed_h] = rough_penalty_1d(param_speed,b_speed);
end

if ~isempty(param_theta)
    [J_theta,J_theta_g,J_theta_h] = rough_penalty_1d_circ(param_theta,b_Theta);
end

%% compute f, the gradient, and the hessian 
J_History = 0;
dlCoupled = [];
if config.fCoupling && config.numOfHistoryParams
%     J_couled = 5e-1 * sum(abs(spikeHistoryParam(config.numOfHistoryParams:end)));
%     dlCoupled = 5e-1 * sign(spikeHistoryParam(config.numOfHistoryParams:end));
     J_History = 5e-1 * sum(abs(spikeHistoryParam));
     dlHistory = dlHistory + 5e-1 * sign(spikeHistoryParam);
    %dlHistory(config.numOfHistoryParams:end) = dlHistory(config.numOfHistoryParams:end) + dlCoupled;
end
f = logLL + J_pos + J_hd + J_speed + J_theta + J_History;
dlTuningParams = dlTuningParams + [J_pos_g; J_hd_g; J_speed_g; J_theta_g];
df = [dlBias; dlHistory; dlTuningParams];
HTuning = HTuning + blkdiag(J_pos_h,J_hd_h, J_speed_h, J_theta_h);
hessian = [[HBias HHistoryBias' HTuningBias']; [HHistoryBias HHistory HTuningHistory']; [HTuningBias HTuningHistory HTuning]];


%% smoothing functions called in the above script
function [J,J_g,J_h] = rough_penalty_2d(param,beta)

    numParam = numel(param);
    D1 = spdiags(ones(sqrt(numParam),1)*[-1 1],0:1,sqrt(numParam)-1,sqrt(numParam));
    DD1 = D1'*D1;
    M1 = kron(eye(sqrt(numParam)),DD1); M2 = kron(DD1,eye(sqrt(numParam)));
    M = (M1 + M2);
 
    J = beta*0.5*param'*M*param;
    J_g = beta*M*param;
    J_h = beta*M;

function [J,J_g,J_h] = rough_penalty_1d_circ(param,beta)
    
    numParam = numel(param);
    D1 = spdiags(ones(numParam,1)*[-1 1],0:1,numParam-1,numParam);
    DD1 = D1'*D1;
    
    % to correct the smoothing across first and last bin
    DD1(1,:) = circshift(DD1(2,:),[0 -1]);
    DD1(end,:) = circshift(DD1(end-1,:),[0 1]);
    
    J = beta*0.5*param'*DD1*param;
    J_g = beta*DD1*param;
    J_h = beta*DD1;

function [J,J_g,J_h] = rough_penalty_1d(param,beta)

    numParam = numel(param);
    D1 = spdiags(ones(numParam,1)*[-1 1],0:1,numParam-1,numParam);
    DD1 = D1'*D1;
    J = beta*0.5*param'*DD1*param;
    J_g = beta*DD1*param;
    J_h = beta*DD1;



