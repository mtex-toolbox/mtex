function SO3F = adjointNFSOFT(rot,values, varargin)
% Compute the SO(3)-Fourier/Wigner transform of given evaluations on a 
% specific quadrature grid.
%
% It uses a NFSOFT (which includes a fast polynom transform).
% We prefer the faster, simpler and more stable |SO3FunHarmonic.adjoint|
% method.
% 
%
% Syntax
%   SO3F = SO3FunHarmonic.adjointNFSOFT(nodes,values,'weights',w)
%   SO3F = SO3FunHarmonic.adjoint(f,'nfsoft')
%
% Input
%  rot  - @quadratureSO3Grid, @rotation, @orientation
%  values - double
%
% Output
%  SO3F - @SO3FunHarmonic
%
% Options
%  bandwidth - minimal harmonic degree (default: 64)
%  weights - quadrature weights
%
% See also
% SO3FunHarmonic/quadrature SO3FunHarmonic/adjoint

persistent keepPlanNSOFT;

% Multivariate functions
if length(rot)~=numel(values)
  s = size(values); s = s(2:end);
  values = reshape(values,length(rot),[]);
  SO3FunHarmonic.adjointNFSOFT(rot,values(:,1),'createPlan',varargin{:});
  SO3F=[];
  for ind = 1:prod(size(values,2))
    SO3F(:,ind) = SO3FunHarmonic.adjointNFSOFT(rot,values(:,ind),'keepPlan',varargin{:});
  end
  SO3FunHarmonic.adjointNFSOFT(rotation.id,1,'killPlan');
  SO3F = reshape(SO3F, s);
  return
end

% kill plan
if check_option(varargin,'killPlan')
  nfsoftmex('finalize',keepPlanNSOFT);
  keepPlanNSOFT = [];
  return
end



% --------------- (1) get weights and values for quadrature ---------------

if isa(rot,'quadratureSO3Grid')
  N = rot.bandwidth;
  nodes = rot.nodes;
  W = rot.weights;
else
  N = get_option(varargin,'bandwidth', getMTEXpref('maxSO3Bandwidth'));
  nodes = rot;
  W = get_option(varargin,'weights',1);
end

if isa(nodes,'orientation')
  SRight = nodes.CS; SLeft = nodes.SS;
  if rot.antipodal, rot.antipodal = 0; varargin{end+1} = 'antipodal'; end
else
  [SRight,SLeft] = extractSym(varargin);
  nodes = orientation(nodes,SRight,SLeft);
end

% check for Inf-values (quadrature fails)
if any(isinf(values))
  error('There are poles at some quadrature nodes.')
end
if any(isnan(values))
  warning('There are Nan values in some nodes. They are set to 0.')
  values(isnan(values)) = 0;
end

if isempty(nodes)
  SO3F = SO3FunHarmonic(0,SRight,SLeft);
  return
end

% -------------------------- (2-4) Adjoint NFSOFT -------------------------

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
  nfsoft_flags = bitor(2^4,2^0)+2^2;
  % nfft cutoff - 4
  % fpt kappa - 1000
  % fftw_size -> 2*ceil(1.5*L)
  % initialize nfsoft plan
  plan = nfsoftmex('init',N,length(nodes),nfsoft_flags,0,4,1000,2*ceil(1.5*N));
  
  % set rotations in Euler angles (nodes)
  nfsoftmex('set_x',plan,Euler(nodes(:),'nfft').');
  
  % node-dependent precomputation
  nfsoftmex('precompute',plan);

end

if check_option(varargin,'createPlan')
  keepPlanNSOFT = plan;
  SO3F=[];
  return
end

% adjoint nfsoft
nfsoftmex('set_f', plan, W(:) .* values(:));
nfsoftmex('adjoint', plan);
% get fourier coefficients from plan and normalize
fhat = nfsoftmex('get_f_hat', plan)*(sqrt(8)*pi);

% kill plan
if check_option(varargin,'keepPlan')
  keepPlanNSOFT = plan;
else
  nfsoftmex('finalize', plan);
end

% ------------------- (5) Construct SO3FunHarmonic ------------------------

SO3F = SO3FunHarmonic(fhat,SRight,SLeft);

% if antipodal consider only even coefficients
SO3F.antipodal = check_option(varargin,'antipodal');

end