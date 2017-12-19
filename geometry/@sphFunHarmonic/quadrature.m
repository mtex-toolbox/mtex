function sF = quadrature(f, varargin)
%
% Syntax
%  sF = sphFunHarmonic.quadrature(nodes,values,'weights',w)
%  sF = sphFunHarmonic.quadrature(f)
%  sF = sphFunHarmonic.quadrature(f, 'm', M)
%
% Input
%  values - double
%  nodes - @vector3d
%  f - function handle in vector3d
%
% Options
%  M - minimal degree of the spherical harmonic (default: 128)
%

M = get_option(varargin, 'm', 128);
if isa(f,'function_handle')
  if check_option(varargin, 'gauss')
    [nodes, W] = quadratureS2Grid(2*M, 'gauss');
  else
    [nodes, W] = quadratureS2Grid(2*M);
  end
  values = f(nodes(:));
else
  nodes = f(:);
  values = varargin{1}(:);
  W = get_option(varargin,'weights',1);
end

% initialize nfsft
nfsft('precompute', M, 1000, 1, 0);
plan = nfsft('init_advanced', M, length(nodes), 1);
nfsft('set_x', plan, [nodes.rho'; nodes.theta']); % set vertices
nfsft('precompute_x', plan);

% adjoint nfsft
nfsft('set_f', plan, W(:) .* values);
nfsft('adjoint', plan);
fhat = nfsft('get_f_hat_linear', plan);

% finalize nfsft
nfsft('finalize', plan);

sF = sphFunHarmonic(fhat);
sF.M = M;

% if antipodal consider only even coefficients
if check_option(varargin,'antipodal') || nodes.antipodal 
  sF = sF.even;
end

end
