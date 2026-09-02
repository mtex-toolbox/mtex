function grains = refineBoundary(grains,n)
% refine the boundary surfaces by midpoint subdivision
%
% Syntax
%
%   grains = refineBoundary(grains)
%   grains = refineBoundary(grains,2)
%
% Input
%  grains - @grain3d with triangular faces
%  n      - number of subdivisions (default 1)
%
% Output
%  grains - @grain3d
%
% Description
% Every subdivision splits each edge at its midpoint and each face into
% four, which halves the spacing of the vertices. No vertex moves, so the
% volumes, the areas and the grains a face separates are inherited exactly;
% a face keeps its voxels and its misorientation.
%
% See also
% grain2d/refineBoundary grain3d/reduceBoundary grain3d/smoothBoundary

if nargin < 2, n = 1; end

for k = 1:n

  gB = grains.boundary;
  [E,F2E] = edges(gB);
  nV = length(gB.allV);
  nF = length(gB.F);

  % the midpoints join the vertex list, the faces are split in place
  M = nV + F2E;
  F = [gB.F(:,1) M(:,1) M(:,3); M(:,1) gB.F(:,2) M(:,2); M(:,3) M(:,2) gB.F(:,3); M];
  F = reshape(permute(reshape(F,nF,4,3),[2 1 3]),[],3);

  gB = gB.subSet(repelem((1:nF).',4));
  gB.F = F;
  gB.id = (1:4*nF).';
  gB.allV = [gB.allV(:); (gB.allV(E(:,1)) + gB.allV(E(:,2))) ./ 2];

  grains.boundary = gB;
  grains.I_GF = grains.I_GF(:,repelem(1:nF,4));

end

end
