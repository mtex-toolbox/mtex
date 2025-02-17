function f =  eval(sF,v,varargin)
% evaluates the spherical harmonic on a given set of points
% Syntax
%   f = eval(sF,v)
%
% Input
%   v - @vector3d interpolation nodes 
%
% Output
%   f - double
%

persistent keepPlan;

% kill plan
if check_option(varargin,'killPlan')
  nfsftmex('finalize',keepPlan);
  keepPlan = [];
  return
end

if isempty(v), f=[]; return; end

v = v(:);

if sF.bandwidth == 0
  f = ones(size(v)).*sF.fhat/sqrt(4*pi);
  return;
else
  f = zeros([length(v) size(sF)]); 
end

if size(f,1)==0, return; end

% extract bandwidth
bw = min(sF.bandwidth,get_option(varargin,'bandwidth',inf));

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlan;
else
  plan = [];
end
if isempty(plan)
  nfsftmex('precompute', bw, 1000, 1, 0);
  plan = nfsftmex('init_advanced', sF.bandwidth, length(v), 1);
  [theta,rho] = polar(v);
  nfsftmex('set_x', plan, [rho'; theta']); % set vertices
  nfsftmex('precompute_x', plan);
end
if check_option(varargin,'createPlan')
  keepPlan = plan;
  return
end


% nfsft
for j = 1:length(sF)
  nfsftmex('set_f_hat_linear', plan, sF.fhat(:,j)); % set fourier coefficients
  nfsftmex('trafo', plan);
  f(:,j) = reshape(nfsftmex('get_f', plan),[],1);
end

% kill plan
if check_option(varargin,'keepPlan')
  keepPlan = plan;
else
  nfsftmex('finalize',plan);
end


% set values to NaN
f(isnan(v),:) = NaN;

if isalmostreal(f) 
  f = real(f); 
end


end
