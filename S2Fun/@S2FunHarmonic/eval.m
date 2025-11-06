function f = eval(sF,v,varargin)
% point-wise evaluation 
%
% Description
% Evaluates the spherical function $f$ on a given set of points using a
% representation based coefficient transform, that transforms 
% a series of spherical harmonics into a bivariate Fourier series and using
% NFFT at the end.
%
% Syntax
%   f = eval(sF,v)
%
% Input
%  sF - @S2FunHarmonic
%  v - @vector3d (evaluation nodes)
%
% Output
%  f - double [numrot x size(sF)]
%
% Options
%  bandwidth - cut bandwidth of the harmonic series in evaluation process
%
% Flags
%  nfsft - use Nonequispace Fast Fourier Transform of the NFFT3 Toolbox (expensive precomputations)
%  noNFFT - do direct evaluation of the harmonic series for every vector3d (Works for very high bandwidth if the nfft runs out of memory, but gets expensive for many vector3ds. Hence number of vector3ds should be less than 100)
%
% See also
% S2FunHarmonic/evalNFSFT

% TODO: adjoint method and quadrature

if ~check_option(varargin,'nfft')
  f = evalNFSFT(sF,v,varargin{:});
  return
end

% change evaluation method for quadratureS2Grid
if isa(v,'quadratureS2Grid') && strcmp(v.scheme,'ClenshawCurtis')
  f = evalEquispacedFFT(sF,v,varargin{:});
  return
end

% Do direct computation for small number of vector3d's
maxBW = 3*getMTEXpref('maxS2Bandwidth');
if sF.bandwidth<maxBW && (length(v)<50 || check_option(varargin,'noNFFT'))
  varargin{end+1} = 'direct';
elseif sF.bandwidth>maxBW || check_option(varargin,'noNFFT')
  f = directEval(sF,v,varargin{:});
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

if isempty(v), f = []; return; end

v = v(:);
M = length(v);

if sF.bandwidth == 0
  f = ones(size(v)) .* sF.fhat /sqrt(pi)/2;
  return;
end

% extract bandwidth
N = min(sF.bandwidth,get_option(varargin,'bandwidth',inf));

% theta,rho
[theta,rho] = polar(v);
tr = [theta,rho].'./(2*pi);

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlanNFFT;
else
  plan = [];
end

if isempty(plan)

  % TODO: Heuristic for selection of oversampling Factor sigma and cut-off Parameter m

  % nfft size
    N1 = 2*N+2;
    N2 = 2*N+2;
    if sF.isReal
      N2 = N+1+mod(N+1,2); 
    end
  % {FFTW_ESTIMATE} or 64 - Specifies that, instead of actual measurements of different algorithms, 
  %                         a simple heuristic is used to pick a (probably sub-optimal) plan quickly. 
  %                         It is the default value
  % {FFTW_MEASURE} or 0   - tells FFTW to find an optimized plan by actually computing several FFTs and 
  %                         measuring their execution time. This can take some time (often a few seconds).
    fftw_flags = int8(64);
    nfft_flags = 1+2^12+2^4+2^10; % PRE_PHI_HUT | NFFT_OMP_BLOCKWISE_ADJOINT | PRE_PSI | FFTW_INIT
  % nfft_cutoff parameter 
    m = get_option(varargin,'cutoffParameter',6);
  % oversampling factor
    sigma = 2;
    fftw_size1 = 2*ceil(sigma/2*N1);
    fftw_size2 = 2*ceil(sigma/2*N2);
  % initialize nfft plan
  if check_option(varargin,'direct')
    plan = nfftmex('init_2d',N1,N2,M);
  else
    plan = nfftmex('init_guru',{2,N1,N2,M,fftw_size1,fftw_size2,m,nfft_flags,fftw_flags});
  end
  
  % set rotations as nodes in plan
  nfftmex('set_x',plan,tr);

  % node-dependent precomputation
  nfftmex('precompute_psi',plan);

end

if check_option(varargin,'createPlan')
  keepPlanNFFT = plan;
  f=[];
  return
end

% If sF is real valued we have the symmetry properties (*) and (**) for
% the Fourier coefficients. We will use this to speed up computation.
flags = 2^0+2^1;
if sF.isReal
  flags = flags + 2^2;
end
if sF.antipodal
  flags = flags + 2^3;
end

f = zeros([length(v) size(sF)]);
for k = 1:length(sF)

  % coefficient transform
  ghat = sphericalHarmonicTrafo(sF.subSet(k),flags,'bandwidth',N); % ghat ist genau gleich
  % set Fourier coefficients
  nfftmex('set_f_hat',plan,ghat(:));

  if check_option(varargin,'direct')
    % direct Fourier transform
    nfftmex('trafo_direct',plan);
  else
    % Fast Fourier transform
    nfftmex('trafo',plan);
  end

  % get function values from plan
  if sF.isReal
    % use (**) and shift summation in 2nd index
    f(:,k) = 2*real( exp(-1i*v.rho*ceil((N)/2))  .* (nfftmex('get_f',plan)) );
  else
    f(:,k) = nfftmex('get_f',plan);
  end
end


% kill plan
if check_option(varargin,'keepPlan')
  keepPlanNFFT = plan;
else
  nfftmex('finalize',plan);
end

end



function f = directEval(sF,v,varargin)

N = sF.bandwidth;
[theta,rho] = polar(v);
flags = 0;

for k=1:length(sF)
  if sF.subSet(k).isReal, flags = flags + 2^2; end
  if sF.subSet(k).antipodal, flags = flags + 2^3; end
  ghat = sphericalHarmonicTrafo(sF.subSet(k),2^0+flags,'bandwidth',N);
  for m=1:length(v)
    if sF.isReal
      f(m,k) = sum(ghat.*exp(-1i*theta(m)*(-N:N)-1i*rho(m)*(0:N)'),"all");
    else
      f(m,k) = sum(ghat.*exp(-1i*theta(m)*(-N:N)-1i*rho(m)*(-N:N)'),"all");
    end
  end
end

if sF.isReal
  f = 2*real(f);
end

end
