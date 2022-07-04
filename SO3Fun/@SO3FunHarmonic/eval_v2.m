function f = eval_v2(SO3F,rot,varargin)
% evaluates the rotational harmonic on a given set of points using a
% representation based coefficient transform, that transforms 
% a series of Wigner-D functions into a trivariate fourier series and using
% NFFT at the end.
%
% Syntax
%   f = eval(F,v)
%
% Input
%   F - @SO3FunHarmonic
%   v - @rotation interpolation nodes
%
% Output
%   f - double
%

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
  if numel(SO3F) == 1, f = reshape(f,s); end
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

  % initialize nfft plan
  %plan = nfftmex('init_3d',2*N+2,2*N+2,2*N+2,M);
  NN = 2*N+2;
  if SO3F.isReal, N2 = N+1+mod(N+1,2); else, N2=2*N+2; end
  FN = ceil(1.5*NN);
  FN2 = ceil(1.5*N2);
  % {FFTW_ESTIMATE} or 64 - Specifies that, instead of actual measurements of different algorithms, 
  %                         a simple heuristic is used to pick a (probably sub-optimal) plan quickly. 
  %                         It is the default value
  % {FFTW_MEASURE} or 0   - tells FFTW to find an optimized plan by actually computing several FFTs and 
  %                         measuring their execution time. This can take some time (often a few seconds).
  fftw_flag = int8(64);
  plan = nfftmex('init_guru',{3,N2,NN,NN,M,FN2,FN,FN,4,int8(0),fftw_flag});

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
    % create ghat -> k x l x j
    %   k = -N+1:N
    %   l =    0:N+ind    -> use ghat(-k,-l,-j)=conj(ghat(k,l,j))        (*)
    %   j = -N+1:N        -> use ghat(k,l,-j)=(-1)^(k+l)*ghat(k,l,j)     (**)
    % we need to make the size (2N+2)^3 as the index set of the NFFT is -(N+1) ... N 
    % Therfore we use ind in 2nd dimension to get even number of fourier coefficients
    % The additional indices produce 0-columns in front of ghat
    % flags: 2^0 -> fhat are the fourier coefficients of a real valued function
    %        2^1 -> make size of ghat even
    %        2^2 -> use L_2-normalized Wigner-D functions
    flags = 2^0+2^1+2^2;
    ghat = representationbased_coefficient_transform(N,SO3F.fhat(:,k),flags);

  else

    % create ghat -> k x l x j
    % we need to make the size (2N+2)^3 as the index set of the NFFT is -(N+1) ... N
    % we can use (**) again to speed up
    % flags: 2^1 -> make size of ghat even
    %        2^2 -> use L_2-normalized Wigner-D functions
    flags = 2^1+2^2;
    ghat = representationbased_coefficient_transform(N,SO3F.fhat(:,k),flags);

  end

  % set Fourier coefficients
  nfftmex('set_f_hat',plan,ghat(:));

  % fast fourier transform
  nfftmex('trafo',plan);

  % get function values from plan
  if SO3F.isReal
    % use (*) and shift summation in 2nd index
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

if numel(SO3F) == 1, f = reshape(f,s); end

end