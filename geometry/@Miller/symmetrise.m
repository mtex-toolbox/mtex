function [m,l] = symmetrise(m,varargin)
% directions symmetrically equivalent to m
%
%% Syntax
%  m = symmetrise(m) - @Miller indice symmetrically equivalent to m
%
%% Input
%  m - @Miller
%
%% Output
%  v - @vector3d
%
%% Options
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]

if nargout==2
  [m.vector3d,l] = symmetrise(m.vector3d,m.CS,varargin{:});
else
  m.vector3d = symmetrise(m.vector3d,m.CS,varargin{:});
end
