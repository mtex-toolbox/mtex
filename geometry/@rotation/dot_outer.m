function d = dot_outer(rot1,rot2,varargin)
% dot_outer
%
% Input
%  rot1, rot2 - @rotation
%
% Output
%  d - double length(rot1) x length(rot2)

d = abs(dot_outer(quaternion(rot1),quaternion(rot2),varargin{:}));
