function [f, df, hessian] = ln_poisson_model(param,data,modelType, config, numOfCouplingParams)

tuningFeatures = data{1}; % subset of A
designMatrix = data{2};
spikeTrain = data{3}; % number of spikes
biasParam = param(1);

if config.fCoupling
   spikeHistoryParam = param(2:1 + numOfCouplingParams); 
   tuningParams = param(2 + numOfCouplingParams:end);
   linerProjection = tuningFeatures * tuningParams + designMatrix * spikeHistoryParam + biasParam;
else
    tuningParams = param(2:end);
    linerProjection = tuningFeatures * tuningParams + biasParam;
end

rate = exp(linerProjection);

% roughness regularizer weight - note: these are tuned using the sum of f,
% and thus have decreasing influence with increasing amounts of data
%b_pos = 0.5; b_hd = 1e0;  b_vel = 0.5; b_border = 1e0;
b_pos = 0.3; b_hd = 1e0;  b_vel = 0.3; b_border = 1e0;

%b_pos = 0; b_hd = 0;  b_vel = 0; b_border = 0;
% start computing the Hessian

dlTuningParams = tuningFeatures' * (rate - spikeTrain);
dlBias = sum(rate) - sum(spikeTrain);
dlHistory = [];
if config.fCoupling
    dlHistory = designMatrix' * (rate - spikeTrain);
end

ratediag = spdiags(rate,0, length(spikeTrain), length(spikeTrain));

HTuning = (tuningFeatures' * (bsxfun(@times,tuningFeatures,rate))); 
HBias = sum(rate);
HTuningBias = (sum(ratediag,1) * tuningFeatures)';

if config.fCoupling
    HHistory = (designMatrix' * (bsxfun(@times,designMatrix,rate)));
    HTuningHistory = ((designMatrix' * ratediag) * tuningFeatures)';
    HHistoryBias = (rate' * designMatrix)';
else
    HHistory = [];
    HTuningHistory = [];
    HHistoryBias = [];
end

%% find the P, H, S, or T parameters and compute their roughness penalties

% initialize parameter-relevant variables
J_pos = 0; J_pos_g = []; J_pos_h = []; 
J_hd = 0; J_hd_g = []; J_hd_h = [];  
J_vel = 0; J_vel_g = []; J_vel_h = [];  
J_border = 0; J_border_g = []; J_border_h = [];  
% find the parameters
[param_pos,param_hd,param_vel, param_border] = find_param(tuningParams, modelType, config.numOfPositionParams,config.numOfHeadDirectionParams, config.numOfVelocityParams, config.numOfDistanceFromBorderParams);

% compute the contribution for f, df, and the hessian
if ~isempty(param_pos)
    [J_pos,J_pos_g,J_pos_h] = rough_penalty_2d(param_pos,b_pos);
end

if ~isempty(param_hd)
    [J_hd,J_hd_g,J_hd_h] = rough_penalty_1d_circ(param_hd,b_hd);
end


if ~isempty(param_vel)
    [J_vel,J_vel_g,J_vel_h] = rough_penalty_2d(param_vel,b_vel);
end

if ~isempty(param_border)
    [J_border,J_border_g,J_border_h] = rough_penalty_1d(param_border,b_border);
end

%% compute f, the gradient, and the hessian 
f = sum(rate-spikeTrain.*linerProjection) + J_pos + J_hd + J_vel + J_border;
dlTuningParams = dlTuningParams + [J_pos_g; J_hd_g; J_vel_g; J_border_g];
df = [dlBias; dlHistory; dlTuningParams];
HTuning = HTuning + blkdiag(J_pos_h,J_hd_h, J_vel_h, J_border_h);
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



