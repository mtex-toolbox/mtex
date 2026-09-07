function d = double(E,varargin)
% coordinates of an embedding in an orthonormal basis of the space it moves in
%
% Syntax
%   d = double(E)          % isometric coordinates, one row per element
%   d = double(E,'full')   % every tensor component, one row per element
%
% Input
%  E - @embedding
%
% Output
%  d - double, n x dim(E) or n x sum(3^rank)
%
% See also
% embedding/setDouble

d = flatten(E).';
if ~check_option(varargin,'full'), d = d * E.B; end

end
