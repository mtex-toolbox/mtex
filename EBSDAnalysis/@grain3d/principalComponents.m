function [a,b,c] = principalComponents(grains,varargin)
% principal axes of a list of grains ignoring holes
%
% Input
%  grains - @grain3d
%
% Output
%  a,b,c - principle axes @vector3d
%
% Options
%  volume - scale a,b,c such that the corresponding ellipsoid has the same area as the grain (default)
%  boundary - scale a,b such that the corresponding ellipse has the boundary length as the grain
%
% See also
% plotEllipse
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

  % volume and centroid of each grain via divergence theorem
  vol = grains.I_GF * sum(A .* N,2) / 6;
  c = grains.I_GF * (N.*((A+B).^2 + (B+C).^2 + (C+A).^2)) / 48 ./ vol;
  c = c.xyz;

  % the quadrature points
  P1 = (1/3 * A + 1/3 * B + 1/3 * C);
  P2 = (3/5 * A + 1/5 * B + 1/5 * C);
  P3 = (1/5 * A + 3/5 * B + 1/5 * C);
  P4 = (1/5 * A + 1/5 * B + 3/5 * C);

  % the integrals of x^3, y^3, z^3 over the faces
  Ix3y3z3 = -9/16 * P1.^3 + 25/48 * (P2.^3 + P3.^3 + P4.^3);
  % the integral of x*y*z over the faces
  Ixyz = -9/16 * prod(P1,2) + 25/48 * (prod(P2,2) + prod(P3,2) + prod(P4,2));
  
  % the volume integrals of x.^2, y.^2, z.^2
  Vx2y2z2 = grains.I_GF * (N .* Ix3y3z3) / 6;
    
  % I (x-mx)^2 = I x^2 - mx^2
  Vx2y2z2 = Vx2y2z2 - vol .* c.^2;
  
  % the volume integrals of yz, xz, xy
  Vxyz = grains.I_GF * (N .* Ixyz) / 2;
  Vxyz = Vxyz - vol .* [c(:,2) .* c(:,3), c(:,1) .* c(:,3), c(:,1) .* c(:,2)];

else % implicitly do the triangulation

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
  c = c.xyz;

  % the quadrature points
  P1 = (1/3 * A + 1/3 * B + 1/3 * C);
  P2 = (3/5 * A + 1/5 * B + 1/5 * C);
  P3 = (1/5 * A + 3/5 * B + 1/5 * C);
  P4 = (1/5 * A + 1/5 * B + 3/5 * C);

  % the integrals of x^3, y^3, z^3 over the triangles
  Ix3y3z3 = -9/16 * P1.^3 + 25/48 * (P2.^3 + P3.^3 + P4.^3);
  % the integral of x*y*z over the triangles
  Ixyz = -9/16 * prod(P1,2) + 25/48 * (prod(P2,2) + prod(P3,2) + prod(P4,2));
  
  % the volume integrals of x.^2, y.^2, z.^2
  Vx2y2z2 = grains.I_GF * accumarray(id,vector3d.byXYZ(N .* Ix3y3z3)) / 6;
    
  % I (x-mx)^2 = I x^2 - mx^2
  Vx2y2z2 = Vx2y2z2.xyz - vol .* c.^2;
  
  % the volume integrals of yz, xz, xy
  Vxyz = grains.I_GF * accumarray(id,vector3d.byXYZ(N .* Ixyz)) / 2;
  Vxyz = Vxyz.xyz - vol .* [c(:,2) .* c(:,3), c(:,1) .* c(:,3), c(:,1) .* c(:,2)];

end

%Vx2y2z2 = sqrt(Vx2y2z2); Vxyz = sqrt(Vxyz);

% compute the principle components of the cross correlation matrix
[v,lambda] = eig3(Vx2y2z2(:,1),Vxyz(:,3),Vxyz(:,2),Vx2y2z2(:,2),Vxyz(:,1),Vx2y2z2(:,3));
v = (v .* sqrt(lambda)).';

% scale to volume
v = v .* (vol ./ (4/3*pi*prod(norm(v),2))).^(1/3);

if nargout > 1
  a = v(:,3);
  b = v(:,2);
  c = v(:,1);
else
  a = v;
end