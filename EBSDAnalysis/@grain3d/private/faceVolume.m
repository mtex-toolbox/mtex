function fV = faceVolume(grains)
% six times the signed volume each boundary face contributes to a grain
%
% Syntax
%   fV = faceVolume(grains)
%
% Input
%  grains - @grain3d
%
% Output
%  fV - numFaces × 1 list of signed volumes (times 6)
%
% Description
%
% Following the divergence theorem the volume of a grain is the sum of the
% signed volumes of all cones spanned by the origin and a boundary face,
% provided all face normals are oriented outwards, i.e.
%
%   vol = grains.I_GF * faceVolume(grains) / 6
%
% See also
% grain3d/volume grain3d/orientFaces
%

if iscell(grains.F)

  % the number of triangles per face
  numTetra = cellfun(@numel,grains.F)-3;

  % the vertices of all triangles
  Vxyz = grains.boundary.allV.xyz;

  indA = repelem( cellfun(@(x) x(1),grains.F),numTetra);
  A = Vxyz(indA,:);

  tmp = cellfun(@(x) x(2:end-2),grains.F,'UniformOutput',false);
  indB = [tmp{:}].';
  B = Vxyz(indB,:);

  tmp = cellfun(@(x) x(3:end-1),grains.F,'UniformOutput',false);
  indC = [tmp{:}].';
  C = Vxyz(indC,:);

  % the unnormalized normals
  N = cross(B-A,C-A,2);

  % transform triangles back to faces
  id = repelem((1:length(grains.F)).',numTetra);

  fV = accumarray(id,sum(A .* N,2),[length(grains.F),1]);

else

  V = grains.boundary.allV;

  fV = det(V(grains.F(:,1)),V(grains.F(:,2)),V(grains.F(:,3)));

end

end
