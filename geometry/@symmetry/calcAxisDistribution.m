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
% Options
%  minAngle - ignore rotations by less than this angle
%  maxAngle - ignore rotations by more than this angle
%
% Description
% The angle window works exactly as in <SO3Fun.calcAxisDistribution.html
% SO3Fun/calcAxisDistribution>, so this stays the uniform reference a
% restricted MDF can be compared against.
%
% See also
% SO3Fun/calcAxisDistribution

[oR,dcs,nSym] = fundamentalRegion(cs,varargin{:});
varargin = delete_option(varargin,'complete');
if ~isempty(varargin) && isa(varargin{1},'symmetry'), varargin(1) = []; end
  

if ~isempty(varargin) && isa(varargin{1},'vector3d')

  x = getValue(varargin{1});
  
else
  
  f = @(h) getValue(h);
  x = S2FunHarmonicSym.quadrature(f,dcs,'bandwidth',256,varargin{:});
  
end

function value = getValue(h)
  h = project2FundamentalRegion(h,dcs);
  maxOmega = oR.maxAngle(h);

  % the requested angle window, clipped to the fundamental region
  a = min(max(get_option(varargin,'minAngle',0),0),maxOmega);
  b = max(min(get_option(varargin,'maxAngle',inf),maxOmega),a);

  % 2/pi * int_a^b sin(omega/2)^2 domega, per symmetry element
  value = nSym * (b - a - sin(b) + sin(a)) ./ pi;
end

end