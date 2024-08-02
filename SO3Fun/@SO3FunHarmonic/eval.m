function f = eval(SO3F,rot,varargin)
% pointwise evaluation 
%
% Description
% Evaluates the orientation dependent function $f$ on a given set of points using a
% representation based coefficient transform, that transforms 
% a series of Wigner-D functions into a trivariate Fourier series and using
% NFFT at the end.
%
% Syntax
%   f = eval(F,rot)
%
% Input
%   F - @SO3FunHarmonic
%   rot - @rotation (evaluation nodes)
%
% Output
%   f - double
%
% See also
% SO3FunHarmonic/evalNFSOFT SO3FunHarmonic/evalEquispacedFFT SO3FunHarmonic/evalSectionsEquispacedFFT

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
if length(rot)<10 || (length(rot)<50 && SO3F.bandwidth>200)
  % varargin{end+1} = 'direct';
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

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlanNFFT;
else
  plan = [];
end

if isempty(plan)

  % TODO: Heuristic for selection of oversampling Factor sigma and cut-off Parameter m

  % nfft size
    NN = 2*N+2;
    if SO3F.isReal, N2 = N+1+mod(N+1,2); else, N2=2*N+2; end
  % {FFTW_ESTIMATE} or 64 - Specifies that, instead of actual measurements of different algorithms, 
  %                         a simple heuristic is used to pick a (probably sub-optimal) plan quickly. 
  %                         It is the default value
  % {FFTW_MEASURE} or 0   - tells FFTW to find an optimized plan by actually computing several FFTs and 
  %                         measuring their execution time. This can take some time (often a few seconds).
    fftw_flag = int8(64);
    nfft_flag = int8(0);
  % nfft_cutoff parameter 
    m = 4;
  % oversampling factor
    sigma = 3;
    fftw_size = 2*ceil(sigma/2*NN);
    fftw_size2 = 2*ceil(sigma/2*N2);
  % initialize nfft plan
  if check_option(varargin,'direct')
    plan = nfftmex('init_3d',N2,NN,NN,M);
  else
    plan = nfftmex('init_guru',{3,N2,NN,NN,M,fftw_size2,fftw_size,fftw_size,m,nfft_flag,fftw_flag});
  end
  
  % set rotations as nodes in plan
  nfftmex('set_x',plan,abg);

  % node-dependent precomputation
  nfftmex('precompute_psi',plan);

end

if check_option(varargin,'createPlan')
  keepPlanNFFT = plan;
  f=[];
  return
end

% If SO3F is real valued we have the symmetry properties (*) and (**) for
% the Fourier coefficients. We will use this to speed up computation.
if SO3F.isReal
  flags = 2^0+2^1+2^2+2^4;
else
  flags = 2^0+2^1+2^4;
end

f = zeros([length(rot) size(SO3F)]);
for k = 1:length(SO3F)

  ghat = wignerTrafo(SO3F.subSet(k),flags,'bandwidth',N);

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
  if SO3F.isReal
    % use (**) and shift summation in 2nd index
    f(:,k) = 2*real((exp(-2*pi*1i*ceil(N/2)*abg(1,:).')).*(nfftmex('get_f',plan)));
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

if isscalar(SO3F), f = reshape(f,s); end

end



function f = directEval(SO3F,rot,varargin)

N = SO3F.bandwidth;
abg = Euler(rot,'Matthies')';
if SO3F.isReal
  for k=1:length(SO3F)
    ghat = wignerTrafo(SO3F.subSet(k),2^0+2^2+2^4,'bandwidth',N);
    for i=1:length(rot)
      f(i,k) = sum(ghat.*exp(-1i*abg(2,i)*(-N:N)-1i*abg(3,i)*(-N:N)'-1i*abg(1,i)*reshape(0:N,1,1,[])),"all");
    end
  end
  f = 2*real(f);
else
  for k=1:length(SO3F)
    ghat = wignerTrafo(SO3F.subSet(k),2^0+2^4,'bandwidth',N);
    for i=1:length(rot)
      f(i,k) = sum(ghat.*exp(-1i*abg(2,i)*(-N:N)-1i*abg(3,i)*(-N:N)'-1i*abg(1,i)*reshape(-N:N,1,1,[])),"all");
    end
  end
end
  
  
if isscalar(SO3F), f = reshape(f,size(rot)); end

end
