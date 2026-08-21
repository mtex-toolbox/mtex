function [ebsdGrid,ind] = squarify(ebsd,varargin)

uC = get_option(varargin,'unitCell',ebsd.unitCell);

% put unitcell in right order
 omega = angle(uC,vector3d(-1,-1,0),zvector);
 [~,a] = sort(omega);
 uC = uC(a);

% if it is a custom unit cell -> resample onto a new regular grid
if check_option(varargin,'unitCell')
  [ebsdGrid,ind] = resample(ebsd,uC,varargin{:});
  return
end

[pos,ind] = calcMesh(ebsd.pos,uC,varargin{:});

% the grid directions delivered by calcMesh are those of the lattice basis -
% bring them into the requested row / column major layout
[pos,ind] = orientGrid(pos,ind,varargin{:});

sGrid = size(pos);

% set phaseId to notIndexed at all empty grid points
phaseId = nan(sGrid);
phaseId(ind) = ebsd.phaseId;

% update rotations
a = nan(sGrid); b = a; c = a; d = a;
a(ind) = ebsd.rotations.a;
b(ind) = ebsd.rotations.b;
c(ind) = ebsd.rotations.c;
d(ind) = ebsd.rotations.d;

% update all other properties
prop = ebsd.prop;
for fn = fieldnames(ebsd.prop).'
  if isnumeric(prop.(char(fn))) || islogical(prop.(char(fn)))
    prop.(char(fn)) = nan(sGrid);
  else
    prop.(char(fn)) = prop.(char(fn)).nan(sGrid);
  end
  prop.(char(fn))(ind) = ebsd.prop.(char(fn));
end

% store old id
prop.oldId = nan(sGrid);
prop.oldId(ind) = ebsd.id;

ebsdGrid = EBSDsquare(pos,rotation(a,b,c,d),phaseId(:),...
  ebsd.phaseMap,ebsd.CSList,'prop',prop,'opt',ebsd.opt,'unitCell',uC);

end

% =========================================================================
function [pos,ind] = orientGrid(pos,ind,varargin)
% bring a grid into row or column major layout
%
% Which of the two lattice directions ends up as the first matrix dimension
% is, on its own, an arbitrary consequence of the vertex order of the unit
% cell. Here it is pinned down explicitly:
%
%  columnMajor (default) - dim 1 is the grid direction closest to y, dim 2
%    the one closest to x, i.e. size(ebsd) = [numRows numCols] and
%    ebsd(i,j) is the j-th pixel of the i-th scan row. This matches the
%    layout of hexagonal grids, see hexify.
%  rowMajor - the transposed layout, size(ebsd) = [numCols numRows]
%
% In both cases the grid directions are oriented such that the coordinates
% increase along them, so ebsd(1,1) is the corner with the smallest
% coordinates.

if size(pos,1) < 2 || size(pos,2) < 2, return; end

isRowMajor = check_option(varargin,'rowMajor');

d1 = pos(2,1) - pos(1,1);
d2 = pos(1,2) - pos(1,1);

% which of the two grid directions is the more horizontal one
horizontal = @(d) abs(dot(d,xvector)) - abs(dot(d,yvector));
isXFirst = horizontal(d1) > horizontal(d2);

% a permutation of the linear indices describes both the transposition and
% the flips at once
lin = reshape(1:numel(pos),size(pos));

if xor(isXFirst,isRowMajor)
  lin = lin.';
  [d1,d2] = deal(d2,d1);
end

% ensure increasing coordinates along both grid directions
if isRowMajor, ref = [xvector,yvector]; else, ref = [yvector,xvector]; end
if dot(d1,ref(1)) < 0, lin = flipud(lin); end
if dot(d2,ref(2)) < 0, lin = fliplr(lin); end

pos = pos(lin);

% ind points into the old grid - translate it into the new one
invPerm = zeros(numel(lin),1);
invPerm(lin) = 1:numel(lin);
ind = reshape(invPerm(ind),size(ind));

end

% =========================================================================
function [ebsdGrid,ind] = resample(ebsd,uC,varargin)
% resample the data onto a new regular grid defined by the unit cell uC
%
% A custom unit cell asks for a grid the data is not measured on - most
% notably when switching from a hexagonal to a square grid. Hence the grid
% is generated from the extent of the map and the data is interpolated onto
% it, instead of trying to recover grid indices of the measured positions.
%
% The grid inherits the orientation of the unit cell, so for a unit cell
% that is not axis aligned the grid does not fill the rectangular matrix it
% is stored in - the corners stick out of the map and stay notIndexed.

ext = get_option(varargin,'extent',ebsd.extent);

% take the lattice from the unit cell and not from its bounding box, which for a
% rotated cell is larger than the cell to cell translation and leaves gaps
A = latticeBasis(uC);

% the four corners of the extent, referred to the lower left one
corner = [ext([1 2 1 2]); ext([3 3 4 4])];
IJ = A \ (corner - corner(:,1));

% index range such that the lattice covers the entire extent
i = floor(min(IJ(1,:))):ceil(max(IJ(1,:)));
j = floor(min(IJ(2,:))):ceil(max(IJ(2,:)));

[ii,jj] = ndgrid(i,j);
xy = A * [ii(:).'; jj(:).'] + corner(:,1);
pos = reshape(vector3d(xy(1,:),xy(2,:),0,ebsd.pos.frame),size(ii));

% the closest grid point for every measured position
IJm = round(A \ ([ebsd.pos.x(:), ebsd.pos.y(:)].' - corner(:,1)));
im = min(max(IJm(1,:).' - i(1) + 1,1),numel(i));
jm = min(max(IJm(2,:).' - j(1) + 1,1),numel(j));
ind = sub2ind(size(pos),im,jm);

% the lattice directions are those of the unit cell - bring them into the
% requested row / column major layout
[pos,ind] = orientGrid(pos,ind,varargin{:});

% nearest neighbor interpolation onto the new grid
ebsdI = ebsd.interp(pos);

ebsdGrid = EBSDsquare(pos,reshape(ebsdI.rotations,size(pos)),ebsdI.phaseId(:),...
  ebsd.phaseMap,ebsd.CSList,'prop',ebsdI.prop,'opt',ebsd.opt,'unitCell',uC);

end
