function sF = approximation(v, y, varargin)
% computes a least square problem to get an approximation
% Syntax
%  sF = sphFunHarmonic.approximation(S2Grid, f)
%  sF = sphFunHarmonic.approximation(S2Grid, f, 'm', M, 'tol', TOL, 'maxit', MAXIT, 'weights', W)
%
% Input
%  S2Grid - grid on the sphere
%  f      - function values on the grid
%
% Options
%  M     - maximum degree of the spherical harmonics used to approximate the function
%  TOL   - tolerance for lsqm
%  MAXIT - maximum number of iterations for lsqm
%  W     - weight w_n for the node v_n (default: voronoi weights)
%

[v, IA] = unique(v); v = v(:);
y = y(IA); y = y(:);

tol = get_option(varargin, 'tol', 1e-6);
maxit = get_option(varargin, 'maxit', 40);

if check_option(varargin, 'antipodal')
	if check_option(varargin, 'weights')
		W = get_option(varargin, 'weights');
	else
		[v2, IA] = unique([v; -v]); 
		W = v2.calcVoronoiArea; % Voronoi weights for symmetrized grid
		W = W(IA <= length(v)); % going back to originally grid (without antipodal doublings)
		y = [y; y];
		y = y(IA(IA <= length(v)));
		v = v2(IA <= length(v));
	end
	M = get_option(varargin, 'm', ceil(sqrt(length(v))));
	M = floor(M/2)*2; % make M even
	mask = sparse((M+1)^2); % only use even polynomial degree
	for m = 0:2:M
		mask((m^2+1):(m^2+2*m+1), (m^2+1):(m^2+2*m+1)) = speye(2*m+1);
	end
else
	M = get_option(varargin, 'm', ceil(sqrt(length(v)/2)));
	W = get_option(varargin, 'weights', v.calcVoronoiArea);
	mask = speye((M+1)^2);
end

% initialize nfsft
nfsft('precompute', M, 1000, 1, 0);
plan = nfsft('init_advanced', M, length(v), 1);
nfsft('set_x', plan, [v.rho'; v.theta']); % set vertices
nfsft('precompute_x', plan);

y = W.*y;

% adjoint nfsft
nfsft('set_f', plan, y);
nfsft('adjoint', plan);
b = nfsft('get_f_hat_linear', plan);

[fhat, flag, relres, iter] = lsqr(...
	@(x, transp_flag) afun(transp_flag, x, plan, W, M, mask), ...
	b, tol, maxit);
fhat = mask*fhat;

% finalize nfsft
nfsft('finalize', plan);

sF = sphFunHarmonic(fhat);

end



function y = afun(transp_flag, x, plan, W, M, mask)
if strcmp(transp_flag, 'transp')

	x = mask*x;

%	conjunct nfsft
	nfsft('set_f_hat_linear', plan, conj(x));
	nfsft('trafo', plan);
	f = conj(nfsft('get_f', plan));

	f = f.*W;

%	transposed nfsft
	nfsft('set_f', plan, f);
	nfsft('adjoint', plan);
	y = conj(nfsft('get_f_hat_linear', plan));

	y = mask*y;

elseif strcmp(transp_flag, 'notransp')

	x = mask*x;

%	nfsft
	nfsft('set_f_hat_linear', plan, x);
	nfsft('trafo', plan);
	f = nfsft('get_f', plan);

	f = f.*W;

%	adjoint nfsft
	nfsft('set_f', plan, f);
	nfsft('adjoint', plan);
	y = nfsft('get_f_hat_linear', plan);

	y = mask*y;

end
end
