function omega = angle(gB,dir,varargin)
% angle of the brain boundary segment to another segment or direction
%
% Syntax
%   kappa = angle(gB1,gB2)
%   kappa = curvature(gB,dir)
%   kappa = curvature(gB,dir,'antipodal')
%
% Input
%  gB1, gB2 - @grainBoundary
%  dir - @vector3d
%
% Output
%  omega - angle between 0 and 2*pi
%

if isa(dir,'grainBoundary'), dir = dir.direction; end

omega = angle(gB.direction,dir,gB.N);
