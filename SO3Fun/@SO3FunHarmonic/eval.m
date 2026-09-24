function f = eval(SO3F,rot,varargin)
% point-wise evaluation 
%
% Description
% Evaluates the orientation dependent function $f$ on a given set of points using a
% representation based coefficient transform, that transforms 
% a series of Wigner-D functions into a trivariate Fourier series and using
% NFFT at the end.
%
% Syntax
%   f = eval(SO3F,rot)
%
% Input
%  SO3F - @SO3FunHarmonic
%  rot - @rotation (evaluation nodes)
%
% Output
%  f - double [numrot × size(SO3F)]
%
% Options
%  bandwidth - cut bandwidth of the harmonic series in evaluation process
%  cutoffParameter - NFFT window cutoff m (default: 6 for few nodes on a large lattice, 4 otherwise)
%  oversampling - NFFT oversampling factor sigma (default: 1.25 for few nodes on a large lattice, 2 otherwise)
%
% Flags
%  nfsoft - use Nonequispace Fast Fourier Transform of the NFFT3 Toolbox (expensive precomputations)
%  noNFFT - do direct evaluation of the harmonic series for every orientation (Works for very high bandwidth if the nfft runs out of memory, but gets expensive for many orientations. Hence number of orientations should be less than 100)
%
% See also
% SO3FunHarmonic/evalNFSOFT SO3FunHarmonic/evalEquispacedFFT SO3FunHarmonic.SO3FunHarmonic

if check_option(varargin,'nfsoft')
  f = evalNFSOFT(SO3F,rot,varargin{:});
  return
end

% if isa(rot,'orientation')
%   ensureCompatibleSymmetries(F,rot)
% end

% change evaluation method for quadratureSO3Grid
if isa(rot,'quadratureSO3Grid') && strcmp(rot.scheme,'ClenshawCurtis')
  f = evalEquispacedFFT(SO3F,rot,varargin{:});
  return
end

% Do direct computation for small number of orientations
maxBW = 3*getMTEXpref('maxSO3Bandwidth');
if SO3F.bandwidth<maxBW && (length(rot)<50 || check_option(varargin,'noNFFT'))
  varargin{end+1} = 'direct';
elseif SO3F.bandwidth>maxBW || check_option(varargin,'noNFFT')
  f = directEval(SO3F,rot,varargin{:});
  return
end

persistent keepPlanNFFT;

% kill plan
if check_option(varargin,'killPlan')
  nfftmex('finalize',keepPlanNFFT);
  keepPlanNFFT = [];
  f=[];
  return
end

if isempty(rot), f = []; return; end

s = size(rot);
rot = rot(:);
M = length(rot);

if SO3F.bandwidth == 0
  f = ones(size(rot)) .* SO3F.fhat;
  if isscalar(SO3F), f = reshape(f,s); end
  return;
end

% extract bandwidth
N = min(SO3F.bandwidth,get_option(varargin,'bandwidth',inf));

% alpha, beta, gamma
abg = Euler(rot,'nfft').'./(2*pi);

% a non finite node makes nfft write outside its buffers and crash MATLAB, so
% replace it by a valid one and set its function value to NaN afterwards
isBadNode = any(~isfinite(abg),1);
abg(:,isBadNode) = 0;

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlanNFFT;
else
  plan = [];
end

% frequencies of the dimensions of the Fourier array ghat, dimension 3 is
% halved for real valued functions - but a plan that is kept for later
% functions has to take complex ones without symmetries
kept = check_option(varargin,{'createPlan','keepPlan'});
realF = SO3F.isReal;
isReal = realF && ~kept;
NN = 2*N+2;
k1 = -(N+1):N;
if isReal, N2 = N+1+mod(N+1,2); k3 = (1:N2) - N2 + N; else, k3 = k1; end

% ghat is only occupied at the multiples of the rotational symmetries around
% the Z-axis, so these rows are kept and the nodes are stretched instead
rZ = [1,1];
if SO3F.SRight.id~=0 && SO3F.SLeft.id~=0 && ~kept
  rZ = [SO3F.SRight.multiplicityZ,SO3F.SLeft.multiplicityZ];
end
[ind1,s3,abg(3,:)] = foldZ(k1,rZ(1),abg(3,:));
[ind3,s1,abg(1,:)] = foldZ(k3,rZ(2),abg(1,:));
sz = [2*ceil(numel(ind1)/2),NN,2*ceil(numel(ind3)/2)];

if isempty(plan)

  % {FFTW_ESTIMATE} or 64 - Specifies that, instead of actual measurements of different algorithms,
  %                         a simple heuristic is used to pick a (probably sub-optimal) plan quickly.
  %                         It is the default value
  % {FFTW_MEASURE} or 0   - tells FFTW to find an optimized plan by actually computing several FFTs and
  %                         measuring their execution time. This can take some time (often a few seconds).
    fftw_flags = int8(64);
    nfft_flags = 1+2^12+2^10+2^13; % PRE_PHI_HUT | NFFT_OMP_BLOCKWISE_ADJOINT | FFTW_INIT | NFFT_PRUNED_FFT
    % PRE_PSI pays only for a plan that is kept for later functions
    if kept, nfft_flags = nfft_flags + 2^4; end
  % window cutoff m and oversampling sigma: few nodes on a large lattice spend
  % the time in the FFT, many nodes in the window sums
    [m,sigma] = nfftParameters(M,sz,varargin{:});
    fftw_size = fftLength(sigma*sz);
  % initialize nfft plan
  if check_option(varargin,'direct')
    plan = nfftmex('init_3d',sz(3),sz(2),sz(1),M);
  else
    plan = nfftmex('init_guru',{3,sz(3),sz(2),sz(1),M,fftw_size(3),fftw_size(2),fftw_size(1),m,nfft_flags,fftw_flags});
  end

  % set rotations as nodes in plan
  nfftmex('set_x',plan,double(abg));

  % node-dependent precomputation
  nfftmex('precompute_psi',plan);

end

if check_option(varargin,'createPlan')
  keepPlanNFFT = plan;
  f=[];
  return
end

% the kept frequencies start at index 0, which shifts them by s against the
% centered frequencies of the nfft
shift = exp(-2*pi*1i*(s1*abg(1,:)+s3*abg(3,:))).';

f = zeros([length(rot) size(SO3F)]);
for k = 1:length(SO3F)

  % the Fourier coefficients straight on the nfft lattice
  g = foldedWignerTrafo(SO3F.fhat(:,k),N,isReal,rZ);

  % set Fourier coefficients
  nfftmex('set_f_hat',plan,g(:));

  if check_option(varargin,'direct')
    % direct Fourier transform
    nfftmex('trafo_direct',plan);
  else
    % Fast Fourier transform
    nfftmex('trafo',plan);
  end

  % get function values from plan, using (**) if SO3F is real valued
  if isReal
    f(:,k) = 2*real(shift .* nfftmex('get_f',plan));
  else
    f(:,k) = shift .* nfftmex('get_f',plan);
  end
end
if realF, f = real(f); end


% kill plan
if check_option(varargin,'keepPlan')
  keepPlanNFFT = plan;
else
  nfftmex('finalize',plan);
end

% restore the non finite nodes
f(isBadNode,:) = NaN;

% reshape output
if isscalar(SO3F), f = reshape(f,s); end

end



function f = directEval(SO3F,rot,varargin)

N = SO3F.bandwidth;
abg = Euler(rot,'Matthies')';
if SO3F.isReal
  for k=1:length(SO3F)
    ghat = wignerTrafo(SO3F.subSet(k),2^0+2^2+2^4,'bandwidth',N);
    for m=1:length(rot)
      f(m,k) = sum(ghat.*exp(-1i*abg(2,m)*(-N:N)-1i*abg(3,m)*(-N:N)'-1i*abg(1,m)*reshape(0:N,1,1,[])),"all");
    end
  end
  f = 2*real(f);
else
  for k=1:length(SO3F)
    ghat = wignerTrafo(SO3F.subSet(k),2^0+2^4,'bandwidth',N);
    for m=1:length(rot)
      f(m,k) = sum(ghat.*exp(-1i*abg(2,m)*(-N:N)-1i*abg(3,m)*(-N:N)'-1i*abg(1,m)*reshape(-N:N,1,1,[])),"all");
    end
  end
end
  
% reshape output
if isscalar(SO3F)
  f = reshape(f,size(rot)); 
else
  f = reshape(f,[numel(rot) size(SO3F)]);
end

end
