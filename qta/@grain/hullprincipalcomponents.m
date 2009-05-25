function [cmp v]= hullprincipalcomponents(grains)
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

[cmp v] = principalcomponents(grains,'hull');