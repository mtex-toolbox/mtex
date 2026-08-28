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
%  psi - @S2Kernel function, default is S2 de la Vallee Poussin
%
% Output
%  sF  - @S2Fun
%   f  - function values
%
% Options
%  halfwidth - halfwidth of a kernel
%  kernel    - specify a S2Kernel
%  weights   - vector of weights, with same length as v
%  noSymmetry - do not symmetrise a density of crystal directions
%

% determine kernel function
hw = get_option(varargin,'halfwidth',10*degree);
psi = get_option(varargin,'kernel',S2DeLaValleePoussinKernel('halfwidth',hw));

% ignore nans
w = get_option(varargin,'weights');
if ~isempty(w)
  varargin = set_option(varargin,'weights',w(~isnan(v)));
end
v = subSet(v,~isnan(v));

sF = 4*pi * S2FunHarmonic.quadrature(v,ones(size(v)),varargin{:});

% normalize
if ~check_option(varargin,'noNormalization')
  sF = sqrt(4*pi) * sF ./ sF.fhat(1);
end

% convolution with kernel function
sF = conv(sF,psi);

% a density of directions is written in their frame, and carries the group
% that frame holds unless that is switched off
if ~isempty(v.frame), sF.frame = v.frame; end

if hasSymmetry(v) && ~check_option(varargin,'noSymmetry')
  sF = S2FunHarmonicSym(sF,v.frame);
  sF = sF.symmetrise;
end

% if required compute function values
if nargin > 1 && isa(varargin{1},'vector3d')
  sF = sF.eval(varargin{1});
end

end