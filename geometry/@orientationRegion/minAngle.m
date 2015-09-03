function  omega = minAngle(oR,varargin)
% get the minimum angle of the boundary of the fundamental region
%
% Syntax
%   omega = minAngle(oR)
%
% Input
%  oR - @orientationRegion
%

if isempty(oR.N)
  omega = pi;
else
  ind = oR.N.angle < pi - 1e-4;
  omega = min(pi-oR.N(ind).angle);
end
