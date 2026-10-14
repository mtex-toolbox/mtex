function varargout = surf(m,cdata,varargin)
% plot RGB colour data on a grid of crystal directions as a surface
%
% The surface is drawn in the spherical projection of the crystal symmetry of m.
%
% Syntax
%
%   h = surf(m,cdata)   % colour the grid m by cdata
%
% Input
%  m     - @Miller, a grid of crystal directions
%  cdata - RGB data, of the size of m by 3
%
% Output
%  h - handle to the graphics objects
%
% See also
% vector3d/surf
%

[varargout{1:nargout}] = surf@vector3d(m,cdata,varargin{:},m.CS,m.CS.how2plot);
