function SO3F = quadratureNFSOFT(f, varargin)
% Compute the SO(3)-Fourier/Wigner coefficients of an given @SO3Fun or
% given evaluations on a specific quadrature grid.
%
% This method evaluates the given SO3Fun on an with respect to symmetries 
% fundamental Region. Afterwards it uses a NFSOFT (which includes a fast
% polynom transform).
% We prefer the faster, simpler and more stable |SO3FunHarmonic.quadrature|
% method.
% 
%
% Syntax
%   SO3F = SO3FunHarmonic.quadratureNFSOFT(nodes,values,'weights',w)
%   SO3F = SO3FunHarmonic.quadrature(f,'nfsoft')
%   SO3F = SO3FunHarmonic.quadrature(f, 'bandwidth', bandwidth,'nfsoft')
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
% See also
% SO3FunHarmonic/quadrature

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
  [nodes,W] = quadratureSO3Grid(2*bw,'ClenshawCurtis',SRight,SLeft,'ABG');
  % Only evaluate unique orientations
  [u,~,iu] = uniqueQuadratureSO3Grid(nodes,bw);
  v = f.eval(u(:));
  values = v(iu(:),:);
  values = reshape(values,[length(nodes),size(f)]);
  [alpha,beta,gamma] = Euler(nodes,'nfft');
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
    [~,~,gMax] = fundamentalRegionEuler(SRight,SLeft,'ABG');
    LCM = lcm((1+double(round(2*pi/gMax/SRight.multiplicityZ) == 4))*SRight.multiplicityZ,SLeft.multiplicityZ);
    while mod(2*bw+2,LCM)~=0
      bw = bw+1;
    end
end