function SO3F = quadrature(f, varargin)
%
% Syntax
%   SO3F = SO3FunHarmonic.quadrature(nodes,values,'weights',w)
%   SO3F = SO3FunHarmonic.quadrature(f)
%   SO3F = SO3FunHarmonic.quadrature(f, 'bandwidth', bandwidth)
%
% Input
%  values - double (first dimension has to be the evaluations)
%  nodes  - @rotation
%  f - function handle in vector3d (first dimension has to be the evaluations)
%
% Output
%  SO3F - @SO3FunHarmonic
%
% Options
%  bandwidth - minimal harmonic degree (default: 64)
%

persistent keepPlanNOSFT;

% kill plan
if check_option(varargin,'killPlan')
  nfsftmex('finalize',keepPlanNOSFT);
  keepPlanNOSFT = [];
  return
end

bw = get_option(varargin, 'bandwidth', 64);

if isa(f,'SO3Fun'), f = @(v) f.eval(v); end

if isa(f,'function_handle')
  if check_option(varargin, 'gauss')
    [nodes, W] = quadratureSO3Grid(2*bw, 'gauss');
  else
    [nodes, W] = quadratureSO3Grid(2*bw);
  end
  values = f(nodes(:));
else
  nodes = f(:);
  values = varargin{1};
  W = get_option(varargin,'weights',1);
  
  if length(nodes)>100000 && length(values) == length(nodes) && length(W)==1
    % TODO: use a regular grid here and a faster search
    n2 = equispacedSO3Grid('resolution',0.5*degree);
    id = find(n2,nodes);
    values = accumarray(id,values,[length(n2),1]);
    
    id = values>0;
    nodes = reshape(n2.subGrid(id),[],1);
    values = values(id);
    nodes.antipodal = f.antipodal;
  end
end

if isempty(nodes)
  SO3F = SO3FunHarmonic(0);
  return
end

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlanNOSFT;
else
  plan = [];
end

% initialize nfsft
if isempty(plan)
  
  % 2^4 -> nfsoft-represent
  % 2^2 -> nfsoft-use-DPT
  nfsoft_flags = bitor(2^4,4);
  % nfft cutoff - 4
  % fpt kappa - 1000
  % fftw_size -> 2*ceil(1.5*L)
  % initialize nfsoft plan
  plan = nfsoftmex('init',bw,length(nodes),nfsoft_flags,0,4,1000,2*ceil(1.5*bw)); 
  
  nfsoftmex('set_x',plan,Euler(nodes,'nfft').');
  nfsoftmex('precompute',plan);

end

s = size(values);
values = reshape(values, length(nodes), []);
num = size(values, 2);

fhat = zeros(deg2dim(bw+1), num);
for index = 1:num
  % adjoint nfsoft
  nfsoftmex('set_f', plan, W(:) .* values(:, index));
  nfsoftmex('adjoint', plan);
  fhat(:, index) = nfsftmex('get_f_hat_linear', plan);
end

% kill plan
if check_option(varargin,'keepPlan')
  keepPlanNOSFT = plan;
else
  nfsftmex('finalize', plan);
end


% maybe we have a multivariate function
try
  fhat = reshape(fhat, [deg2dim(bw+1) s(2:end)]);
end
SO3F = SO3FunHarmonic(fhat);
SO3F.bandwidth = bw;

% if antipodal consider only even coefficients
SO3F.antippodal = check_option(varargin,'antipodal') || nodes.antipodal;

end
