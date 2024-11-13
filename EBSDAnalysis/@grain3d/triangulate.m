function grains = triangulate(grains, varargin)
% triangulate surface of 3d grains
%
% Syntax
%   grainsT = grains.triangulate
%
% Input
%  grains - @grain3d
%
% Output
%  grainsT - triangulated @grain3d
%

F = grains.F;

% the number of triangles per face
numTriangle = cellfun(@numel,F)-3;

% the first point of each triangle
indA = repelem( cellfun(@(x) x(1),F),numTriangle);

% the second point of each triangle
tmp = cellfun(@(x) x(2:end-2),grains.F,'UniformOutput',false);
indB = [tmp{:}].';

% the third point of each triangle
tmp = cellfun(@(x) x(3:end-1),grains.F,'UniformOutput',false);
indC = [tmp{:}].';

% this removes all faces that do not belong to single grain
%grains.I_GF = grains.I_GF(:,any(grains.I_GF,1));
% new incidence matrix
id = repelem(1:size(F,1),numTriangle);
grains.I_GF = grains.I_GF(:,id);

% new faces
grains.boundary.F = [indA,indB,indC];
grains.boundary.grainId = grains.boundary.grainId(id,:);
grains.boundary.phaseId = grains.boundary.phaseId(id,:);
grains.boundary.ebsdId = grains.boundary.ebsdId(id,:);
grains.boundary.misrotation = grains.boundary.misrotation(id);
grains.boundary.id = grains.boundary.id(id);