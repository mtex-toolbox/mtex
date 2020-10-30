function sF = calcDensity(v,varargin)
% calculate a density function out of (weighted) unit vectors
%
% Syntax
%
%   sF = calcDensity(v)
%   sF = calcDensity(v,'weights',w)
%   sF = calcDensity(v,'halfwidth',delta)
%   sF = calcDensity(v,'kernel',psi)
%    f = calcDensity(v,S2G)
%
% Input
%  v   - sampling points for density estimation @vector3d
%  S2G - @vector3d
%  w   - weights, default is all one
%  delta - halfwidth of the kernel, default is 10 degree
%  psi - @kernel function, default is de la Vallee Poussin
%
% Output
%  sF  - @S2Fun
%   f  - function values
%
% Options
%  halfwidth - halfwidth of a kernel
%  kernel    - specify a kernel
%  weights   - vector of weights, with same length as v
%

% determine kernel function
hw = get_option(varargin,'halfwidth',10*degree);
psi = get_option(varargin,'kernel',S2DeLaValleePoussin('halfwidth',hw));

% ignore nans
v = subSet(v,~isnan(v));

sF = 4*pi * S2FunHarmonic.quadrature(v,ones(size(v)),varargin{:});

% normalize
if ~check_option(varargin,'noNormalization')
  sF = sqrt(4*pi) * sF ./ sF.fhat(1);
end

% convolute with kernel function
sF = conv(sF,psi);

% if required compute function values
if nargin > 1 && isa(varargin{1},'vector3d')
  sF = sF.eval(varargin{1});
end

end