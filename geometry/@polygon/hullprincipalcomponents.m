function [cmp v]= hullprincipalcomponents(p)
% returns the principalcomponents of convexhull
%
%% Input
%  grains - @grain
%
%% Output
%  cmp   - angle of components as complex
%  v     - length of axis
%
%% See also
% grain/principalcomponents grain/plotellipse
%

[cmp v] = principalcomponents(convhull(p));