function f =  eval(sF,v)
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

v = v(:);
if sF.bandwidth == 0
  f = ones(size(v)).*sF.fhat/sqrt(4*pi);
  return;
end

% initialize nfsft
nfsftmex('precompute', sF.bandwidth, 1000, 1, 0);
plan = nfsftmex('init_advanced', sF.bandwidth, length(v), 1);
nfsftmex('set_x', plan, [v.rho'; v.theta']); % set vertices
nfsftmex('precompute_x', plan);

f = zeros([length(v) size(sF)]);
% nfsft
for j = 1:length(sF)
  nfsftmex('set_f_hat_linear', plan, sF.fhat(:,j)); % set fourier coefficients
  nfsftmex('trafo', plan);
  f(:,j) = reshape(real(nfsftmex('get_f', plan)),[],1);
end

% set values to NaN
f(isnan(v),:) = NaN;

% finalize nfsft
nfsftmex('finalize', plan);

end
