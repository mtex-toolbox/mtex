function  omega = maxAngle(cs,varargin)
% get the maximum angle of the fundamental region
%
% Syntax
%   omega = maxAngle(cs1)
%   omega = maxAngle(cs1,cs2)
%   omega = maxAngle(cs1,axis)
%
% Input
%  cs1, cs2 - @symmetry
%  axis - axis(@vector3d) of rotation
%

oR = cs.fundamentalRegion(varargin{:});

omega = oR.maxAngle(cs,varargin{:});

