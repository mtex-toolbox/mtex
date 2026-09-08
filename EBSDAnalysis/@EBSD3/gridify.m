function [ebsdGrid,newId] = gridify(ebsd,varargin)
% put a list of voxels back onto its lattice
%
% A selection from a volume, |ebsd('Quartz')| or |ebsd(condition)|, is a
% list of voxels that still carries the unit cell of the grid it came from.
% This rebuilds that grid: every voxel goes to its lattice cell and the
% cells nobody occupies are padded as not indexed.
%
% Syntax
%   [ebsdGrid,newId] = gridify(ebsd)
%
% Input
%  ebsd - @EBSD3
%
% Output
%  ebsdGrid - @EBSD3square, with |ebsdGrid.pos(newId) == ebsd.pos|
%  newId    - lattice index of every voxel of the list
%
% See also
% EBSD3square EBSD/gridify EBSD3/calcGrains

assert(length(ebsd.unitCell) == 8, ...
  'gridify needs the cuboid unit cell of a voxel grid')

% the three edges of the cell at its first corner: the shortest corner
% differences that are orthogonal to each other
c = reshape(ebsd.unitCell - ebsd.unitCell(1),[],1);
c = c(norm(c) > 0);
[~,order] = sort(norm(c)); c = c(order);
e = c(1);
for k = 2:3
  e(k) = c(find(all(abs(dot_outer(c,e)) < 1e-6 * norm(c) * norm(e(:)).',2),1));
end
% the grid dimensions run along x, y and z, so match the edges to the axes,
% pointing forward
axes = [vector3d.X,vector3d.Y,vector3d.Z];
M = abs(dot_outer(reshape(e,[],1),axes));
order = zeros(1,3);
for k = 1:3
  [~,i] = max(M(:)); [r,a] = ind2sub([3 3],i);
  order(a) = r; M(r,:) = -1; M(:,a) = -1;
end
e = reshape(e(order),1,3);
e = e .* sign(dot(e,axes));
d = norm(e);

% lattice index of every voxel
ijk = round(dot_outer(reshape(ebsd.pos,[],1) - ebsd.pos(1),e) ./ d.^2);
ijk = ijk - min(ijk,[],1) + 1;
% at least two cells per direction, so the grid has a step in each
sGrid = max(max(ijk,[],1),2);
newId = sub2ind(sGrid,ijk(:,1),ijk(:,2),ijk(:,3));
assert(numel(unique(newId)) == numel(newId), ...
  'two voxels fall onto one lattice cell, the positions are not on a regular grid')

% the positions of the whole grid
origin = ebsd.pos(1) - sum((ijk(1,:) - 1) .* e);
[I,J,K] = ndgrid(1:sGrid(1),1:sGrid(2),1:sGrid(3));
pos = origin + (I-1) .* e(1) + (J-1) .* e(2) + (K-1) .* e(3);

% the cells nobody occupies are padded as not indexed
phaseId = nan(sGrid);
phaseId(newId) = ebsd.phaseId;
rot = rotation.nan(sGrid);
rot(newId) = ebsd.rotations;

prop = struct;
for fn = fieldnames(ebsd.prop).'
  p = ebsd.prop.(char(fn));
  if isnumeric(p) || islogical(p)
    prop.(char(fn)) = nan(sGrid);
  else
    prop.(char(fn)) = p.nan(sGrid);
  end
  prop.(char(fn))(newId) = p;
end
prop.oldId = nan(sGrid);
prop.oldId(newId) = ebsd.id;

ebsdGrid = EBSD3square(pos,rot,phaseId(:),ebsd.phaseMap,ebsd.CSList,d, ...
  'prop',prop,'opt',ebsd.opt,'unitCell',ebsd.unitCell);
ebsdGrid.scanUnit = ebsd.scanUnit;

end
