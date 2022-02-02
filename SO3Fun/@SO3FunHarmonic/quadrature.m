function SO3F = quadrature(f, varargin)
%
% Syntax
%   SO3F = SO3FunHarmonic.quadrature(nodes,values,'weights',w)
%   SO3F = SO3FunHarmonic.quadrature(f)
%   SO3F = SO3FunHarmonic.quadrature(f, 'bandwidth', bandwidth)
%
% Input
%  values - double (first dimension has to be the evaluations)
%  nodes  - @rotation, @orientation
%  f - function handle in @orientation (first dimension has to be the evaluations)
%
% Output
%  SO3F - @SO3FunHarmonic
%
% Options
%  bandwidth - minimal harmonic degree (default: 64)
%

if check_option(varargin,'v2')
  SO3F = SO3FunHarmonic.quadrature_v2(f,varargin{:});
  return
end


persistent keepPlanNSOFT;

% kill plan
if check_option(varargin,'killPlan')
  nfsoftmex('finalize',keepPlanNSOFT);
  keepPlanNSOFT = [];
  return
end

bw = get_option(varargin, 'bandwidth', 64);

if isa(f,'SO3Fun')
  SLeft = f.SLeft; SRight = f.SRight;
  f = @(v) f.eval(v);
end

if isa(f,'function_handle')
  if check_option(varargin, 'gauss')
    [nodes, W] = quadratureSO3Grid(2*bw, 'gauss',SLeft,SRight);
  else
    [nodes, W] = quadratureSO3Grid(2*bw,'ClenshawCurtis',SLeft,SRight);
  end
  values = f(nodes(:));
else
  nodes = f(:);
  values = varargin{1};
  W = get_option(varargin,'weights',1);
  
  if length(nodes)>1e7 && length(values) == length(nodes) && length(W)==1
    % TODO: use a regular grid here and a faster search 
    % TODO: nodes have to be orientation to use nodes.CS . Does the following work correctly?
    % if isa(nodes,'rotation'), orientation(nodes,crystalSymmetry); end
    n2 = equispacedSO3Grid(nodes.CS,'resolution',0.5*degree);
    id = find(n2,nodes);
    values = accumarray(id,values,[length(n2),1]);
    
    id = values>0;
    nodes = reshape(n2.subGrid(id),[],1);
    values = values(id);
    nodes.antipodal = f.antipodal;
  end

  if isa(nodes,'orientation')
    SLeft = nodes.CS; SRight = nodes.SS;
  else
    [SLeft,SRight] = extractSym(varargin);
  end
end

if isempty(nodes)
  SO3F = SO3FunHarmonic(0,SLeft,SRight);
  return
end

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlanNSOFT;
else
  plan = [];
end

% initialize nfsoft
if isempty(plan)
  
  % 2^4 -> nfsoft-represent
  % 2^2 -> nfsoft-use-DPT
   % 2^0 -> use normalized Wigner-D functions and fourier coefficients
  nfsoft_flags = bitor(2^4,4)+1;
  % nfft cutoff - 4
  % fpt kappa - 1000
  % fftw_size -> 2*ceil(1.5*L)
  % initialize nfsoft plan
  plan = nfsoftmex('init',bw,length(nodes),nfsoft_flags,0,4,1000,2*ceil(1.5*bw));
  
  % set rotations in Euler angles (nodes)
  nfsoftmex('set_x',plan,Euler(nodes,'nfft').');
  
  % node-dependent precomputation
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
  % get fourier coefficients from plan and normalize
  fhat(:, index) = nfsoftmex('get_f_hat', plan)*(sqrt(8)*pi);
end

% kill plan
if check_option(varargin,'keepPlan')
  keepPlanNSOFT = plan;
else
  nfsoftmex('finalize', plan);
end


% maybe we have a multivariate function
try
  fhat = reshape(fhat, [deg2dim(bw+1) s(2:end)]);
end
SO3F = SO3FunHarmonic(fhat,SLeft,SRight);
SO3F.bandwidth = bw;

% if antipodal consider only even coefficients
SO3F.antipodal = check_option(varargin,'antipodal') || (isa(nodes,'orientation') && nodes.antipodal);

end
