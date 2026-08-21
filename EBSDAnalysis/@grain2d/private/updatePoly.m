function grains = updatePoly(grains)
% recompute the grain polygons from the current boundary segments
%
% Syntax
%   grains = updatePoly(grains)
%
% Description
% grains.poly holds index lists into grains.allV that have to stay in sync
% with grains.boundary.F, so anything that changes the segment list - refine,
% reduce, simplify - has to retrace the cycles afterwards. Both poly and
% inclusionId are rebuilt.
%
% Input
%  grains - @grain2d
%
% Output
%  grains - @grain2d
%
% See also
% grain2d/simplifyBoundary grain2d/refineBoundary grain2d/reduceBoundary

gB = grains.boundary;

% I_FG has one column per grainId value, so build the incidence against the
% position in this list instead
pos = zeros(max([gB.grainId(:); grains.id(:); 0]),1);
pos(grains.id) = 1:length(grains);

isMember = gB.grainId > 0;
isMember(isMember) = pos(gB.grainId(isMember)) > 0;

iF = repmat((1:size(gB.F,1)).',1,2);
I_FG = logical(sparse(iF(isMember),pos(gB.grainId(isMember)),1, ...
  size(gB.F,1),length(grains)));

[poly,inclusionId] = calcPolygonsC(I_FG,gB.F,grains.allV,grains.N);

grains.poly = reshape(poly,size(grains.id));
grains.inclusionId = reshape(inclusionId,size(grains.id));
