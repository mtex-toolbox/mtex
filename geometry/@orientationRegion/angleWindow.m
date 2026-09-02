function [a,b] = angleWindow(oR,h,varargin)
% the rotation angles about h that lie in the region, cut to a window
%
% Syntax
%   [a,b] = angleWindow(oR,h)
%   [a,b] = angleWindow(oR,h,'minAngle',20*degree,'maxAngle',40*degree)
%
% Input
%  oR - @orientationRegion
%  h  - @vector3d, rotational axes
%
% Output
%  a, b - the angles about each axis run from a to b, b >= a
%
% See also
% orientationRegion/maxAngle orientationRegion/calcAxisDistribution

maxOmega = oR.maxAngle(h);

a = min(max(get_option(varargin,'minAngle',0),0),maxOmega);
b = max(min(get_option(varargin,'maxAngle',inf),maxOmega),a);

end
