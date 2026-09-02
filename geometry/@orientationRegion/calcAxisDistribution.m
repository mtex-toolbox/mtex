function x = calcAxisDistribution(oR,h,varargin)
% compute the axis distribution of an uniform ODF or MDF
%
% Input
%  oR - @orientationRegion
%  h  - @vector3d
%
% Output
%  x   - values of the axis distribution
%
% Options
%  minAngle - ignore rotations by less than this angle
%  maxAngle - ignore rotations by more than this angle
%
% See also
% SO3Fun/calcAxisDistribution symmetry/calcAxisDistribution

[a,b] = angleWindow(oR,h,varargin{:});

x = (b - a - sin(b) + sin(a)) ./ 2;
