function sF = quadrature(f, varargin)
%
% Syntax
%  sF = S2FunHarmonic.quadrature(nodes,values,'weights',w)
%  sF = S2FunHarmonic.quadrature(f)
%  sF = S2FunHarmonic.quadrature(f, 'bandwidth', bandwidth)
%
% Input
%  values - double
%  nodes - @vector3d
%  f - function handle in vector3d
%
% Options
%  bandwidth - minimal degree of the spherical harmonic (default: 128)
%

bandwidth = get_option(varargin, 'bandwidth', 128);
if isa(f,'function_handle')
  if check_option(varargin, 'gauss')
    [nodes, W] = quadratureS2Grid(2*bandwidth, 'gauss');
  else
    [nodes, W] = quadratureS2Grid(2*bandwidth);
  end
  values = f(nodes(:));
else
  nodes = f(:);
  values = varargin{1}(:);
  W = get_option(varargin,'weights',1);
end

% initialize nfsft
nfsft('precompute', bandwidth, 1000, 1, 0);
plan = nfsft('init_advanced', bandwidth, length(nodes), 1);
nfsft('set_x', plan, [nodes.rho'; nodes.theta']); % set vertices
nfsft('precompute_x', plan);

% adjoint nfsft
nfsft('set_f', plan, W(:) .* values);
nfsft('adjoint', plan);
fhat = nfsft('get_f_hat_linear', plan);

% finalize nfsft
nfsft('finalize', plan);

sF = S2FunHarmonic(fhat);
sF.bandwidth = bandwidth;

% if antipodal consider only even coefficients
if check_option(varargin,'antipodal') || nodes.antipodal 
  sF = sF.even;
end

end
