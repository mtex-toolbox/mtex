function [mesh,ind,model] = calcMesh(pos,uC,varargin)
% 
%
% Input
%  pos - @vector3d
%  uC  - unitCell  
%
% Output
%  mesh - @vector3d
%  ind  - mesh(ind) == pos
%  model - diagnostics information
%
% Options

u = uC(2) - uC(1);
v = uC(4) - uC(1);

% rough index assignment
IJ = double([u;v]) \ double(pos(:) - pos(1));
I = round(IJ(1,:)).';
J = round(IJ(2,:)).';

% refine origin from assigned indices
p0 = pos(1) + min(I) * u + min(J)*v;

% shift indices to p0
I = I - min(I);
J = J - min(J);

nI = max(I)+1; nJ = max(J)+1;
ind = sub2ind([nI,nJ],I+1,J+1);

% ideal grid
[ii,jj] = ndgrid(1:nI,1:nJ);
idealMesh = p0 + (ii-1) * u + (jj-1)*v;

% maybe the ideal grid is sufficiently good
if mean(norm(idealMesh(ind) - pos)) / mean(norm(uC)) < 1e-2
  mesh = idealMesh;
  return
end

% otherwise we interpolate the deformation

% observed matrices
mesh = vector3d.nan(size(idealMesh));
mesh(ind) = pos;

known = ~isnan(mesh);

% local deformation on known nodes
def = mesh - idealMesh;

% interpolate deformation field in index space
Ik = ii(known);
Jk = jj(known);

Fx = scatteredInterpolant(Ik,Jk,def.x(known),'natural','nearest');
Fy = scatteredInterpolant(Ik,Jk,def.y(known),'natural','nearest');
Fz = scatteredInterpolant(Ik,Jk,def.z(known),'natural','nearest');

defFull = vector3d(Fx(ii,jj),Fy(ii,jj),Fz(ii,jj));

% reconstruct full mesh
mesh = idealMesh + defFull;

% keep observed nodes exact
mesh(known) = pos;

% diagnostics
if nargout == 3
  res = def(known);
  model = struct();
  model.p0 = p0;
  model.u = u;
  model.v = v;
  model.nI = nI;
  model.nJ = nJ;
  %model.known = known;
  %model.idealMesh = idealMesh;
  %model.def = def;
  model.rmse = sqrt(mean(res.x.^2 + res.y.^2 + res.z.^2));
  model.maxErr = max(sqrt(res.x.^2 + res.y.^2 + res.z.^2));
end