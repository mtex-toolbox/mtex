function b = eq(v1,v2,varargin)
% ? v1 == v2
%
%% Input
%  v1, v2 - @vector3d
%
%% Output
%  b - boolean
%
%% Options
%  antipodal - include antipodal symmetry
%

b = isnull(angle(v1,v2,varargin{:}));
