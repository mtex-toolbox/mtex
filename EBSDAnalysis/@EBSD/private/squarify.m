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

ext = get_option(varargin,'extent',ebsd.extent);

% the step size of the new grid
dxy = [range(uC.x), range(uC.y)];
nGrid = 1 + max(0,round((ext([2 4]) - ext([1 3])) ./ dxy));

x = linspace(ext(1),ext(2),nGrid(1));
y = linspace(ext(3),ext(4),nGrid(2));

% meshgrid is column major - transpose for the row major layout
if check_option(varargin,'rowMajor')
  pos = vector3d(x.' + 0*y, 0*x.' + y, 0, ebsd.how2plot);
else
  pos = vector3d(x + 0*y.', 0*x + y.', 0, ebsd.how2plot);
end

% nearest neighbor interpolation onto the new grid
ebsdI = ebsd.interp(pos);

ebsdGrid = EBSDsquare(pos,reshape(ebsdI.rotations,size(pos)),ebsdI.phaseId(:),...
  ebsd.phaseMap,ebsd.CSList,'prop',ebsdI.prop,'opt',ebsd.opt,'unitCell',uC);

if nargout < 2, return; end

% the closest grid point for every measured position
if isscalar(x), dx = 1; else, dx = x(2)-x(1); end
if isscalar(y), dy = 1; else, dy = y(2)-y(1); end
i = min(max(1 + round((ebsd.pos.x(:) - ext(1)) / dx),1),numel(x));
j = min(max(1 + round((ebsd.pos.y(:) - ext(3)) / dy),1),numel(y));

if check_option(varargin,'rowMajor')
  ind = sub2ind(size(pos),i,j);
else
  ind = sub2ind(size(pos),j,i);
end

end
