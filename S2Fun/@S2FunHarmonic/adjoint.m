function sF = adjoint(v,y, varargin)
% Compute the adjoint S2-Fourier transform of given evaluations on a 
% specific quadrature grid.
% 
% This method uses an adjoint bivariate nfft/fft and an adjoint coefficient 
% transform which is based on a representation property of the Wigner-d 
% functions.
% Hence it do not use the NFSFT (which includes a fast polynom transform) 
% as in the older method |S2FunHarmonic.adjointNFSFT|.
%
% Syntax
%   sF = S2FunHarmonic.adjoint(vec,values)
%   sF = S2FunHarmonic.adjoint(vec,values,'bandwidth',32,'weights',w)
%
% Input
%  vec    - @vector3d, @quadratureS2Grid,
%  values - double
%
% Output
%  sF - @S2FunHarmonic
%
% Options
%  bandwidth - maximal harmonic degree (default: 512)
%  weights   - quadrature weights
%
% Flags
%  'nfsft'             - use (mostly slower) NFSFT algorithm
%  'directComputation' - direct evaluation of Fourier sums (no nfft)
%
% See also
% S2FunHarmonic/quadrature S2FunHarmonic/adjointNFSFT 
% S2FunHarmonic/approximate S2FunHarmonic/interpolate


% Use NFSFT of nfft toolbox
if ~check_option(varargin,'nfft')
  sF = S2FunHarmonic.adjointNFSFT(v,y,varargin{:});
  return
end

persistent keepPlanNFFT;

% kill plan
if check_option(varargin,'killPlan') 
  if isempty(keepPlanNFFT), return, end
  nfftmex('finalize',keepPlanNFFT);
  keepPlanNFFT = [];
  sF=[];
  return
end

% get plotting convention
how2plot = getClass(varargin,'plottingConvention',v.how2plot);

% multivariate case
y = reshape(y,length(v),[]);
len = size(y,2);
sz = size(y);


% -------------- (1) get weights and values for quadrature ----------------

if v.antipodal 
  v.antipodal = 0; 
  varargin{end+1} = 'antipodal'; 
end

if isa(v,'quadratureS2Grid')
  N = v.bandwidth;
  W = v.weights;
else
  N = get_option(varargin,'bandwidth', getMTEXpref('maxS2Bandwidth'));
  v = v(:);  
  W = get_option(varargin,'weights',1);
end


% check for Inf-values (quadrature fails)
if any(isinf(y(:)))
  ind = isinf(y);
  m = max( abs(y(~ind)) ,[],'all')*1e+10;
  y(ind) = sign(y(ind)) .* m;
  warning(['There are poles at some quadrature nodes. They are set to +-',num2str(m,3),'.'])
  % error('There are poles at some quadrature nodes.')
end
if any(isnan(y(:)))
  warning('There are Nan values in some nodes. They are set to 0.')
  y(isnan(y)) = 0;
end

if isempty(v)
  sF = S2FunHarmonic(0);
  sF.how2plot = how2plot;
  return
end
if N==0
  sF = S2FunHarmonic(mean(y)*sqrt(4*pi));
  sF.how2plot = how2plot;
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
if isempty(plan) && ~(isa(v,'quadratureS2Grid') && strcmp(v.scheme,'ClenshawCurtis')) && ~check_option(varargin,'directComputation')

  % nfft size
    NN = 2*N+2;
  % {FFTW_ESTIMATE} or 64 - Specifies that, instead of actual measurements of different algorithms, 
  %                         a simple heuristic is used to pick a (probably sub-optimal) plan quickly. 
  %                         It is the default value
  % {FFTW_MEASURE} or 0   - tells FFTW to find an optimized plan by actually computing several FFTs and 
  %                         measuring their execution time. This can take some time (often a few seconds).
    fftw_flags = int8(64);
    nfft_flags = 1+2^12+2^4+2^10; % PRE_PHI_HUT | NFFT_OMP_BLOCKWISE_ADJOINT | PRE_PSI | FFTW_INIT
  % nfft_cutoff parameter
    m = get_option(varargin,'cutoffParameter',4);
  % oversampling factor
    sigma = 3;
    fftw_size = 2*ceil(sigma/2*NN);
  % initialize nfft plan
  plan = nfftmex('init_guru',{2,NN,NN,length(v),fftw_size,fftw_size,m,nfft_flags,fftw_flags});

  % set vector3d as nodes in plan
  [theta,rho] = polar(v(:));
  tr = [theta,rho].'./(2*pi);
  nfftmex('set_x',plan,tr);

  % node-dependent precomputation
  nfftmex('precompute_psi',plan);

  if check_option(varargin,'createPlan')
    keepPlanNFFT = plan;
    sF=[];
    return
  end

end

% use trivariate inverse equispaced fft in case of Clenshaw Curtis
% quadrature grid and nfft otherwise 
% TODO: Do FFT x NFFT x FFT in case of GaussLegendre-Quadrature
if isa(v,'quadratureS2Grid') && strcmp(v.scheme,'ClenshawCurtis')

  % Possibly use smaller input matrix by using the symmetries
  if len==1
    ghat = ifft2( W.* reshape(y,[size(W),1]) ,4*N,2*N+2);
    ghat = ifftshift(ghat);
  else % multivariate
    ghat = ifft(ifft(W.*reshape(y,[size(W),len]),4*N,1),2*N+2,2);
    ghat = ifftshift(ifftshift(ghat,1),2);
  end

  ghat = 4*N*(2*N+2) * ghat(N+1:3*N+1,2:end,:);
  ghat = permute(ghat,[2,1,3]);

elseif check_option(varargin,'directComputation')

  % Do adjoint nsoft directly by evaluating the sum
  ghat = zeros(2*N+1,2*N+1,len);

  for m = 1:length(v)
    ghat = ghat + W(m)*y(m)* exp(1i* ( (-N:N)'*v.rho(m) + (-N:N)*v.theta(m) ));
  end

else

  ghat = zeros((2*N+2)^2,len);
  for m=1:len
    nfftmex('set_f', plan, W(:) .* y(:,m));
    nfftmex('adjoint', plan);
    % adjoint Fourier transform
    ghat(:,m) = nfftmex('get_f_hat', plan);
  end
  ghat = reshape(ghat,2*N+2,2*N+2,len);
  ghat = ghat(2:end,2:end,:);

end

% shift grid
z = (1i).^(-N:N).';
ghat = z .* ghat;


% --------------------- (3) adjoint Wigner transform ----------------------


% set flags
flags = [1,0,0,0,0]; % use L2-normalized Wigner-D functions

% TODO: Probably use limit 1e-5 because this is precision m of nfft
if isalmostreal(y,'precision',10,'norm',1)
  flags(3) = 1; % f real valued
end
if v.antipodal || check_option(varargin,'antipodal')
  flags(4) = 1;% f antipodal
end

% use adjoint Wigner transform
fhat = zeros((N+1)^2,len);
flagsMEX = bin2dec(sprintf('%d',flip(flags)));
for m = 1:len
  fhat(:,m) = sphericalHarmonicTrafoAdjointmex(N,ghat(:,:,m),flagsMEX,[1,1]);
end

if flags(3)
  for n=2:N
    ind = n^2+1 : (n+1)^2;
    A = fhat(ind,:);
    fhat(ind,:) = A + (A==0).*conj(flip(A,1)); 
  end 
end


% kill plan
if check_option(varargin,'keepPlan')
  keepPlanNFFT = plan;
elseif ~isempty(plan)
  nfftmex('finalize', plan);
end

% ------------------- (4) Construct S2FunHarmonic ------------------------

sF = S2FunHarmonic(fhat,varargin{:});
sF = reshape(sF,sz(2:end));
sF.how2plot = how2plot;

end