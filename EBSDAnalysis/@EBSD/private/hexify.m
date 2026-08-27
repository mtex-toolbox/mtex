function [ebsdGrid,newId] = hexify(ebsd,varargin)
% place hexagonally measured EBSD data into a staggered matrix
%
% The counterpart of squarify, and like it built on the virtual lattice: the
% (row,col) of a measurement comes from its integer lattice index, not from
% rounding its raw x/y against the axes. That is what lets a rotated grid
% work - the previous version divided by hard coded sqrt(3) and 3/2 factors
% taken off ebsd.extent, so on a rotated map several measurements rounded
% onto one cell and were silently overwritten (5.2% of titanium at 20
% degree, see TODO.md E14).
%
% The layout is the usual staggered one: with u the dense lattice direction
% and v the one 60 degree from it, a cell at axial index (i,j) sits at
%
%   row = j + 1,   col = i + floor(j/2) + 1
%
% which is exactly the offset convention @EBSDhex/cube2hex implements, so
% hex2cube/cube2hex keep working against the result.

% allow to run again even if already EBSDhex
ebsd = EBSD(ebsd);

% extract new unitCell
unitCell = get_option(varargin,'unitCell',ebsd.unitCell);

prop = ebsd.prop;

% --- the lattice ---------------------------------------------------------
[u,v] = hexBasis(unitCell);
A = [u(:), v(:)];

pos2d = [ebsd.pos.x(:), ebsd.pos.y(:)];
ij = assignGridIndex(pos2d,A);
i0 = ij(:,1); j0 = ij(:,2);          % both >= 0

% axial -> staggered offset coordinates
c0   = i0 + floor(j0/2);
cMin = min(c0);

row = j0 + 1;
col = c0 - cMin + 1;

sGrid = [max(row), max(col)];
newId = sub2ind(sGrid,row,col);

% the index map is a bijection by construction, so this cannot fire - it is
% here because the failure it replaces was silent for years
assert(numel(unique(newId)) == numel(newId), ...
  'MTEX:hexify:collision', ...
  'hexify placed %d measurements on a shared cell', ...
  numel(newId) - numel(unique(newId)));

% --- positions of every cell of the rectangle ----------------------------
% deformation aware, and the measured nodes are put back exactly afterwards
isIndexed = ebsd.isIndexed(:);
if ~any(isIndexed), isIndexed = true(size(pos2d,1),1); end
reconstructPos = latticeModel(pos2d,ij,isIndexed,mean(vecnorm(A,2,1)));

[allRow,allCol] = ndgrid(1:sGrid(1),1:sGrid(2));
allJ = allRow(:) - 1;
allI = allCol(:) - 1 + cMin - floor(allJ/2);
xy   = reconstructPos([allI, allJ]);

pos = reshape(vector3d(xy(:,1),xy(:,2),0,ebsd.pos.frame),sGrid);
pos(newId) = ebsd.pos;

% --- scatter the data ----------------------------------------------------
if ~check_option(varargin,'nearest')

  phaseId = nan(sGrid);
  phaseId(newId) = ebsd.phaseId;

  rot = rotation.nan(sGrid);
  rot(newId) = ebsd.rotations;

  for fn = fieldnames(ebsd.prop).'
    prop.(char(fn)) = scatterProp(ebsd.prop.(char(fn)),newId,sGrid,length(ebsd));
  end

  prop.oldId = nan(sGrid);
  prop.oldId(newId) = ebsd.id;

else

  % general nearest neighbour interpolation onto the same cells
  nearId = griddata(ebsd.pos.x(:),ebsd.pos.y(:), ...
    reshape(ebsd.id,[numel(ebsd.id),1]),pos.x,pos.y,'nearest');

  % no interpolation further than one unit cell
  [~,dist] = knnsearch(pos2d,[pos.x(:),pos.y(:)],'K',1,'Distance','euclidean');
  toIgnore = reshape(dist,sGrid) >= mean(norm(unitCell));

  phaseId = nan(sGrid);
  phaseId(~toIgnore) = ebsd.phaseId(nearId(~toIgnore));

  rot = rotation.nan(sGrid);
  rot(~toIgnore) = ebsd.rotations(nearId(~toIgnore));

  src = nearId(~toIgnore);
  tgt = find(~toIgnore);
  for fn = fieldnames(ebsd.prop).'
    v = ebsd.prop.(char(fn));
    v = reshape(v,length(ebsd),[]);      % one row per measurement, k columns
    prop.(char(fn)) = scatterProp(v(src,:),tgt,sGrid,numel(src));
  end

end

% the measured unit cell is handed over, so a rotated one survives - the
% constructor used to replace it with an axis aligned hexagon
ebsdGrid = EBSDhex(pos, rot, phaseId(:), ebsd.phaseMap, ebsd.CSList, ...
  [], [], 'unitCell', unitCell, 'options', prop, 'opt', ebsd.opt);

end

% =========================================================================
function [u,v] = hexBasis(uC)
% the dense lattice direction and the one 60 degree from it
%
% Taken from the unit cell rather than from latticeBasis so that the choice
% is pinned here: latticeBasis returns whichever of the six translations has
% the smallest angle modulo 180 degree, which for the bundled hex data is
% the one pointing at 180 degree, and the sign would then decide the layout.
% u is the translation closest to +x, which for an axis aligned pointy top
% cell is the 0 degree one and so reproduces the layout these maps already
% have; on a rotated map it rotates with the lattice, which is the point.

V = [uC.x(:), uC.y(:)];
V = V - mean(V,1);

mids  = 0.5 * (V + V([2:end 1],:));
trans = 2 * mids;                       % 6 × 2, one per shared edge

ang = atan2(trans(:,2),trans(:,1));

[~,iu] = min(abs(mod(ang + pi, 2*pi) - pi));
u = trans(iu,:);

dv = mod(ang - ang(iu) - pi/3 + pi, 2*pi) - pi;
[~,iv] = min(abs(dv));
v = trans(iv,:);

end
