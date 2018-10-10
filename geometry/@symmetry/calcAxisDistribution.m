function x = calcAxisDistribution(cs,varargin)
% compute the axis distribution of an uniform ODF or MDF
%
% Syntax
%   value = calcAxisDistribution(cs,a)
%   adf = calcAxisDistribution(cs)
%
% Input
%  cs - @crystalSymmetry
%  h  - @vector3d
%  
% Output
%  value - values of the axis distribution function at axes a
%  adf - axes distribution function @S2Fun
% See also

if nargin > 1 && isa(varargin{1},'vector3d')
  varargin = delete_option(varargin,'complete');
  [oR,dcs,nSym] = fundamentalRegion(cs,varargin{:});
  h = varargin{1};
  h = project2FundamentalRegion(h,dcs);
  omega = oR.maxAngle(h);
  x = nSym * (omega - sin(omega)) ./ pi;
else
  f = @(h) calcAxisDistribution(cs,h,varargin{:});  
  x = S2FunHarmonicSym.quadrature(f,cs,'bandwidth',128,varargin{:});
end
