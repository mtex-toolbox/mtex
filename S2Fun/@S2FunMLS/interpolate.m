function S2F = interpolate(varargin)
% Approximate an S2FunMLS by given function values at given nodes
%
% Syntax
%   S2F = S2FunMLS.interpolate(nodes,y)
%
% Input
%  nodes - spherical grid @vector3d, @S2Grid
%  y     - function values on the grid (maybe multidimensional) or empty
%
% Output
%  S2F   - @S2FunMLS
%
% See also
% S2FunMLS S2FunHarmonic/interpolate

% run constructor
S2F = S2FunMLS(varargin{:});

end
