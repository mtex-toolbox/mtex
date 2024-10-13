function vol = volume(grains, varargin)
% volume of a list of grains
%
% Input
%  grains - @grain3d
%
% Output
%  vol  - list of volumes (in measurement units^3)
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
  
  % volume of each grain via divergence theorem
  vol = grains.I_GF * accumarray(id,sum(A .* N,2)) / 6;  

else

  V = grains.boundary.allV;

  isF = any(grains.I_GF,1);
  sgnVol = zeros(width(grains.I_GF),1);

  sgnVol(isF) = det(V(grains.F(:,1)),V(grains.F(:,2)),V(grains.F(:,3)));

  vol = grains.I_GF * sgnVol / 6;

end
