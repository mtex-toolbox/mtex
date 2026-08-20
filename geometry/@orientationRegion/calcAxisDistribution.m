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

maxOmega = oR.maxAngle(h);

% the requested angle window, clipped to what the region holds for each axis
a = min(max(get_option(varargin,'minAngle',0),0),maxOmega);
b = max(min(get_option(varargin,'maxAngle',inf),maxOmega),a);

x = (b - a - sin(b) + sin(a)) ./ 2;
