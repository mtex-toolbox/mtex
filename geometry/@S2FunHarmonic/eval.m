function f =  eval(sF,v)
% evaluates the spherical harmonic on a given set of points
% Syntax
%  f = eval(sF,v)
%
% Input
%  v - @vector3d interpolation nodes 
%

s = size(v);
v = v(:);
M = sqrt(length(sF.fhat))-1;
if M == 0
  f = sF.fhat*ones(size(v));
  return;
end

% initialize nfsft
nfsft('precompute', M, 1000, 1, 0);
plan = nfsft('init_advanced', M, length(v), 1);
nfsft('set_x', plan, [v.rho'; v.theta']); % set vertices
nfsft('precompute_x', plan);

% nfsft
nfsft('set_f_hat_linear', plan, sF.fhat); % set fourier coefficients
nfsft('trafo', plan);
f = real(nfsft('get_f', plan));
f = real(reshape(f, s));

% finalize nfsft
nfsft('finalize', plan);

end
