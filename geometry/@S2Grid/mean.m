function m = mean(S2G,varargin)
% computes the mean vector 
%
%% Input
%  v - @vector3d
%
%% Output
%  m - @vector3d
%
%% Options
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
% 

m = mean(vector3d(S2G),varargin{:});
