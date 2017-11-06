function sF = approximation(v, y, varargin)
%
% computes a least square problem to get an approximation
%  fun = sphFunHarmonic.approximation(S2Grid, f)
%
% available options are:
%  'm' - maximum degree of the spherical harmonics used to approximate the function
%  'tol' - tolerance for lsqm
%  'maxit' - number of iterations for lsqm
%  'weights' - weight w_n for the node v_n
% 

v = v(:);

M = get_option(varargin, 'm', ceil(sqrt(length(v)/2)));
tol = get_option(varargin, 'tol', 1e-6);
maxit = get_option(varargin, 'maxit', 20);
W = get_option(varargin, 'weights', v.calcVoronoiArea);

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

[fhat, flag] = lsqr(@(x, transp_flag)afun(transp_flag, x, plan, W), b, tol, maxit);

% finalize nfsft
nfsft('finalize', plan);
sF = sphFunHarmonic(fhat);

end


function y = afun(transp_flag, x, plan, W)
if strcmp(transp_flag, 'transp')
%	conjunct nfsft
	nfsft('set_f_hat_linear', plan, conj(x));
	nfsft('trafo', plan);
	f = conj(nfsft('get_f', plan));

	f = f.*W;

%	transposed nfsft
	nfsft('set_f', plan, f);
	nfsft('adjoint', plan);
	y = conj(nfsft('get_f_hat_linear', plan));

elseif strcmp(transp_flag, 'notransp')
%	nfsft
	nfsft('set_f_hat_linear', plan, x);
	nfsft('trafo', plan);
	f = nfsft('get_f', plan);

	f = f.*W;

%	adjoint nfsft
	nfsft('set_f', plan, f);
	nfsft('adjoint', plan);
	y = nfsft('get_f_hat_linear', plan);

end
end
