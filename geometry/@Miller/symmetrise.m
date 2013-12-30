function varargout = symmetrise(m,varargin)
% directions symmetrically equivalent to m
%
%% Syntax
%  m = symmetrise(m) - @Miller indice symmetrically equivalent to m
%
%% Input
%  m - @Miller
%
%% Output
%  v - @Miller
%
%% Options
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]

if nargout==2
  [m.vector3d,l] = symmetrise(m.vector3d,m.CS,varargin{:});
  varargout = {m,l};
else
  m.vector3d = symmetrise(m.vector3d,m.CS,varargin{:});
  varargout = {m};
end
