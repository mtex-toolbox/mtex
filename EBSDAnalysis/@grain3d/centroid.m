function c = centroid(grains, varargin)
% centroid of the grains
% 
% Syntax
%
%   c = grains.centroid
%
% Input
%  grains - @grain3d
%
% Output
%  c - @vector3d
%
% See also
% grain3d/fitEllipse
%


% see https://paulbourke.net/geometry/polygonmesh/centroid.pdf
if isnumeric(grains.F)
  
  % the vertices of all triangles
  Vxyz = grains.boundary.allV.xyz;
  A = Vxyz(grains.F(:,1),:);
  B = Vxyz(grains.F(:,2),:);
  C = Vxyz(grains.F(:,3),:);

  % the unnormalized normals
  N = cross(B-A,C-A,2);

  % volume of each grain via divergence theorem
  vol = grains.I_GF * sum(A .* N,2) / 6;

  % centroid of each grain via divergence theorem
  c = grains.I_GF * (N.*((A+B).^2 + (B+C).^2 + (C+A).^2)) / 48 ./ vol;

  c = vector3d.byXYZ(c);
  
else

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
  
  % centroid of each grain via divergence theorem
  c = vector3d.byXYZ(N.*((A+B).^2 + (B+C).^2 + (C+A).^2) / 48);

  c = grains.I_GF * accumarray(id,c) ./ vol;
  
end
