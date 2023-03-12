function f =  eval(F,rot,varargin)
% evaluates the rotational harmonic on a given set of points using NFSOFT
%
% gives a align for numel(F)==1 or otherwise transform the align of v to a
% vector.
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
% See also
% SO3FunHarmonic/evalV2 SO3FunHarmonic/evalEquispacedFFT SO3FunHarmonic/evalSectionsEquispacedFFT

if isa(rot,'orientation')
  ensureCompatibleSymmetries(F,rot)
end

if ~check_option(varargin,'nfsoft')
  f = evalV2(F,rot,varargin{:});
  return
end

persistent keepPlan;

% kill plan
if check_option(varargin,'killPlan')
  nfsoftmex('finalize',keepPlan);
  keepPlan = [];
  return
end

if isempty(rot), f = []; return; end

s = size(rot);
rot = rot(:);

if F.bandwidth == 0
  f = ones(size(rot)) .* F.fhat;
  if numel(F) == 1, f = reshape(f,s); end
  return;
end

% maybe we should set antipodal
F.antipodal = check_option(varargin,'antipodal') || ...
    (isa(rot,'orientation') && rot.antipodal);

% extract bandwidth
L = min(F.bandwidth,get_option(varargin,'bandwidth',inf));
Ldim = deg2dim(double(L+1));

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlan;
else
  plan = [];
end
if isempty(plan)

  % 2^4 -> nfsoft-represent
  % 2^2 -> nfsoft-use-DPT
  % 2^0 -> use normalized Wigner-D functions and fourier coefficients
  nfsoft_flags = bitor(2^4,4)+1;
  % nfft cutoff - 4
  % fpt kappa - 1000
  % fftw_size -> 2*ceil(1.5*L)
  % initialize nfsoft plan
  plan = nfsoftmex('init',L,length(rot),nfsoft_flags,0,4,1000,...
      2*ceil(1.5*L));

  % set rotations in Euler angles (nodes)
  nfsoftmex('set_x',plan,Euler(rot,'nfft').');

  % node-dependent precomputation
  nfsoftmex('precompute',plan);

end

if check_option(varargin,'createPlan')
  keepPlan = plan;
  return
end

f = zeros([length(rot) size(F)]);
for k = 1:length(F)

  % set Fourier coefficients
  nfsoftmex('set_f_hat',plan,reshape(F.fhat(1:Ldim,k),[],1));

  % fast SO(3) fourier transform
  nfsoftmex('trafo',plan);

  % get function values from plan and normalize
  f(:,k) = nfsoftmex('get_f',plan) * (sqrt(8)*pi);

end

% kill plan
if check_option(varargin,'keepPlan')
  keepPlan = plan;
else
  nfsoftmex('finalize',plan);
end

if numel(F) == 1, f = reshape(f,s); end

if F.isReal, f = real(f); end

end