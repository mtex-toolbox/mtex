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
  omega = min(pi-oR.N.angle);
end
