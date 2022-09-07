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

if ~check_option(varargin,'nfsoft')
  SO3F = SO3FunHarmonic.quadratureV2(f,varargin{:});
  return
end


persistent keepPlanNSOFT;

% kill plan
if check_option(varargin,'killPlan')
  nfsoftmex('finalize',keepPlanNSOFT);
  keepPlanNSOFT = [];
  return
end

bw = get_option(varargin,'bandwidth', getMTEXpref('maxSO3Bandwidth'));


if isa(f,'function_handle')
  [SRight,SLeft] = extractSym(varargin);
  f = SO3FunHandle(f,SRight,SLeft);
end

try
  if f.antipodal
    f.antipodal = 0;
    varargin{end+1} = 'antipodal';
  end
end

% 1) compute/get weights and values for quadrature

if isa(f,'SO3Fun')
  
  SLeft = f.SLeft; SRight = f.SRight;

  % Use crystal and specimen symmetries by only evaluating at Clenshaw Curtis 
  % quadrature grid in fundamental region. 
  % Therefore adjust the bandwidth to crystal and specimen symmetry.
  bw = adjustBandwidth(bw,SRight,SLeft);
  [values,nodes,W] = evalOnCCGridUseSymmetries(f,bw,SRight,SLeft);
  alpha = nodes(:,:,:,1); 
  beta = nodes(:,:,:,2); 
  gamma = nodes(:,:,:,3);
  nodes = [alpha(:),beta(:),gamma(:)];

else

  nodes = f(:);
  values = varargin{1}(:);
  W = get_option(varargin,'weights',1);
  W = W(:);

  if isa(nodes,'orientation')
    SRight = nodes.CS; SLeft = nodes.SS;
  else
    [SRight,SLeft] = extractSym(varargin);
  end
  nodes = Euler(nodes,'nfft');

end


if isempty(nodes)
  SO3F = SO3FunHarmonic(0,SRight,SLeft);
  return
end


% 2) Inverse NFSOFT

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
  plan = nfsoftmex('init',bw,size(nodes,1),nfsoft_flags,0,4,1000,2*ceil(1.5*bw));
  
  % set rotations in Euler angles (nodes)
  nfsoftmex('set_x',plan,nodes.');
  
  % node-dependent precomputation
  nfsoftmex('precompute',plan);

end

if check_option(varargin,'createPlan')
  keepPlanNSOFT = plan;
  return
end

s = size(values);
values = reshape(values, size(nodes,1), []);
num = size(values, 2);

fhat = zeros(deg2dim(bw+1), num);
for index = 1:num
  % adjoint nfsoft

  values(isnan(values)) = 0;

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

SO3F = SO3FunHarmonic(fhat,SRight,SLeft);
SO3F.bandwidth = bw;

% if antipodal consider only even coefficients
SO3F.antipodal = check_option(varargin,'antipodal');

end





% --------------------------- functions -----------------------------------

function bw = adjustBandwidth(bw,SRight,SLeft)
  t1=1; t2=2; 
  if SRight.multiplicityPerpZ==1 || SLeft.multiplicityPerpZ==1, t2=1; end
  if SLeft.id==22,  t2=4; end     % 2 | (N+1)
  if SRight.id==22, t1=4; end     % 2 | (N+1)
  while (mod(2*bw+2,SRight.multiplicityZ*t1) ~= 0 || mod(2*bw+2,SLeft.multiplicityZ*t2) ~= 0)
    bw = bw+1;
  end
end