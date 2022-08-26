function m = perp(m,varargin)
% best normal to a list of directions
%
% Syntax
%   n = perp(d)
%
% Input
%  d - list of @Miller
%
% Output
%  n - @Miller

m = Miller(perp@vector3d(m,varargin{:}),m.CS,MillerConvention(-MillerConvention(m.dispStyle)));

end
