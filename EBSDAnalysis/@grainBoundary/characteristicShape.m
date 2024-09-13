function cShape = characteristicShape(gB,varargin)
% derive characteristic shape from a set of grain boundaries
%
% Syntax
%
%   cshape = characteristicShapeN(grains.boundary('b','b'))
%
% Input
%  gB   -  @grainBoundary 
%
% Output
%  cShape - @shape2d
%

cShape = shape2d.byFV(gB.F, gB.allV, varargin{:});

% set normal vector
cShape.N = gB.N;

end
