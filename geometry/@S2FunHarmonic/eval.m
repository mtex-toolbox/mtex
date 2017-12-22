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
if sF.bandwidth == 0
  f = sF.fhat*ones(size(v));
  return;
end

% initialize nfsft
nfsft('precompute', sF.bandwidth, 1000, 1, 0);
plan = nfsft('init_advanced', sF.bandwidth, length(v), 1);
nfsft('set_x', plan, [v.rho'; v.theta']); % set vertices
nfsft('precompute_x', plan);

f = zeros([numel(sF) length(v)]);
for j = 1:numel(sF)
  % nfsft
  fhat = subsref(sF, [substruct('()', {j}), substruct('.', 'fhat')]);

  nfsft('set_f_hat_linear', plan, fhat); % set fourier coefficients
  nfsft('trafo', plan);
  f(j, :) = real(nfsft('get_f', plan));
end
f = reshape(f, [size(sF) s]);

% finalize nfsft
nfsft('finalize', plan);

end
