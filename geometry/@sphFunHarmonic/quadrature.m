function sF = quadrature(f, varargin)
%
%  fun = sphFunHarmonic.quadrature(S2Grid, f)
%

M = get_option(varargin, 'm', 100);
if check_option(varargin, 'gauss')
	[v, W] = quadratureS2Grid(2*M, 'gauss');
else
	[v, W] = quadratureS2Grid(2*M);
end

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

sF = sphFunHarmonic(fhat, varargin{:});

end
