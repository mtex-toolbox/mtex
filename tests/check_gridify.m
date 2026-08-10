function check_gridify
% check that ebsd.gridify picks the right grid type and does not distort pos
%
% A hexagonal unit cell must end up as an @EBSDhex, a square one as an
% @EBSDsquare. Regression: ebsd.unitCell became a 1xN @vector3d, so the
% shape test size(unitCell,1)==6 that dispatched to hexify never fired and
% every hex map was squarified onto the lattice basis (a1,a2) with a2 at
% 120 degree - a parallelogram, which sheared ebsd.pos far outside the
% measured extent (ferrite: x in [-40.2, 110.25] instead of [0, 69.9]).

cases = {'ferrite','EBSDhex',6; 'titanium','EBSDhex',6; ...
  'twins','EBSDsquare',4; 'forsterite','EBSDsquare',4};

for k = 1:size(cases,1)

  name = cases{k,1};
  ebsd = EBSD(mtexdata(name,'silent'));

  assert(length(ebsd.unitCell) == cases{k,3}, ...
    'check_gridify: %s is expected to have a %d corner unit cell',name,cases{k,3});

  [ebsdGrid,newId] = ebsd.gridify;

  assert(isa(ebsdGrid,cases{k,2}), ...
    'check_gridify: %s gridified to %s, expected %s',name,class(ebsdGrid),cases{k,2});

  % every measurement keeps its position - up to the grid regularisation
  dPos = max(norm(ebsd.pos - ebsdGrid.pos(newId)));
  assert(dPos < 0.05 * ebsd.dPos, ...
    'check_gridify: %s moves measurements by %g (step size %g)',name,dPos,ebsd.dPos);

  % no two measurements share a grid point
  assert(numel(unique(newId)) == numel(newId), ...
    'check_gridify: %s maps several measurements onto the same grid point',name);

  % the grid does not extend more than one cell beyond the measured extent
  ext = ebsd.extent; extGrid = ebsdGrid.extent;
  assert(all(abs(extGrid(1:4) - ext(1:4)) <= ebsd.dPos), ...
    'check_gridify: %s grid extent [%s] does not match data extent [%s]',...
    name,xnum2str(extGrid(1:4)),xnum2str(ext(1:4)));

  % gridifying an already gridified map is a no-op
  ebsdGrid2 = ebsdGrid.gridify;
  assert(isa(ebsdGrid2,cases{k,2}) && all(size(ebsdGrid2) == size(ebsdGrid)) && ...
    max(norm(ebsdGrid.pos(:) - ebsdGrid2.pos(:))) < 1e-10, ...
    'check_gridify: %s is not stable under a second gridify',name);

  % column major layout: one scan row per matrix row, coordinates increasing
  assert(range(ebsdGrid.pos(1,:).y) < 1e-6 * ebsd.dPos, ...
    'check_gridify: %s does not have a constant y along the first matrix row',name);
  assert(ebsdGrid.pos(end,1).y > ebsdGrid.pos(1,1).y && ...
    ebsdGrid.pos(1,end).x > ebsdGrid.pos(1,1).x, ...
    'check_gridify: %s is not oriented towards increasing coordinates',name);

end

checkLayout;
checkMapShapedInput;
checkDistortedGrid;
checkResample;
checkResampleRotated;
checkSubGrid;
checkFillGridFree;
checkInterp;
checkPos2Ind;
checkHexRotatedRefused;
checkHexDerivedGeometry;
checkExportAng;

disp('gridify: all checks passed');

end

% =========================================================================
function checkSubGrid
% subGrid crops to the same rectangle whether ind is logical or numeric
%
% Regression: the numeric branch did [x,y] = ind2sub(ebsd,ind), but
% ind2sub returns the ROW first, so x held rows and y held columns while
% the mask was indexed mask(yMin:yMax, xMin:xMax) - i.e. transposed. A
% square map hides this, so the test deliberately uses a non-square one.

ebsd = EBSD(mtexdata('twins','silent')).gridify;

assert(size(ebsd,1) ~= size(ebsd,2), ...
  'check_gridify: checkSubGrid needs a non square map to be meaningful');

% a rectangle strictly inside the map, deliberately not square and placed
% off centre so a transposition cannot coincidentally give the same answer
rows = 10:40; cols = 55:70;
mask = false(size(ebsd));
mask(rows,cols) = true;

eLog = ebsd.subGrid(mask);
eNum = ebsd.subGrid(find(mask)); %#ok<FNDSB> - the numeric branch is the point

assert(all(size(eLog) == [numel(rows) numel(cols)]), ...
  'check_gridify: subGrid(logical) returned a %s block, expected %d x %d', ...
  xnum2str(size(eLog)),numel(rows),numel(cols));

assert(all(size(eNum) == size(eLog)), ...
  'check_gridify: subGrid(numeric) returned a %s block, subGrid(logical) a %s one', ...
  xnum2str(size(eNum)),xnum2str(size(eLog)));

assert(isequaln(eNum.id,eLog.id) && isequaln(eNum.rotations.a,eLog.rotations.a), ...
  'check_gridify: subGrid(numeric) and subGrid(logical) select different data');

% and the block really is the requested one
assert(isequaln(eLog.id,ebsd.id(rows,cols)), ...
  'check_gridify: subGrid cropped to the wrong rectangle');

end

% =========================================================================
function checkLayout
% the rowMajor layout is the transpose of the default columnMajor one

ebsd = EBSD(mtexdata('twins','silent'));

eC = ebsd.gridify;
eR = ebsd.gridify('rowMajor');

assert(all(size(eC) == fliplr(size(eR))), ...
  'check_gridify: rowMajor is not the transpose of columnMajor');

assert(abs(dot(normalize(eC.d1),yvector)-1) < 1e-6 && ...
  abs(dot(normalize(eC.d2),xvector)-1) < 1e-6, ...
  'check_gridify: columnMajor does not run along +y, +x');

assert(abs(dot(normalize(eR.d1),xvector)-1) < 1e-6 && ...
  abs(dot(normalize(eR.d2),yvector)-1) < 1e-6, ...
  'check_gridify: rowMajor does not run along +x, +y');

assert(isequaln(eC.rotations.a, eR.rotations.a.') && ...
  isequaln(reshape(eC.phaseId,size(eC)), reshape(eR.phaseId,size(eR)).'), ...
  'check_gridify: rowMajor and columnMajor do not hold the same data');

% the explicit flag agrees with the default
assert(all(size(ebsd.gridify('columnMajor')) == size(eC)), ...
  'check_gridify: columnMajor is not the default layout');

end

% =========================================================================
function checkMapShapedInput
% an EBSD built from map shaped (r x c) input is flat and gridifies
%
% Regression, two layers. The constructor flattened phaseId and id but
% stored pos and rotations exactly as handed over, so the object looked
% valid while size(ebsd) - which is size(ebsd.id) - contradicted the data
% it held. It then detonated inside gridify, where calcMesh compared an
% explicitly flattened ideal grid against pos in the callers shape: an
% (N x 1) minus (r x c) subtraction, which used to hang forever in
% vector3d/plus. A map shaped @EBSD is what @EBSDsquare / @EBSDhex are
% for, so the constructor normalizes to a flat list.

sz = 20; d = 0.3;
[Y,X] = ndgrid((0:sz-1)*d,(0:sz-1)*d);

ebsd = EBSD(vector3d(X,Y,zeros(sz)), rotation.rand(sz,sz), ones(sz,sz), ...
  {crystalSymmetry('m-3m')}, struct('bc',rand(sz,sz)));

s = size(ebsd);
assert(isequal(s,[sz^2 1]), ...
  'check_gridify: a map shaped input gives an EBSD of size %s',mat2str(s));
assert(isequal(size(ebsd.pos),s) && isequal(size(ebsd.rotations),s) && ...
  isequal(size(ebsd.phaseId),s) && isequal(size(ebsd.bc),s), ...
  'check_gridify: the constructor stores pos %s, rotations %s, phaseId %s, bc %s next to an id of %s',...
  mat2str(size(ebsd.pos)),mat2str(size(ebsd.rotations)),...
  mat2str(size(ebsd.phaseId)),mat2str(size(ebsd.bc)),mat2str(s));

[ebsdGrid,newId] = ebsd.gridify;

assert(numel(ebsdGrid) == sz^2, ...
  'check_gridify: a map shaped pos gridified to %d instead of %d points',...
  numel(ebsdGrid),sz^2);

assert(max(norm(ebsdGrid.pos(newId) - ebsd.pos(:))) < 1e-10 * d, ...
  'check_gridify: a map shaped pos does not survive gridify');

% a genuine N x k property is not a map and keeps its columns
N = 50; fse = rand(N,5);
ebsd = EBSD(vector3d((0:N-1).'*d,zeros(N,1),zeros(N,1)), rotation.rand(N,1), ...
  ones(N,1), {crystalSymmetry('m-3m')}, struct('fse',fse));

assert(isequal(ebsd.fse,fse), ...
  'check_gridify: a multi column property was flattened to %s',...
  mat2str(size(ebsd.fse)));

end

% =========================================================================
function checkDistortedGrid
% a distorted map keeps every measurement at its measured position
%
% A distortion beyond calcMesh's 1e-2 tolerance takes its second branch,
% which interpolates the deformation field and then restores the observed
% nodes. Regression: that restore assigned through the logical mask of
% known nodes, which fills in ascending linear index order, while pos comes
% in the callers order - so on any map whose scan order is not the mesh's
% column major order the positions ended up permuted (by up to a full map
% width on twins). The ideal-grid branch every undistorted map takes never
% reaches this line.

ebsd = EBSD(mtexdata('twins','silent'));

% trapezoidal stage drift: scale x per scan row about the map centre
p = ebsd.pos;
xC = (min(p.x) + max(p.x))/2;
yC = (min(p.y) + max(p.y))/2; yHalf = (max(p.y) - min(p.y))/2;
ebsd.pos = vector3d(xC + (p.x-xC).*(1 + 0.05*(p.y-yC)/yHalf), p.y, p.z);

[ebsdGrid,newId] = ebsd.gridify;

assert(max(norm(ebsdGrid.pos(newId) - ebsd.pos)) < 1e-10 * ebsd.dPos, ...
  'check_gridify: a distorted map does not keep its measured positions');

end

% =========================================================================
function checkResample
% a custom unit cell resamples the map onto a grid of exactly that cell

ebsd = EBSD(mtexdata('copper','silent'));

uC = 2.5 * vector3d([-1 -1 1 1].',[-1 1 1 -1].',0);
ebsdS = ebsd.gridify('unitCell',uC);

assert(isa(ebsdS,'EBSDsquare'), ...
  'check_gridify: a square unit cell did not produce an EBSDsquare');

assert(max(norm(ebsdS.unitCell(:) - uC(:))) < 1e-6 * norm(uC(1)), ...
  'check_gridify: the resampled map does not carry the requested unit cell');

% the new grid covers the old map without extending it
ext = ebsd.extent; extS = ebsdS.extent;
assert(all(abs(extS(1:4) - ext(1:4)) <= ebsd.dPos), ...
  'check_gridify: the resampled grid extent [%s] does not match [%s]',...
  xnum2str(extS(1:4)),xnum2str(ext(1:4)));

% the resampled map is not empty - nearest neighbor interpolation assigns
% every grid point inside the map
assert(nnz(ebsdS.isIndexed) > 0.9 * length(ebsdS), ...
  'check_gridify: only %d of %d resampled pixels are indexed',...
  nnz(ebsdS.isIndexed),length(ebsdS));

% and it is plottable - a degenerate unit cell would break latticeBasis
f = figure('visible','off');
plot(ebsdS('indexed'),ebsdS('indexed').orientations);
close(f);

end

% =========================================================================
function checkResampleRotated
% a rotated unit cell gives a rotated - and still gap free - grid
%
% Regression: the new grid was built axis aligned from the BOUNDING BOX of
% the unit cell instead of from its cell to cell translations. A unit cell
% rotated by 45 degree was therefore placed at a spacing of its full
% diagonal, so the cells only touched at their corners and half the map -
% every second cell of a checkerboard - stayed empty.

ebsd = EBSD(mtexdata('twins','silent')).gridify;

uC = rotate(2*ebsd.unitCell,45*degree);
ebsdR = ebsd.gridify('unitCell',uC);

% the grid directions follow the unit cell, they are not axis aligned
assert(abs(abs(dot(normalize(ebsdR.d1),yvector)) - cos(45*degree)) < 1e-6 && ...
  abs(abs(dot(normalize(ebsdR.d2),xvector)) - cos(45*degree)) < 1e-6, ...
  'check_gridify: a 45 degree rotated unit cell did not give a rotated grid');

% neighbouring cells are one cell edge apart, not one bounding box apart
dCell = norm(uC(1) - uC(2));
assert(abs(norm(ebsdR.d1) - dCell) < 1e-6 * dCell && ...
  abs(norm(ebsdR.d2) - dCell) < 1e-6 * dCell, ...
  'check_gridify: the rotated grid has spacing %g / %g instead of %g',...
  norm(ebsdR.d1),norm(ebsdR.d2),dCell);

% hence the new cells cover the original map instead of only half of it
areaNew = nnz(ebsdR.isIndexed) * polyArea(uC);
areaOld = nnz(ebsd.isIndexed) * polyArea(ebsd.unitCell);
assert(areaNew > 0.95 * areaOld, ...
  'check_gridify: the rotated grid covers only %.0f%% of the map',...
  100 * areaNew / areaOld);

end

% =========================================================================
function checkFillGridFree
% fill no longer turns a plain @EBSD into an @EBSDsquare
%
% The pixels to fill have to exist before they can be filled, which is what
% the unconditional gridify was for. addLatticeSites materialises the
% empty sites on the virtual lattice instead, so the class survives.

for nameC = {'twins','titanium'}

  name = nameC{1};
  ebsd = EBSD(mtexdata(name,'silent'));
  e = ebsd('indexed');

  fp = fill(e);              % lattice route
  fg = fill(e,'gridify');    % the old behaviour, kept as an opt-out

  assert(strcmp(class(fp),'EBSD'), ...
    'check_gridify: %s - fill returned a %s, expected the input class EBSD', ...
    name, class(fp));
  assert(isa(fg,'EBSDgrid'), ...
    'check_gridify: %s - fill(...,''gridify'') no longer returns a grid class', name);

  % the measurements themselves are untouched, and stay in their rows
  assert(length(fp) >= length(e), 'check_gridify: %s - fill lost pixels', name);
  assert(max(norm(fp.pos(1:length(e)) - e.pos)) < 1e-10, ...
    'check_gridify: %s - fill moved the measured positions', name);
  r0 = e.rotations; r1 = fp.rotations(1:length(e));
  assert(isequaln([r0.a r0.b r0.c r0.d],[r1.a r1.b r1.c r1.d]), ...
    'check_gridify: %s - fill altered the measured orientations', name);

  % every site it created is a site gridify creates too - never one outside
  % the scanned area. With a tolerance rather than exactly, since gridify
  % regularises positions slightly (the main loop of this file allows
  % 0.05*dPos for that).
  %
  % The converse does NOT hold: gridify pads the map out to a rectangle,
  % which on a hex grid adds corner cells that are not hex lattice sites at
  % all - 48 of them on titanium, a gap free scan where there is nothing to
  % fill and the lattice route correctly adds nothing.
  A = [fp.pos.x(:) fp.pos.y(:)];
  B = [fg.pos.x(:) fg.pos.y(:)];
  % note the argument order: pdist2(X,Y,'Smallest',1) gives one distance per
  % point of Y, so this is "for each site I made, how far is the nearest
  % gridify site" - the other order asks the converse, which is false by
  % design (gridify's rectangle padding has no counterpart here)
  dNear = pdist2(B,A,'euclidean','Smallest',1).';
  nOutside = nnz(dNear > 0.1*e.dPos);
  assert(nOutside == 0, ...
    ['check_gridify: %s - the lattice route created %d sites that gridify ' ...
    'does not have (max distance %.3g, step %.3g)'], ...
    name, nOutside, max(dNear), e.dPos);

end

% and a hole really does get filled
ebsd = EBSD(mtexdata('twins','silent'));
e = ebsd('indexed');
% chosen by lattice position, not by scan order: a run of consecutive scan
% indices straddles a row end, and a removed pixel at the map border sits on
% the convex hull, where fill's 'none' extrapolation legitimately returns NaN
ij = e.lattice.ij;
interior = find(all(ij > min(ij,[],1)+3 & ij < max(ij,[],1)-3, 2));
drop = interior(round(linspace(1,numel(interior),10)));

keep = true(length(e),1); keep(drop) = false;
holed = e.subSet(keep);

gone = e.pos(~keep);
filled = fill(holed);

assert(length(filled) > length(holed), ...
  'check_gridify: fill did not materialise the removed pixels');

% the removed pixels are back, at their old positions, and carry data.
% Note fill does not promise to fill EVERYTHING: scatteredInterpolant with
% the default 'none' extrapolation returns NaN outside the convex hull, so a
% few sites on the border stay empty unless 'extrapolate' is given.
d = pdist2([filled.pos.x filled.pos.y],[gone.x gone.y],'euclidean','Smallest',1);
assert(all(d < 1e-9), ...
  'check_gridify: fill did not restore %d of the removed pixels', nnz(d >= 1e-9));

[~,back] = ismembertol([gone.x gone.y],[filled.pos.x filled.pos.y],1e-9,'ByRows',true);
assert(~any(isnan(filled.rotations(back))), ...
  'check_gridify: fill restored the removed pixels but left them unfilled');

end

% =========================================================================
function checkInterp
% interp is grid free, keeps every query point, and returns a flat list
%
% The @EBSDsquare and @EBSDhex overrides are gone - the square one used
% griddedInterpolant, which needs an axis aligned rigid grid and threw
% "Grid arrays must have NDGRID structure" on a rotated map.

ebsd = EBSD(mtexdata('twins','silent'));
x = linspace(5,40,20); y = linspace(5,30,20);

% row vector query: the result must be a flat list of 20, not a 1 x 20
% pos against a 20 x 1 id, which reported length 1
r = interp(ebsd,x,y);
assert(length(r) == 20 && all(size(r.pos) == [20 1]) && all(size(r.phaseId) == [20 1]), ...
  ['check_gridify: interp(ebsd,x,y) with row vectors returned an ' ...
  'inconsistent object - length %d, pos %s, phaseId %s'], ...
  length(r), mat2str(size(r.pos)), mat2str(size(r.phaseId)));

% and it agrees with the column/vector3d spelling
r2 = interp(ebsd,vector3d(x(:),y(:),0));
assert(isequaln(r.rotations.a,r2.rotations.a), ...
  'check_gridify: interp disagrees between the row vector and vector3d call');

% a rotated grid: the deleted square override could not do this at all
eR = rotate(ebsd,30*degree,'keepEuler').gridify;
q = eR.pos(round(numel(eR.pos)*[0.3 0.5 0.7]));
a = eR.interp(q);
assert(length(a) == 3 && all(a.isIndexed), ...
  'check_gridify: interp failed on a rotated grid');

% every query point survives, including where the source is a gridified map
% whose notIndexed padding carries a NaN phaseId
eG = EBSD(mtexdata('ferrite','silent')).gridify;
pos = vector3d(rand(120,200)*100,rand(120,200)*100,0);
ei = eG.interp(pos);
assert(length(ei) == numel(pos), ...
  ['check_gridify: interp returned %d of %d query points - a gridded ' ...
  'source has NaN phaseId at its padding, and those rows must not be dropped'], ...
  length(ei), numel(pos));
assert(strcmp(class(ei),'EBSD'), ...
  'check_gridify: interp returned a %s, but a query at arbitrary positions is a list', ...
  class(ei));

end

% =========================================================================
function checkPos2Ind
% pos2ind inverts the grid basis, so a sheared grid works too
%
% It used to project onto d1 and d2 separately, which inverts the basis
% only if they are perpendicular. Rotation keeps them perpendicular, shear
% does not - the old code answered (5,8) for the cell at (3,7).

ebsd = EBSD(mtexdata('twins','silent'));

cases = {'axis aligned', ebsd; ...
  'rotated 30', rotate(ebsd,30*degree,'keepEuler'); ...
  'sheared',    transform(ebsd,@(p) vector3d(p.x+0.35*p.y,p.y,p.z))};

for k = 1:size(cases,1)

  g = cases{k,2}.gridify;

  for t = [3 7; 20 40; 100 150].'
    [i,j] = g.pos2ind(g.pos(t(1),t(2)));
    assert(i == t(1) && j == t(2), ...
      ['check_gridify: pos2ind on a %s grid put the cell at (%d,%d) ' ...
      'at (%d,%d)'], cases{k,1}, t(1), t(2), i, j);
  end

  % a vector of queries, and the single output linear index form
  q = [g.pos(3,7) g.pos(20,40)];
  [i,j] = g.pos2ind(q);
  assert(isequal(i(:).',[3 20]) && isequal(j(:).',[7 40]), ...
    'check_gridify: pos2ind on a %s grid broke for a vector of queries', cases{k,1});

  assert(g.pos2ind(g.pos(5,9)) == sub2ind(size(g),5,9), ...
    'check_gridify: pos2ind single output disagrees with sub2ind on a %s grid', ...
    cases{k,1});

end

% hex too: its pos2ind used a fixed axial matrix in raw x/y, which is the
% inverse basis of an axis aligned lattice only
gh = EBSD(mtexdata('titanium','silent')).gridify;
for w = [0 20 45]
  gr = rotate(gh,w*degree);
  for t = [3 7; 20 40; 50 60].'
    [r,c] = gr.pos2ind(gr.pos(t(1),t(2)));
    assert(r == t(1) && c == t(2), ...
      ['check_gridify: hex pos2ind rotated %d degree put the cell at ' ...
      '(%d,%d) at (%d,%d)'], w, t(1), t(2), r, c);
  end
  assert(gr.pos2ind(gr.pos(5,9)) == sub2ind(size(gr),5,9), ...
    'check_gridify: hex pos2ind single output disagrees with sub2ind at %d degree', w);
end

end

% =========================================================================
function checkHexRotatedRefused
% a rotated hex grid gridifies losslessly (TODO.md E14)
%
% hexify used to round raw x/y against hard coded sqrt(3) and 3/2 factors,
% so a rotated map put several measurements on one cell and the last one
% won - 421 of 8100 on titanium at 20 degree, 3407 of 63045 on ferrite. It
% places cells by their lattice index now.

for nameC = {'titanium','ferrite'}

  name = nameC{1};
  e0 = EBSD(mtexdata(name,'silent'));

  for w = [0 20 45]

    e = rotate(e0,w*degree,'keepEuler');
    [g,newId] = e.gridify;

    assert(isa(g,'EBSDhex'), ...
      'check_gridify: %s rotated %d deg gridified to %s, expected EBSDhex', name, w, class(g));

    assert(numel(unique(newId)) == numel(newId), ...
      ['check_gridify: %s rotated %d deg put %d of %d measurements on a ' ...
      'shared cell - they are silently overwritten'], name, w, numel(newId)-numel(unique(newId)), numel(newId));

    % and the measured positions are kept exactly, not replaced by
    % theoretical ones - the old hexify moved them by up to 0.02
    assert(max(norm(e.pos - g.pos(newId))) == 0, ...
      'check_gridify: %s rotated %d deg moved the measured positions by %g', name, w, max(norm(e.pos - g.pos(newId))));

    % every measurement is still there and unchanged
    r0 = e.rotations; r1 = g.rotations(newId);
    assert(isequaln([r0.a r0.b r0.c r0.d],[r1.a r1.b r1.c r1.d]), ...
      'check_gridify: %s rotated %d deg altered the orientations', name, w);

  end
end

end

% =========================================================================
function checkHexDerivedGeometry
% @EBSDhex derives its geometry from unitCell/pos instead of storing it
%
% dHex + isRowAlignment used to be stored, which could express exactly two
% orientations - 0 and 30 degree - so a rotated hex grid was not
% representable at all. They are read off the unit cell and the positions
% now, which also makes them survive a rotation.

g = EBSD(mtexdata('titanium','silent')).gridify;

% the derived values reproduce what the stored ones used to be
assert(abs(g.dHex - mean(norm(g.unitCell))) < 1e-12, ...
  'check_gridify: dHex is not the unit cell circumradius');
assert(g.isRowAlignment == true && g.offset == 1, ...
  'check_gridify: titanium should be row aligned with offset +1');
% relative, not exact: dx/dy are measured off pos now, while dHex comes from
% the unit cell, which calcUnitCell fits statistically - on titanium the
% measured column step is 12.000000 against sqrt(3)*dHex = 11.999824. Being
% the measured spacing is the point; the ideal relation only has to hold to
% the accuracy of that fit.
assert(abs(g.dx - sqrt(3)*g.dHex) < 1e-3*g.dx && abs(g.dy - 1.5*g.dHex) < 1e-3*g.dy, ...
  'check_gridify: dx/dy do not reproduce the row aligned spacings');

% a flat top grid is recognised the other way round
e = EBSDhex([],rotation.nan(8,9),ones(72,1),1,{crystalSymmetry},1,0);
assert(e.isRowAlignment == false, ...
  'check_gridify: a flat top grid was read as row aligned');
assert(abs(e.dx - 1.5*e.dHex) < 1e-3*e.dx && abs(e.dy - sqrt(3)*e.dHex) < 1e-3*e.dy, ...
  'check_gridify: dx/dy are not swapped for a flat top grid');

% and rotating the map does not disturb any of them. The old offset was
% sign(pos.x(2,1)-pos.x(1,1)), which flips from 45 degree on and inverts
% the whole staggered addressing.
for w = [20 45 90 120 200]
  r = rotate(g,w*degree);
  assert(isa(r,'EBSDhex') && length(r.unitCell) == 6, ...
    'check_gridify: rotating a hex map by %d degree broke the unit cell', w);
  assert(abs(r.dHex - g.dHex) < 1e-9 && r.isRowAlignment == g.isRowAlignment ...
    && r.offset == g.offset, ...
    ['check_gridify: rotating by %d degree changed the derived geometry - ' ...
    'dHex %.4f, isRowAlignment %d, offset %+d'], w, r.dHex, r.isRowAlignment, r.offset);
end

end

% =========================================================================
function checkExportAng
% ang export needs a grid aligned with x and y, and says so if it is not
%
% The header carries one XSTEP along x and one YSTEP along y. A rotated
% grid has a step along neither, and now that both grid classes can hold
% one, writing its two lattice spacings into those fields would describe a
% grid the file does not have.

f = [tempname '.ang'];
clean = onCleanup(@() delete(f));

for nameC = {'twins','titanium'}

  name = nameC{1};
  e0 = EBSD(mtexdata(name,'silent'));

  % axis aligned exports, and the steps land in the header. Square used to
  % die here: @EBSDsquare has had no dx/dy since 859b62af0.
  evalc('export_ang(e0,f)');
  h = fileread(f);
  xs = regexp(h,'XSTEP: ([0-9.]+)','tokens','once');
  ys = regexp(h,'YSTEP: ([0-9.]+)','tokens','once');
  assert(~isempty(xs) && ~isempty(ys) && str2double(xs{1}) > 0 && str2double(ys{1}) > 0, ...
    'check_gridify: export_ang wrote no usable XSTEP/YSTEP for %s', name);

  % rotated is refused, by identifier
  eR = rotate(e0,20*degree,'keepEuler');
  ok = false;
  try
    evalc('export_ang(eR,f)');
  catch ME
    ok = strcmp(ME.identifier,'MTEX:export_ang:notAxisAligned');
  end
  assert(ok, 'check_gridify: export_ang did not refuse a rotated %s map', name);

end

end
