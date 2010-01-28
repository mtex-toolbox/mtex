function d = dot_outer(rot1,rot2,varargin)
% dot_outer
%
%% Input
%  rot1, rot2 - @rotatiom
%
%% Output
%  

d = abs(dot_outer(quaternion(rot1),quaternion(rot2),varargin{:}));
