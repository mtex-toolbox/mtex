function f =  eval(sF,v)
% evaluates the spherical harmonic on a given set of points
% Syntax
%  f = eval(sF,v)
%
% Input
%  v - @vector3d interpolation nodes 
%

v = v(:);
if sF.bandwidth == 0
size(sF.fhat)
size(v)
  f = ones(size(v)).*sF.fhat;
  return;
end

% initialize nfsft
nfsft('precompute', sF.bandwidth, 1000, 1, 0);
plan = nfsft('init_advanced', sF.bandwidth, length(v), 1);
nfsft('set_x', plan, [v.rho'; v.theta']); % set vertices
nfsft('precompute_x', plan);

f = zeros([length(v) size(sF)]);
% nfsft
for j = 1:length(sF)
  nfsft('set_f_hat_linear', plan, sF.fhat(:,j)); % set fourier coefficients
  nfsft('trafo', plan);
  f(:,j) = reshape(real(nfsft('get_f', plan)),[],1);
end

% finalize nfsft
nfsft('finalize', plan);

end
