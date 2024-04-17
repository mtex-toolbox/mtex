function f = eval(SO3F,rot,varargin)
% pointwise evaluation 
%
% Description
% Evaluates the orientation dependent function $f$ on a given set of points using a
% representation based coefficient transform, that transforms 
% a series of Wigner-D functions into a trivariate fourier series and using
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
abg = (abg + [0.25;0;-0.25]);
abg = mod(abg,1);

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
  plan = nfftmex('init_guru',{3,N2,NN,NN,M,fftw_size2,fftw_size,fftw_size,m,nfft_flag,fftw_flag});

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

f = zeros([length(rot) size(SO3F)]);
for k = 1:length(SO3F)

  % If SO3F is real valued we have the symmetry properties (*) and (**) for 
  % the Fourier coefficients. We will use this to speed up computation.
  if SO3F.isReal

    % ind = mod(N+1,2);
    % create ghat -> k x j x l
    %   k = -N+1:N
    %   j = -N+1:N      -> use ghat(k,-j,l) = (-1)^(k+l)*ghat(k,j,l)    (*)
    %   l =    0:N+ind  -> use ghat(-k,-j,-l) = conj(ghat(k,j,l))      (**)
    % we need to make the size (2N+2)^3 as the index set of the NFFT is -(N+1) ... N 
    % Therfore we use ind in 2nd dimension to get even number of fourier coefficients
    % The additional indices produce 0-columns in front of ghat
    % flags: 2^0 -> use L_2-normalized Wigner-D functions
    %        2^1 -> make size of result even
    %        2^2 -> fhat are the fourier coefficients of a real valued function
    %        2^4 -> use right and left symmetry
    flags = 2^0+2^1+2^2+2^4;
    sym = [min(SO3F.SRight.multiplicityPerpZ,2),SO3F.SRight.multiplicityZ,...
         min(SO3F.SLeft.multiplicityPerpZ,2),SO3F.SLeft.multiplicityZ];
    ghat = representationbased_coefficient_transform(N,SO3F.fhat(:,k),flags,sym);
    ghat = symmetriseFourierCoefficients(ghat,flags,SO3F.SRight,SO3F.SLeft,sym);
%     ghat = representationbased_coefficient_transform_old(N,SO3F.fhat(:,k),2^0+2^1+2^2);

  else

    % create ghat -> k x j x l
    % we need to make the size (2N+2)^3 as the index set of the NFFT is -(N+1) ... N
    % we can use (*) again to speed up
    % flags: 2^0 -> use L_2-normalized Wigner-D functions
    %        2^1 -> make size of result even
    %        2^4 -> use right and left symmetry
    flags = 2^0+2^1+2^4;
    sym = [min(SO3F.SRight.multiplicityPerpZ,2),SO3F.SRight.multiplicityZ,...
         min(SO3F.SLeft.multiplicityPerpZ,2),SO3F.SLeft.multiplicityZ];
    ghat = representationbased_coefficient_transform(N,SO3F.fhat(:,k),flags,sym);
    ghat = symmetriseFourierCoefficients(ghat,flags,SO3F.SRight,SO3F.SLeft,sym);
%     ghat = representationbased_coefficient_transform_old(N,SO3F.fhat(:,k),2^1+2^2);

  end

  % set Fourier coefficients
  nfftmex('set_f_hat',plan,ghat(:));

  % fast fourier transform
  nfftmex('trafo',plan);

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