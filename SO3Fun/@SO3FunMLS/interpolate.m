function SO3F = interpolate(varargin)
% Approximate an SO3FunMLS by given function values at given nodes
%
% Syntax
%   SO3F = SO3FunRBF.interpolate(nodes,y)
%
% Input
%  nodes - rotational grid @SO3Grid, @orientation, @rotation
%  y     - function values on the grid (maybe multidimensional) or empty
%
% Output
%  SO3F  - @SO3FunMLS
%
% See also
% rotation/interp SO3FunHarmonic/interpolate

% run constructor
SO3F = SO3FunMLS(varargin{:});

end

