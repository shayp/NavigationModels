function [f, df, hessian] = ln_poisson_model(param,data,modelType, numPos, numHD, numSpd, numVelX, numBorder)

X = data{1}; % subset of A
Y = data{2}; % number of spikes

% compute the firing rate
u = X * param;
rate = exp(u);

% roughness regularizer weight - note: these are tuned using the sum of f,
% and thus have decreasing influence with increasing amounts of data
b_pos = 0.1; b_hd = 1e0; b_spd = 0.0001; b_velx = 10; b_border = 1e0;
%b_pos = 0.1; b_hd = 1e0; b_spd = 0.0001; b_velx = 2; b_border = 1e0;
%b_pos = 0; b_hd = 0; b_spd = 0; b_velx = 0; b_border = 0;
% start computing the Hessian
rX = bsxfun(@times,rate,X);       
hessian_glm = rX'*X;

%% find the P, H, S, or T parameters and compute their roughness penalties

% initialize parameter-relevant variables
J_pos = 0; J_pos_g = []; J_pos_h = []; 
J_hd = 0; J_hd_g = []; J_hd_h = [];  
J_spd = 0; J_spd_g = []; J_spd_h = [];  
J_velx = 0; J_velx_g = []; J_velx_h = [];  
J_border = 0; J_border_g = []; J_border_h = [];  
% find the parameters
[param_pos,param_hd,param_spd, param_velx, param_border] = find_param(param,modelType,numPos,numHD,numSpd, numVelX, numBorder);

% compute the contribution for f, df, and the hessian
if ~isempty(param_pos)
    [J_pos,J_pos_g,J_pos_h] = rough_penalty_2d(param_pos,b_pos);
end

if ~isempty(param_hd)
    [J_hd,J_hd_g,J_hd_h] = rough_penalty_1d_circ(param_hd,b_hd);
end

if ~isempty(param_spd)
    [J_spd,J_spd_g,J_spd_h] = rough_penalty_1d(param_spd,b_spd);
end

if ~isempty(param_velx)
    [J_velx,J_velx_g,J_velx_h] = rough_penalty_1d(param_velx,b_velx);
end

if ~isempty(param_border)
    [J_border,J_border_g,J_border_h] = rough_penalty_1d(param_border,b_border);
end

%% compute f, the gradient, and the hessian 
f = sum(rate-Y.*u) + J_pos + J_hd + J_spd + J_velx + J_border;
df = real(X' * (rate - Y) + [J_pos_g; J_hd_g; J_spd_g; J_velx_g; J_border_g]);
hessian = hessian_glm + blkdiag(J_pos_h,J_hd_h,J_spd_h, J_velx_h, J_border_h);


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



