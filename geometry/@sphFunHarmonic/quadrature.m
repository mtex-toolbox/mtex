function sF = quadrature(f, varargin)
%
%  fun = sphFunHarmonic.quadrature(S2Grid, f)
%

M = get_option(varargin, 'm', 50);
[v, W] = quadratureS2Grid('chebyshev', 2*M);
v = v(:);
y = f(v);

% initialize nfsft
nfsft('precompute', M, 1000, 1, 0);
plan = nfsft('init_advanced', M, length(v), 1);
nfsft('set_x', plan, [v.rho'; v.theta']); % set vertices
nfsft('precompute_x', plan);

y = W.*y;

% adjoint nfsft
nfsft('set_f', plan, y);
nfsft('adjoint', plan);
fhat = nfsft('get_f_hat_linear', plan);

% finalize nfsft
nfsft('finalize', plan);
sF = sphFunHarmonic(fhat);

end
