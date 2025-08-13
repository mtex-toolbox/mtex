function SO3F = adjoint(rot,values, varargin)
% Compute the adjoint SO(3)-Fourier/Wigner transform of given evaluations 
% on specific nodes.
%
% This method uses an adjoint trivariate nfft/fft and an adjoint coefficient 
% transform which is based on a representation property of the Wigner-D 
% functions.
% Hence it do not use the NFSOFT (which includes a fast polynom transform) 
% as in the older method |SO3FunHarmonic.adjointNFSOFT|.
%
% Syntax
%   SO3F = SO3FunHarmonic.adjoint(rot,values)
%   SO3F = SO3FunHarmonic.adjoint(rot,values,'bandwidth',32,'weights',w)
%
% Input
%  rot  - @quadratureSO3Grid, @rotation, @orientation, @SO3Grid
%  values - double
%
% Output
%  SO3F - @SO3FunHarmonic
%
% Options
%  bandwidth - maximal harmonic degree (default: 64)
%  weights   - quadrature weights
%  cutOffParameter - set parameter precision parameter m for nfft
%
% Flags
%  'nfsoft'            - use (mostly slower) NFSOFT algorithm
%  'directComputation' - direct evaluation of Fourier sums (no nfft)
%  'createPlan'        - NFFT3-Flags
%  'keepPlan'          - NFFT3-Flags
%  'deletePlan'        - NFFT3-Flags
%
% See also
% SO3FunHarmonic/quadrature SO3FunHarmonic/adjointNFSOFT
% SO3FunHarmonic/approximate SO3FunHarmonic/interpolate



% Use NFSOFT of nfft3 toolbox
if check_option(varargin,'nfsoft')
  SO3F = SO3FunHarmonic.adjointNFSOFT(rot,values,varargin{:});
  return
end

persistent keepPlanNFFT;

% kill plan
if check_option(varargin,'killPlan') 
  if isempty(keepPlanNFFT), return, end
  nfftmex('finalize',keepPlanNFFT);
  keepPlanNFFT = [];
  SO3F=[];
  return
end


% Multivariate functions
% if length(rot)~=numel(values)
%   s = size(values); s = s(2:end);
%   values = reshape(values,length(rot),[]);
%   SO3FunHarmonic.adjoint(rot,values(:,1),'createPlan',varargin{:});
%   SO3F = [];
%   for ind = 1:prod(size(values,2))
%     G = SO3FunHarmonic.adjoint(rot,reshape(values(:,ind),size(rot)),'keepPlan',varargin{:});
%     SO3F = [SO3F,G];
%   end
%   SO3FunHarmonic.adjoint(rotation.id,1,'killPlan');
%   SO3F = reshape(SO3F, s);
%   return
% end

% -------------- (1) get weights and values for quadrature ----------------

sz = size(values);
len = prod(sz(2:end)); % multivariate case
values = reshape(values,[],len);

if isa(rot,'orientation')
  SRight = rot.CS; SLeft = rot.SS;
  if rot.antipodal, rot.antipodal = 0; varargin{end+1} = 'antipodal'; end
else
  [SRight,SLeft] = extractSym(varargin);
  rot = orientation(rot,SRight,SLeft);
end

if isa(rot,'quadratureSO3Grid') 
  %  TODO: Multivariate quadratureSO3Grid
  N = rot.bandwidth;
  if strcmp(rot.scheme,'ClenshawCurtis')
    values = reshape(values(rot.iuniqueGrid,:),[size(rot.iuniqueGrid) size(values,2)]);
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

  % nfft size
    NN = 2*N+2;
  % {FFTW_ESTIMATE} or 64 - Specifies that, instead of actual measurements of different algorithms, 
  %                         a simple heuristic is used to pick a (probably sub-optimal) plan quickly. 
  %                         It is the default value
  % {FFTW_MEASURE} or 0   - tells FFTW to find an optimized plan by actually computing several FFTs and 
  %                         measuring their execution time. This can take some time (often a few seconds).
    fftw_flag = int8(64);
    nfft_flag = int8(0);
  % nfft_cutoff parameter
    m = get_option(varargin,'cutoffParameter',4);
  % oversampling factor
    sigma = 3;
    fftw_size = 2*ceil(sigma/2*NN);
  % initialize nfft plan
  plan = nfftmex('init_guru',{3,NN,NN,NN,length(rot),fftw_size,fftw_size,fftw_size,m,nfft_flag,fftw_flag});

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
  if len==1
    ghat = ifftn( W.* reshape(values,[size(W),len]) ,[2*N+2,4*N,2*N+2]);
    ghat = ifftshift(ghat);
  else % multivariate
    ghat = ifft(ifft(ifft(W.*reshape(values,[size(W),len]),2*N+2,1),4*N,2),2*N+2,3);
    ghat = ifftshift(ifftshift(ifftshift(ghat,1),2),3);
  end

  ghat = 16*N*(N+1)^2 * ghat(2:end,N+1:3*N+1,2:end,:);

elseif check_option(varargin,'directComputation')
  % TODO: use symmetries
  
  % Do adjoint nsoft directly by evaluating the sum
  nodes = Euler(rot(:),'nfft').';
  ghat = zeros(2*N+1,2*N+1,2*N+1,len);

  for m = 1:length(rot)
    ghat = ghat + reshape(values(m,:),1,1,1,[]).*exp(1i * ( ...
      (-N:N)*nodes(2,m) ...
      + (-N:N)'*nodes(3,m) ...
      + permute(-N:N,[1,3,2])*nodes(1,m)) );
  end

else

  % adjoint nfft
  ghat = zeros(8*(N+1)^3,len);
  for i=1:len
    nfftmex('set_f', plan, W(:) .* values(:,i));
    nfftmex('adjoint', plan);
    % adjoint Fourier transform
    ghat(:,i) = nfftmex('get_f_hat', plan);
  end
  ghat = reshape(ghat,2*N+2,2*N+2,2*N+2,len);
  ghat = ghat(2:end,2:end,2:end,:);

end

% --------------------- (3) adjoint Wigner transform ----------------------

% shift rotational grid
z = (1i).^(reshape(-N:N,1,1,[]) - (-N:N).');
ghat = z .* ghat;

% set flags and symmetry axis
if SLeft.id==0 || SRight.id==0 % do not use symmetry properties, if symmetries are not standardized
  flags = 2^0;  % use L2-normalized Wigner-D functions
else
  flags = 2^0+2^4;  % use L2-normalized Wigner-D functions and symmetry properties
end
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
% use adjoint Wigner transform
fhat = zeros(deg2dim(N+1),len);
for i=1:len
  progress(i,len)
  fhat(:,i) = wignerTrafoAdjointmex(N,ghat(:,:,:,i),flags,sym);
end
fhat = symmetriseWignerCoefficients(fhat,flags,SRight,SLeft,sym);

% kill plan
if check_option(varargin,'keepPlan')
  keepPlanNFFT = plan;
elseif ~isempty(plan)
  nfftmex('finalize', plan);
end

% ------------------- (4) Construct SO3FunHarmonic ------------------------

SO3F = SO3FunHarmonic(fhat,SRight,SLeft,varargin{:});
SO3F = reshape(SO3F,sz(2:end));

% if antipodal consider only even coefficients
SO3F.antipodal = check_option(varargin,'antipodal');

end