function SO3F = quadrature(f, varargin)
% Compute the SO(3)-Fourier/Wigner coefficients of an given @SO3Fun or
% given evaluations on a specific quadrature grid.
%
% This method evaluates the given SO3Fun on an with respect to symmetries 
% fundamental Region. Afterwards it uses a inverse trivariate nfft/fft and
% an adjoint coefficient transform which is based on a representation
% property of Wigner-D functions.
% Hence it do not use the NFSOFT (which includes a fast polynom transform) 
% as in the older method |SO3FunHarmonic.quadratureNFSOFT|.
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
%  bandwidth      - minimal harmonic degree (default: 64)
%  ClenshawCurtis - use Clenshaw Curtis quadrature nodes and weights
%
% See also
% SO3FunHarmonic/quadratureNFSOFT

% Tests
% check_SO3FunHarmonicQuadrature

if check_option(varargin,'nfsoft')
  SO3F = SO3FunHarmonic.quadratureNFSOFT(f,varargin{:});
  return
end

N = get_option(varargin,'bandwidth', getMTEXpref('maxSO3Bandwidth'));

try
  if f.antipodal
    f.antipodal = 0;
    varargin{end+1} = 'antipodal';
  end
end


% Get nodes, values and weights for quadrature in case of SO3Fun
if isa(f,'function_handle')
  [SRight,SLeft] = extractSym(varargin);
  f = SO3FunHandle(f,SRight,SLeft);
end
if isa(f,'SO3Fun')
  SLeft = f.SLeft; SRight = f.SRight;
  % Use crystal and specimen symmetries by only evaluating at Clenshaw Curtis 
  % quadrature grid in fundamental region. 
  % Therefore adjust the bandwidth to crystal and specimen symmetry.
  bw = adjustBandwidth(N,SRight,SLeft);
  SO3G = quadratureSO3Grid(bw,'ClenshawCurtis',SRight,SLeft,'ABG');
  % Only evaluate unique orientations
  values = f.eval(SO3G);
  values = reshape(values,[length(SO3G),size(f)]);
  % Do quadrature
  SO3F = SO3FunHarmonic.quadrature(SO3G,values,varargin{:});%,'weights',SO3G.weights,'bandwidth',bw,'ClenshawCurtis');
  SO3F.bandwidth = N;
  return
end





persistent keepPlanNFFT;

% kill plan
if check_option(varargin,'killPlan')
  nfftmex('finalize',keepPlanNFFT);
  keepPlanNFFT = [];
  SO3F=[];
  return
end


% 1) get weights and values for quadrature
if isa(f,'quadratureSO3Grid')
  N = f.bandwidth;
  nodes = f.nodes;
  W = f.weights;
  varargin{end+1} = f.scheme;
else
  nodes = f;
  W = get_option(varargin,'weights',1);
end
values = varargin{1};

if ~check_option(varargin,'ClenshawCurtis')
  nodes = nodes(:);
  values = values(:);
  W = W(:);
end

if isa(nodes,'orientation')
  SRight = nodes.CS; SLeft = nodes.SS;
else
  [SRight,SLeft] = extractSym(varargin);
  nodes = orientation(nodes,SRight,SLeft);
end

% TODO: Look at approximation or interpolation
%   % Speed up for a high number of nodes, by transforming the nodes to an 
%   % equispaced Clenshaw Curtis grid.
%   if length(nodes)>1e7 && length(values) == length(nodes) && length(W)==1
%     warning('There are to many input nodes. Thatswhy an inexact rounded quadrature is used.')
%     [nodes,values] = round2equispacedGrid(nodes,values,N,SRight,SLeft);
%     varargin{end+1} = 'ClenshawCurtis';
%   end


% check for Inf-values (quadrature fails)
if any(isinf(values))
  error('There are poles at some quadrature nodes.')
end

if isempty(nodes)
  SO3F = SO3FunHarmonic(0,SRight,SLeft);
  return
end

% 2) Inverse trivariate NFFT/FFT and representation based wigner transform

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlanNFFT;
else
  plan = [];
end

% initialize nfft plan
if isempty(plan) && ~check_option(varargin,'ClenshawCurtis')

  %plan = nfftmex('init_3d',2*N+2,2*N+2,2*N+2,M);
  NN = 2*N+2;
  FN = 2*ceil(1.5*NN);
  % {FFTW_ESTIMATE} or 64 - Specifies that, instead of actual measurements of different algorithms, 
  %                         a simple heuristic is used to pick a (probably sub-optimal) plan quickly. 
  %                         It is the default value
  % {FFTW_MEASURE} or 0   - tells FFTW to find an optimized plan by actually computing several FFTs and 
  %                         measuring their execution time. This can take some time (often a few seconds).
  fftw_flag = int8(64);
  plan = nfftmex('init_guru',{3,NN,NN,NN,length(nodes),FN,FN,FN,4,int8(0),fftw_flag});

  % set rotations as nodes in plan
  nfftmex('set_x',plan,(Euler(nodes,'nfft').')/(2*pi));
  % node-dependent precomputation
  nfftmex('precompute_psi',plan);

end

if check_option(varargin,'createPlan')
  keepPlanNFFT = plan;
  SO3F=[];
  return
end

s = size(values);
values = reshape(values, prod(size(nodes)), []);
num = size(values, 2);

fhat = zeros(deg2dim(N+1), num);
for index = 1:num
  
  % use trivariate inverse equispaced fft in case of Clenshaw Curtis
  % quadrature grid and nfft otherwise 
  % TODO: Do FFT x NFFT x FFT in case of GaussLegendre-Quadrature
  if check_option(varargin,'ClenshawCurtis')

    % Possibly use smaller input matrix by using the symmetries
    ghat = ifftn( W.* reshape(values(:, index),size(nodes)) ,[2*N+2,4*N,2*N+2]);
    ghat = ifftshift(ghat);
    ghat = 16*N*(N+1)^2 * ghat(2:end,N+1:3*N+1,2:end);

  else
    
    % adjoint nfft
    nfftmex('set_f', plan, W(:) .* values(:, index));
    nfftmex('adjoint', plan);
    % adjoint fourier transform
    ghat = nfftmex('get_f_hat', plan);
    ghat = reshape(ghat,2*N+2,2*N+2,2*N+2);
    ghat = ghat(2:end,2:end,2:end);

  end

  % shift rotational grid
  [~,k,l] = meshgrid(-N:N,-N:N,-N:N);
  ghat = (1i).^(l-k).*ghat;

  % set flags and symmetry axis
  flags = 2^0+2^4;  % use L2-normalized Wigner-D functions and symmetry properties
  % TODO: Probably use limit 1e-5 because this is precision m of nfft
  if isalmostreal(values(:,index),'precision',10,'norm',1) % real valued
    flags = flags+2^2;
  end
  sym = [min(SRight.multiplicityPerpZ,2),SRight.multiplicityZ,...
         min(SLeft.multiplicityPerpZ,2),SLeft.multiplicityZ];
  % if random samples the symmetry properties do not fit
  if ~isa(f,'quadratureSO3Grid')
    sym([1,3])=1;
  end
  % use adjoint representation based coefficient transform
  fhat(:,index) = adjoint_representationbased_coefficient_transform(N,ghat,flags,sym);
  fhat(:,index) = symmetriseWignerCoefficients(fhat(:,index),flags,SRight,SLeft,sym);
%   fhat(:,index) = adjoint_representationbased_coefficient_transform_old(N,ghat,flags);

end

% kill plan
if check_option(varargin,'keepPlan')
  keepPlanNFFT = plan;
elseif ~check_option(varargin, 'ClenshawCurtis')
  nfftmex('finalize', plan);
end

try
  fhat = reshape(fhat, [deg2dim(N+1) s(2:end)]);
end

SO3F = SO3FunHarmonic(fhat,SRight,SLeft,'bandwidth',N);

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
