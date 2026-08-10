function [mesh,ind,model] = calcMesh(pos,uC,varargin)
% complete a (possibly incomplete) 2d lattice from its points and unit cell
%
% The grid is described by two lattice basis vectors u, v that are derived
% from the unit cell. The unit cell is interpreted as the Voronoi (Wigner-
% Seitz) cell of the lattice, so every nearest neighbour sits at twice the
% vector from the cell center to an edge midpoint. The two shortest linearly
% independent of these neighbour vectors form a primitive basis. This works
% for any 2d lattice: it reduces to the edge vectors for a 4-corner square
% or rectangular cell and yields (dx,0),(dx/2,dy) for a 6-corner hexagonal
% cell - so square and hex grids are handled by the same code.
%
% Input
%  pos - @vector3d  measured point centers (possibly incomplete)
%  uC  - @vector3d  unit cell vertices, ordered around the polygon
%                   (4 for square/rect, 6 for hex); relative to the center
%
% Output
%  mesh  - @vector3d  complete lattice (observed nodes kept exact)
%  ind   - mesh(ind) == pos
%  model - diagnostics: p0, u, v, nI, nJ, rmse, maxErr
%

% --- lattice basis from the unit cell --------------------------------
% (i,j) index assignment is robust to smooth grid distortion (e.g. a
% trapezoidal stage drift) - see assignGridIndex - and shared with
% gridIndex/gridComponents/spatialDecompositionGrid/generateUnitCells,
% which all place a pixel on the same virtual lattice this way.
A = latticeBasis(uC);

% the caller may hand over pos in any shape, e.g. map shaped (r x c) - the
% lattice fit and all the indexing below operate on a flat list of points
pos = pos(:);

xy = [pos.x(:), pos.y(:)];
IJ = assignGridIndex(xy,A);
I = IJ(:,1); J = IJ(:,2);

% refine the lattice basis by fitting p0,u,v to the actual measured
% positions via least squares against the rough integer indices. The
% unit-cell-derived (u,v) is only a statistical estimate (calcUnitCell
% fits it from local point statistics), and even a tiny mismatch against
% the true per-pixel step compounds over hundreds of grid steps, which
% can displace far-away points by a large fraction of a cell and corrupt
% the mesh built below.
designMatrix = [ones(numel(I),1), I, J];
posXYZ = [pos.x(:), pos.y(:), pos.z(:)];
fit = designMatrix \ posXYZ;
p0 = vector3d(fit(1,1),fit(1,2),fit(1,3));
u  = vector3d(fit(2,1),fit(2,2),fit(2,3));
v  = vector3d(fit(3,1),fit(3,2),fit(3,3));

% ideal grid
nI = max(I)+1; nJ = max(J)+1;
[ii,jj] = ndgrid(1:nI,1:nJ);
idealMesh = p0 + (ii-1) * u + (jj-1)*v;

% p0,u,v are plain vector3d - restore the plotting convention of the input
idealMesh.how2plot = pos.how2plot;

if nargout == 1
  mesh = idealMesh;
  return;
end

ind = sub2ind([nI,nJ],I+1,J+1);
% maybe the ideal grid is sufficiently good
res = idealMesh(ind) - pos;
if mean(norm(res)) / mean(norm(uC)) < 1e-2
  mesh = idealMesh;
  mesh(ind) = pos;
  if nargout == 3
    model = makeModel(p0,u,v,nI,nJ,res);
  end
  return
end

% otherwise we interpolate the deformation
% observed matrices
mesh = vector3d.nan(size(idealMesh),pos.how2plot);
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
% keep observed nodes exact - index by ind, not by the mask known: the mask
% assigns in ascending linear order, while pos is in the callers order
mesh(ind) = pos;
% diagnostics
if nargout == 3
  model = makeModel(p0,u,v,nI,nJ,def(known));
end
end

% =========================================================================
function model = makeModel(p0,u,v,nI,nJ,res)
model = struct();
model.p0     = p0;
model.u      = u;
model.v      = v;
model.nI     = nI;
model.nJ     = nJ;
model.rmse   = sqrt(mean(res.x.^2 + res.y.^2 + res.z.^2));
model.maxErr = max(sqrt(res.x.^2 + res.y.^2 + res.z.^2));
end

% =========================================================================
function varargout = getOption(args,names)
% tiny name/value getter returning [] for absent options
varargout = cell(1,numel(names));
for n = 1:numel(names)
  idx = find(strcmpi(args,names{n}),1,'last');
  if ~isempty(idx) && idx < numel(args)
    varargout{n} = args{idx+1};
  else
    varargout{n} = [];
  end
end
end
