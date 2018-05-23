function sF = calcDensity(h,varargin)
% calculate a density function out of (weighted) crystal directions
%
% Syntax
%
%   sF = calcDensity(h)
%   sF = calcDensity(h,'weights',w)
%   sF = calcDensity(h,'halfwidth',delta)
%   sF = calcDensity(h,'kernel',psi)
%    f = calcDensity(h,S2G)
%
% Input
%  h   - list of crystal directions @Miller
%  S2G - @vector3d
%  w   - weights, default is all one
%  delta - halfwidth of the kernel, default is 10 degree
%  psi - @kernel function, default is de la Vallee Poussin
%
% Output
%  sF  - @S2FunHarmonicSym
%   f  - function values
%
% Options
%  halfwidth - halfwidth of a kernel
%  kernel    - specify a kernel
%  weights   - vector of weights, with same length as v
%

hw = get_option(varargin,'halfwidth',10*degree);
psi = get_option(varargin,'kernel',deLaValeePoussinKernel('halfwidth',hw));

sF = 4*pi * S2FunHarmonic.quadrature(h,ones(size(h)),varargin{:});

% normalize
if ~check_option(varargin,'noNormalization')
  sF = sqrt(4*pi) * sF ./ sF.fhat(1);
end

% convolute with kernel function
sF = conv(sF,psi);

% symmetrise with respect to crystal symmetry
sF = sF.symmetrise(h.CS);

% if required compute function values
if nargin > 1 && isa(varargin{1},'vector3d')
  sF = sF.eval(varargin{1});
end

end