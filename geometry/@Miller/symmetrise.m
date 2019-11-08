function varargout = symmetrise(m,varargin)
% directions symmetrically equivalent to m
%
% Syntax
%   m = symmetrise(m) % @Miller indices symmetrically equivalent to m
%
% Input
%  m - @Miller
%
% Output
%  v - @Miller
%
% Options
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%  skipAntipodal - do not include antipodal symmetry

[varargout{1:nargout}] = symmetrise(vector3d(m),m.CS,varargin{:});

[m.x,m.y,m.z] = double(varargout{1});
varargout{1} = m;
