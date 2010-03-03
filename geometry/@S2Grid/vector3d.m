function v = vector3d(S2G,varargin)
% converts points to vector3d
%% Input
%  S2G    - @S2Grid
%  indece - theta,rho (optional)
%% Output
%  @vector3d

v = S2G.vector3d(varargin{:});
