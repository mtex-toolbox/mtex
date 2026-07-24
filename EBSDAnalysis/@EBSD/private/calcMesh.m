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
[u,v] = latticeBasis(uC);

% rough index assignment
IJ = double([u;v]) \ double(pos(:) - pos(1));
I = round(IJ(1,:)).';
J = round(IJ(2,:)).';

% refine origin from assigned indices
p0 = pos(1) + min(I) * u + min(J)*v;
% shift indices to p0
I = I - min(I);
J = J - min(J);

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
if nargout == 1
  mesh = idealMesh;
  return;
end

ind = sub2ind([nI,nJ],I+1,J+1);
% maybe the ideal grid is sufficiently good
if mean(norm(reshape(idealMesh(ind),[],1) - pos)) / mean(norm(uC)) < 1e-2
  mesh = idealMesh;
  mesh(ind) = pos;
  if nargout == 3
    model = makeModel(p0,u,v,nI,nJ,reshape(idealMesh(ind),[],1) - pos);
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
% keep observed nodes exact
mesh(known) = pos;
% diagnostics
if nargout == 3
  model = makeModel(p0,u,v,nI,nJ,def(known));
end
end

% =========================================================================
function [u,v] = latticeBasis(uC)
% primitive lattice vectors from a Voronoi-type unit cell (square or hex)

% candidate nearest-neighbour vectors = 2 * (edge midpoint - center)
% uC(:) always linearizes to a column, but uC(idx) for a vector uC keeps
% uC's own row/column orientation regardless of idx's shape - so both
% sides are forced to a column explicitly, or a row/column mismatch here
% silently broadcasts into an nCorner x nCorner matrix instead of the
% intended elementwise result
c0  = mean(uC);
shifted = uC([2:end 1]);
mid = (uC(:) + shifted(:)) ./ 2;     % edge midpoints (closed polygon)
g   = 2 .* (mid - c0);

% sort candidates by length, then pick the two shortest independent ones
len = norm(g);
[len,ord] = sort(len(:));
g = g(ord);

u = g(1);
v = [];
for k = 2:numel(g)
  if norm(cross(u,g(k))) > 1e-6 * len(1) * len(k)
    v = g(k);
    break
  end
end
if isempty(v)
  error('calcMesh:degenerateCell', ...
    'The unit cell does not define two independent lattice vectors.')
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
