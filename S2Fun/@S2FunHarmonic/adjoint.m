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
%  bandwidth - maximal harmonic degree (default: getMTEXpref('defaultS2Bandwidth'))
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
if check_option(varargin,'nfsft')
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

% the frame of the result: an explicit frame wins, then an explicit convention,
% then the frame of the nodes
fr = getClass(varargin,'referenceFrame');
if isempty(fr)
  pC = getClass(varargin,'plottingConvention');
  if ~isempty(pC)
    fr = specimenSymmetry.frameFor(pC);
  else
    fr = getFrame(v);
  end
end
applyFrame = isempty(getClass(varargin,'symmetry')) && ~isempty(fr);

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
  N = get_option(varargin,'bandwidth', getMTEXpref('defaultS2Bandwidth'));
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
  if applyFrame, sF = setFrame(sF,fr); end
  return
end
if N==0
  sF = S2FunHarmonic(mean(y)*sqrt(4*pi));
  if applyFrame, sF = setFrame(sF,fr); end
  return
end

% -------------------- (2) Adjoint trivariate NFFT/FFT --------------------

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlanNFFT;
else
  plan = [];
end

% real values take the real nfft, which gives the orders k2 >= 0, if nfftmex
% has real plans
realN = isreal(y) && isreal(W) && ~check_option(varargin,{'createPlan','keepPlan'}) && nfftReal;

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
    nfft_flags = 1+2^12+2^10+2^13; % PRE_PHI_HUT | NFFT_OMP_BLOCKWISE_ADJOINT | FFTW_INIT | NFFT_PRUNED_FFT
  % nfft cutoff and oversampling, the pair S2FunHarmonic/eval uses
    m = get_option(varargin,'cutoffParameter',6);
    sigma = get_option(varargin,'oversampling',2);
    fftw_size = fftLength(sigma*NN);
  % initialize nfft plan
  plan = nfftmex('init_guru',{2,NN,NN,length(v),fftw_size,fftw_size,m,nfft_flags+realN*2^14,fftw_flags});

  % set vector3d as nodes in plan, a non finite one as 0 with value 0
  [tr,isBadNode] = nfftNodesmex(double(v.x),double(v.y),double(v.z));
  y(isBadNode,:) = 0;
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
% TODO: Do FFT × NFFT × FFT in case of GaussLegendre-Quadrature
if isa(v,'quadratureS2Grid') && strcmp(v.scheme,'ClenshawCurtis')

  % every inverse FFT keeps only the frequencies -N:N, rho first
  ghat = ifft((4*N*(2*N+2)) * W .* reshape(y,[size(W),len]),2*N+2,2);
  ghat = ifft(ghat(:,mod(-N:N,2*N+2)+1,:),4*N,1);
  ghat = permute(ghat(mod(-N:N,4*N)+1,:,:),[2,1,3]);

elseif check_option(varargin,'directComputation')

  % Do adjoint nsoft directly by evaluating the sum
  [theta,rho] = polar(v(:));
  ghat = pagemtimes(exp(1i*(-N:N).'*rho.'), reshape(W(:).*y,[],1,len) .* exp(1i*theta*(-N:N)));

else

  ghat = zeros(2*N+1,2*N+1,len);
  for m=1:len
    nfftmex('set_f', plan, double(W(:) .* y(:,m)));
    nfftmex('adjoint', plan);
    % adjoint Fourier transform, of real values k2 >= 0 and k2 < 0 conjugated at -k1
    if realN
      h = reshape(nfftmex('get_f_hat', plan),N+1,2*N+2);
      ghat(:,:,m) = [conj(h(N+1:-1:2,end:-1:2));h(:,2:end)];
    else
      h = reshape(nfftmex('get_f_hat', plan),2*N+2,2*N+2);
      ghat(:,:,m) = h(2:end,2:end);
    end
  end

end

% shift grid
% as in sphericalHarmonicTrafo: the exact i^k, not exp(k*log(1i))
ipow = [1;1i;-1;-1i];
z = ipow(mod((-N:N).',4)+1);
ghat = z .* ghat;


% --------------------- (3) adjoint Wigner transform ----------------------


% set flags
flags = [1,0,0,0,0]; % use L2-normalized Wigner-D functions

% TODO: Probably use limit 1e-5 because this is precision m of nfft
if isreal(y) || isalmostreal(y,'precision',10,'norm',1)
  flags(3) = 1; % f real valued
end
if v.antipodal || check_option(varargin,'antipodal')
  flags(4) = 1;% f antipodal
end

% use adjoint Wigner transform
fhat = zeros((N+1)^2,len);
flagsMEX = bin2dec(sprintf('%d',flip(flags)));
for m = 1:len
  fhat(:,m) = sphericalHarmonicTrafoAdjointmex(N,double(ghat(:,:,m)),flagsMEX,[1,1]);
end

% the zeros of a real valued function from fhat(n,k) = conj(fhat(n,-k))
if flags(3)
  d = (0:N+1).^2;
  rev = repelem(d(1:end-1)+d(2:end)+1,diff(d)).' - (1:d(end)).';
  fhat = fhat + (fhat==0).*conj(fhat(rev,:));
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
if applyFrame, sF = setFrame(sF,fr); end

end