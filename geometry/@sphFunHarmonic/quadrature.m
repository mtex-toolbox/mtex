function sF = quadrature(f, varargin)
%
% Syntax
%  sF = sphFunHarmonic.quadrature(value,v)
%  sF = sphFunHarmonic.quadrature(f)
%  sF = sphFunHarmonic.quadrature(f, 'm', M)
%
% Input
%  value - double
%  v - @vector3d
%  f - function handle in vector3d
%
% Options
%  M - minimal degree of the spherical harmonic (default: 100)
%

M = get_option(varargin, 'm', 128);
if isa(f,'double')
  M2 = 2*M;
  y = f(:);
  v = getClass(varargin,'vector3d'); v = v(:);
else
  if check_option(varargin, 'gauss')
    [v, W, M2] = quadratureS2Grid(2*M, 'gauss');
  else
    [v, W, M2] = quadratureS2Grid(2*M);
  end
  y = W(:).*f(v(:));
end

% initialize nfsft
nfsft('precompute', M, 1000, 1, 0);
plan = nfsft('init_advanced', M, length(v), 1);
nfsft('set_x', plan, [v.rho'; v.theta']); % set vertices
nfsft('precompute_x', plan);

% adjoint nfsft
nfsft('set_f', plan, y);
nfsft('adjoint', plan);
fhat = nfsft('get_f_hat_linear', plan);

% finalize nfsft
nfsft('finalize', plan);

sF = sphFunHarmonic(fhat);
sF.M = M;

% if antipodal consider only even coefficients
if check_option(varargin,'antipodal') || v.antipodal 
  sF = sF.even;
end

end
