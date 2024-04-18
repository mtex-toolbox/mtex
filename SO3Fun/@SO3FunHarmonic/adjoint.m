function SO3F = adjoint(rot,values, varargin)
% Compute the adjoint SO(3)-Fourier/Wigner transform of given evaluations 
% on specific nodes.
%
% This method uses a inverse trivariate nfft/fft and an adjoint coefficient 
% transform which is based on a representation property of Wigner-D 
% functions.
% Hence it do not use the NFSOFT (which includes a fast polynom transform) 
% as in the older method |SO3FunHarmonic.adjointNFSOFT|.
%
% Syntax
%   SO3F = SO3FunHarmonic.adjoint(rot,values,'bandwidth',32,'weights',w)
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
% SO3FunHarmonic/quadrature SO3FunHarmonic/adjointNFSOFT



% Use NFSOFT of nfft3 toolbox
if check_option(varargin,'nfsoft')
  SO3F = SO3FunHarmonic.adjointNFSOFT(rot,values,varargin{:});
  return
end

persistent keepPlanNFFT;

% Multivariate functions
if length(rot)~=numel(values)
  s = size(values); s = s(2:end);
  values = reshape(values,length(rot),[]);
  SO3FunHarmonic.adjoint(rot,values(:,1),'createPlan',varargin{:});
  SO3F = [];
  for ind = 1:prod(size(values,2))
    G = SO3FunHarmonic.adjoint(rot,reshape(values(:,ind),size(rot)),'keepPlan',varargin{:});
    SO3F = [SO3F,G];
  end
  SO3FunHarmonic.adjoint(rotation.id,1,'killPlan');
  SO3F = reshape(SO3F, s);
  return
end

% kill plan
if check_option(varargin,'killPlan') 
  if isempty(keepPlanNFFT), return, end
  nfftmex('finalize',keepPlanNFFT);
  keepPlanNFFT = [];
  SO3F=[];
  return
end



% -------------- (1) get weights and values for quadrature ----------------

if isa(rot,'orientation')
  SRight = rot.CS; SLeft = rot.SS;
  if rot.antipodal, rot.antipodal = 0; varargin{end+1} = 'antipodal'; end
else
  [SRight,SLeft] = extractSym(varargin);
  rot = orientation(rot,SRight,SLeft);
end

if isa(rot,'quadratureSO3Grid') 
  N = rot.bandwidth;
  if strcmp(rot.scheme,'ClenshawCurtis')
    values = values(rot.iuniqueGrid);
    W = rot.weights;
  else % use unique grid in NFFT in case of Gauss-Legendre quadrature
    if SRight.multiplicityPerpZ*SLeft.multiplicityPerpZ == 1
      GC = 1;
    else
      GC = groupcounts(rot.iuniqueGrid(:));
    end
    W = rot.weights(rot.ifullGrid).*GC;
  end
else
  N = get_option(varargin,'bandwidth', getMTEXpref('maxSO3Bandwidth'));
  W = get_option(varargin,'weights',1);
end

% check for Inf-values (quadrature fails)
if any(isinf(values))
  error('There are poles at some quadrature nodes.')
end
if any(isnan(values))
  warning('There are Nan values in some nodes. They are set to 0.')
  values(isnan(values)) = 0;
end

if isempty(rot)
  SO3F = SO3FunHarmonic(0,SRight,SLeft);
  return
end

% -------------------- (2) Adjoint trivariate NFFT/FFT --------------------

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlanNFFT;
else
  plan = [];
end

% initialize nfft plan
if isempty(plan) && ~(isa(rot,'quadratureSO3Grid') && strcmp(rot.scheme,'ClenshawCurtis')) && ~check_option(varargin,'directComputation')

  %plan = nfftmex('init_3d',2*N+2,2*N+2,2*N+2,M);
  NN = 2*N+2;
  FN = 2*ceil(1.5*NN);
  % {FFTW_ESTIMATE} or 64 - Specifies that, instead of actual measurements of different algorithms, 
  %                         a simple heuristic is used to pick a (probably sub-optimal) plan quickly. 
  %                         It is the default value
  % {FFTW_MEASURE} or 0   - tells FFTW to find an optimized plan by actually computing several FFTs and 
  %                         measuring their execution time. This can take some time (often a few seconds).
  fftw_flag = int8(64);
  plan = nfftmex('init_guru',{3,NN,NN,NN,length(rot),FN,FN,FN,4,int8(0),fftw_flag});

  % set rotations as nodes in plan
  nfftmex('set_x',plan,(Euler(rot(:),'nfft').')/(2*pi));
  % node-dependent precomputation
  nfftmex('precompute_psi',plan);

end

if check_option(varargin,'createPlan')
  keepPlanNFFT = plan;
  SO3F=[];
  return
end

% use trivariate inverse equispaced fft in case of Clenshaw Curtis
% quadrature grid and nfft otherwise 
% TODO: Do FFT x NFFT x FFT in case of GaussLegendre-Quadrature
if isa(rot,'quadratureSO3Grid') && strcmp(rot.scheme,'ClenshawCurtis')

  % Possibly use smaller input matrix by using the symmetries
  ghat = ifftn( W.* reshape(values,size(W)) ,[2*N+2,4*N,2*N+2]);
  ghat = ifftshift(ghat);
  ghat = 16*N*(N+1)^2 * ghat(2:end,N+1:3*N+1,2:end);

elseif check_option(varargin,'directComputation')
  % use symmetries
  
  % Do adjoint nsoft directly by evaluating the sum
  nodes = Euler(rot(:),'nfft').';
  ghat = zeros(2*N+1,2*N+1,2*N+1);
  for m = 1:length(rot)
    ghat = ghat + values(m)*exp(1i * ( ...
                                    (-N:N)*nodes(2,m) ...
                                    + (-N:N)'*nodes(3,m) ...
                                    + permute(-N:N,[1,3,2])*nodes(1,m)) );
  end

else

  % adjoint nfft
  nfftmex('set_f', plan, W(:) .* values(:));
  nfftmex('adjoint', plan);
  % adjoint Fourier transform
  ghat = nfftmex('get_f_hat', plan);
  ghat = reshape(ghat,2*N+2,2*N+2,2*N+2);
  ghat = ghat(2:end,2:end,2:end);

end

% --------------------- (3) shift rotational grid -------------------------

z = (1i).^(reshape(-N:N,1,1,[]) - (-N:N).');
ghat = z .* ghat;

% --------- (4) adjoint representation based coefficient transform ---------

% set flags and symmetry axis
flags = 2^0+2^4;  % use L2-normalized Wigner-D functions and symmetry properties
% TODO: Probably use limit 1e-5 because this is precision m of nfft
if isalmostreal(values,'precision',10,'norm',1) % real valued
  flags = flags+2^2;
end
sym = [min(SRight.multiplicityPerpZ,2),SRight.multiplicityZ,...
       min(SLeft.multiplicityPerpZ,2),SLeft.multiplicityZ];
% if random samples the symmetry properties do not fit
if ~isa(rot,'quadratureSO3Grid') || strcmp(rot.scheme,'GaussLegendre')
  sym([1,3]) = 1;
end
% use adjoint representation based coefficient transform
fhat = adjoint_representationbased_coefficient_transform(N,ghat,flags,sym);
fhat = symmetriseWignerCoefficients(fhat,flags,SRight,SLeft,sym);

% kill plan
if check_option(varargin,'keepPlan')
  keepPlanNFFT = plan;
elseif ~isempty(plan)
  nfftmex('finalize', plan);
end

% ------------------- (5) Construct SO3FunHarmonic ------------------------

SO3F = SO3FunHarmonic(fhat,SRight,SLeft,varargin{:});

% if antipodal consider only even coefficients
SO3F.antipodal = check_option(varargin,'antipodal');

end