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
%
% See also
% ODF/calcAxisDistribution

[oR,dcs,nSym] = fundamentalRegion(cs,varargin{:});
varargin = delete_option(varargin,'complete');
if isa(varargin{1},'symmetry'), varargin(1) = []; end
  

if ~isempty(varargin) && isa(varargin{1},'vector3d')

  x = getValue(varargin{1});
  
else
  
  f = @(h) getValue(h);
  x = S2FunHarmonicSym.quadrature(f,dcs,'bandwidth',256,varargin{:});
  
end

function value = getValue(h)
  h = project2FundamentalRegion(h,dcs);
  omega = oR.maxAngle(h);
  value = nSym * (omega - sin(omega)) ./ pi;
end

end