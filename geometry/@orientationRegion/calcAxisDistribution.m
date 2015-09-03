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
% See also


omega = oR.maxAngle(h);
x = (omega - sin(omega)) ./ 2;
