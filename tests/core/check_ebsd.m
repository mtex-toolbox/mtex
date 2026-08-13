function check_ebsd
% checks on the EBSD object itself: construction, display, loadobj, interp
%
% Owns the EBSD object as a subsystem. Merged from check_ebsdDisplay,
% check_ebsdLoadobj and check_ebsdInterp, which were three files produced by
% one bug-fixing session in August 2026 - one per numbered bug. Each of them
% is kept below as a named case, verbatim, with its own explanation of the
% regression it pins.
%
% See also
% EBSD/display EBSD/loadobj EBSD/interp EBSD/subsind

checkDisplay;
checkLoadobj;
checkInterp;
checkIndexing;

disp('check_ebsd: passed');

end

% =========================================================================
function checkDisplay
% check that displaying an EBSD object never throws
%
% A diagnostic should not be the thing that breaks on the object one is
% trying to look at. Regression: display printed the map extent
% unconditionally, but extent is empty when there are no positions, so
% ext(1:2) threw "Index in position 1 exceeds array bounds" - which is how
% an old .mat file that lost its pos (see EBSD/loadobj) masked itself:
% ebsd = mtexdata('trueEbsdWCCo'); worked while mtexdata trueEbsdWCCo did
% not, the only difference being the display.
%
% Syntax
%   check_ebsdDisplay
%
% See also
% EBSD/display check_ebsdLoadobj

ebsd = EBSD(mtexdata('twins','silent'));

checkDisplays(ebsd,'a plain EBSD');
checkDisplays(ebsd.gridify,'a gridified EBSD');
checkDisplays(ebsd(1:5),'a five pixel EBSD');
checkDisplays(ebsd(false(length(ebsd),1)),'an empty EBSD');

% no positions at all - the damaged object of the regression above
noPos = ebsd;
noPos.pos = vector3d;
out = checkDisplays(noPos,'an EBSD without positions');
assert(contains(out,'no positions'), ...
  'check_ebsdDisplay: an EBSD without positions does not say so:\n%s',out);

% and with the unit cell gone as well
noCell = noPos;
noCell.unitCell = vector3d;
checkDisplays(noCell,'an EBSD without positions or unit cell');


end

% =========================================================================
function out = checkDisplays(ebsd,name)
% both display and disp must survive - only the former is what the command
% form of an assignment calls

try
  out = evalc('display(ebsd)');
  evalc('disp(ebsd)');
catch ME
  error('check_ebsdDisplay: displaying %s failed with\n  %s',name,ME.message);
end

end

% =========================================================================
function checkLoadobj
% check that EBSD.loadobj recovers the positions of older .mat files
%
% Matlab hands a saved object to loadobj as a plain struct whenever it
% cannot assign all of its fields - which is exactly what happens to a file
% written before commit 859b62af0 ("EBSDsquare can now be rotated"), since
% that commit removed the dx / dy properties of @EBSDsquare. The struct
% branch of loadobj then has to carry the data over by hand, and every
% field it forgets is lost silently.
%
% Syntax
%   check_ebsdLoadobj
%
% See also
% EBSD/loadobj

checkPosIsKept;
checkPosFromStep;
checkPosFromPropXY;


end

% =========================================================================
function s = oldStyleStruct(ebsd)
% the fields an @EBSDsquare of the dx / dy era was saved with

s = struct();
s.id        = ebsd.id;
s.rotations = ebsd.rotations;
s.pos       = ebsd.pos;
s.unitCell  = ebsd.unitCell;
s.N         = ebsd.N;
s.phaseId   = ebsd.phaseId;
s.CSList    = ebsd.CSList;
s.phaseMap  = ebsd.phaseMap;
s.prop      = ebsd.prop;
s.opt       = ebsd.opt;
s.scanUnit  = ebsd.scanUnit;
s.A_D       = [];
s.dx        = norm(ebsd.d2);
s.dy        = norm(ebsd.d1);

end

% =========================================================================
function checkPosIsKept
% a struct that carries its positions keeps them
%
% Regression: the struct branch copied id, rotations, phaseId, CSList,
% prop, scanUnit, phaseMap, unitCell - and not pos. So every file that
% reached loadobj as a struct came back with an empty pos, whatever it had
% stored, and any later access to ebsd.pos / d1 / d2 threw "Index in
% position 1 exceeds array bounds". This is what happened to the published
% trueEbsdWCCo.mat.

ebsd = EBSD(mtexdata('twins','silent')).gridify;

e = EBSD.loadobj(oldStyleStruct(ebsd));

assert(isa(e,'EBSDsquare'), ...
  'check_ebsdLoadobj: a grid struct loaded as %s',class(e));

assert(~isempty(e.pos), ...
  'check_ebsdLoadobj: loadobj dropped the positions the file had stored');

assert(isequal(size(e.pos),size(ebsd.pos)) && ...
  max(norm(e.pos(:) - ebsd.pos(:))) < 1e-10 * ebsd.dPos, ...
  'check_ebsdLoadobj: the recovered positions are not the stored ones');

end

% =========================================================================
function checkPosFromStep
% a struct with no positions falls back to the stored grid spacing
%
% The dx / dy era stored the spacing as a property of its own. Matlab
% cannot assign those two fields any more - which is why such a file
% arrives as a struct in the first place - so they are still readable here
% and pos can be rebuilt, up to the origin that representation never had.

ebsd = EBSD(mtexdata('twins','silent')).gridify;

s = oldStyleStruct(ebsd);
s.pos = vector3d;

w = warning('off','MTEX:EBSD:loadobj:posFromStep');
e = EBSD.loadobj(s);
warning(w);

assert(isequal(size(e.pos),size(ebsd.pos)), ...
  'check_ebsdLoadobj: pos was rebuilt with size %s instead of %s',...
  mat2str(size(e.pos)),mat2str(size(ebsd.pos)));

% same grid, only shifted to the origin
d = e.pos - e.pos(1,1) - (ebsd.pos - ebsd.pos(1,1));
assert(max(norm(d(:))) < 1e-10 * ebsd.dPos, ...
  'check_ebsdLoadobj: the rebuilt grid does not match the stored spacing');

end

% =========================================================================
function checkPosFromPropXY
% the older prop.x / prop.y era still works

ebsd = EBSD(mtexdata('twins','silent'));

s = struct();
s.id        = ebsd.id;
s.rotations = ebsd.rotations;
s.unitCell  = ebsd.unitCell;
s.phaseId   = ebsd.phaseId;
s.CSList    = ebsd.CSList;
s.phaseMap  = ebsd.phaseMap;
s.prop      = ebsd.prop;
s.prop.x    = ebsd.pos.x;
s.prop.y    = ebsd.pos.y;
s.opt       = ebsd.opt;
s.scanUnit  = ebsd.scanUnit;

e = EBSD.loadobj(s);

assert(max(norm(e.pos - ebsd.pos)) < 1e-10 * ebsd.dPos, ...
  'check_ebsdLoadobj: the prop.x / prop.y era is no longer recovered');

assert(~isfield(e.prop,'x') && ~isfield(e.prop,'y'), ...
  'check_ebsdLoadobj: prop.x / prop.y were not removed after the rescue');

end

% =========================================================================
function checkInterp
% check that EBSD/interp keeps every measurement it is asked for
%
% Interpolating a map at its own positions must be the identity. It was not:
% interp decided "inside the map" with scatteredInterpolant's convex hull
% test, and a query sitting exactly ON the hull - which is what every border
% pixel does in that round trip - fell on either side of it by floating point
% alone. 24 of 144 pixels of a synthetic square map and 899 of 245952 of
% forsterite were silently lost, in a ragged pattern along the border, where
% the griddedInterpolant this replaced lost none.
%
% Reachable through private/squarify, whose resample path (a custom unit
% cell, e.g. hex to square) interpolates onto a grid built from the map's own
% extent.
%
% The criterion is now local: a query takes the measurement it is nearest to
% as long as it lies inside that pixel. That has no edge to fall off, and it
% makes no assumption about the grid - which is what the original report
% asked for, griddedInterpolant having needed an axis aligned monotonic grid.

checkRoundTrip;
checkOutside;
checkProperties;
checkNotIndexedSource;
checkAlwaysAList;


end

% =========================================================================
function checkRoundTrip
% every measurement comes back, whatever the grid looks like

cases = makeCases;

for k = 1:size(cases,1)

  [name,ebsd] = cases{k,:};

  q = interp(ebsd,ebsd.pos(:));

  lost = nnz(isnan(q.prop.tag));
  assert(lost == 0, ...
    'check_ebsdInterp: %s loses %d of %d measurements interpolated onto itself',...
    name,lost,length(ebsd));

  assert(isequal(q.prop.tag(:),reshape(ebsd.prop.tag,[],1)), ...
    'check_ebsdInterp: %s does not map every position onto its own measurement',name);

  % and the query points really are where they were asked for
  dPos = max(norm(q.pos - ebsd.pos(:)));
  assert(dPos < 1e-12*ebsd.dPos, ...
    'check_ebsdInterp: %s moved the query points by %g',name,dPos);

end

end

% =========================================================================
function checkOutside
% a query well outside the map is notIndexed - and phaseId 1, not 0, which
% indexes neither CSList nor phaseMap

cases = makeCases;

for k = 1:size(cases,1)

  [name,ebsd] = cases{k,:};

  % everything here is relative to the map's own step size - the two
  % synthetic maps are 3 um across, titanium is 1000 um across with a 7 um
  % step, so any absolute offset is either inside one of them or far outside
  % the other
  p = ebsd.pos(:);
  ext = ebsd.extent;
  r = max(norm(ebsd.unitCell));

  outside = vector3d(ext(2) + 3*ebsd.dPos, ext(4) + 3*ebsd.dPos, 0);
  q = interp(ebsd,[p(1); outside]);

  assert(all(q.phaseId >= 1), ...
    'check_ebsdInterp: %s gives a phaseId of %d outside the map',...
    name,min(q.phaseId));

  assert(~q.isIndexed(2) && isnan(q.prop.tag(2)), ...
    'check_ebsdInterp: %s indexed a query 3 steps past the map extent',name);

  assert(q.isIndexed(1), ...
    'check_ebsdInterp: %s dropped a query on a measured position',name);

  % the border is where the convex hull test used to fail: a query still
  % covered by the outermost pixel has to stay in
  [~,iEdge] = max(p.x);
  assert(interp(ebsd,p(iEdge) + 0.4*r*xvector).isIndexed, ...
    'check_ebsdInterp: %s dropped a query %g inside the outermost pixel',name,0.4*r);

end

end

% =========================================================================
function checkProperties

n = 24;
fs = reshape(1:5*n,n,5);

ebsd = smallMap(struct('fs',fs,'bc',(1:n).'));

q = interp(ebsd,ebsd.pos);

% a multi channel property keeps its columns
assert(isequal(size(q.fs),[n 5]), ...
  'check_ebsdInterp: an N x 5 property came back as %s',mat2str(size(q.fs)));

assert(isequal(q.fs,fs), ...
  'check_ebsdInterp: an N x 5 property did not round trip');

assert(isequal(q.bc,(1:n).'), ...
  'check_ebsdInterp: an ordinary property did not round trip');

% and outside the map every channel is NaN, not just the first
far = ebsd.pos + vector3d(1000,0,0);
qf = interp(ebsd,far);
assert(isequal(size(qf.fs),[n 5]) && all(isnan(qf.fs(:))), ...
  'check_ebsdInterp: outside the map an N x 5 property is %s',mat2str(size(qf.fs)));

end

% =========================================================================
function checkNotIndexedSource
% a source pixel that carries no orientation still carries its properties -
% isIndexed means "the query landed on a measurement", not "that measurement
% was indexed". Recorded here because it was reported the other way round

n = 24; k = 9;

ebsd = smallMap(struct('bc',(1:n).'));
ebsd.rotations(k) = rotation.nan;
ebsd.phaseId(k) = 1;

q = interp(ebsd,ebsd.pos(k));

assert(q.bc == ebsd.bc(k), ...
  'check_ebsdInterp: a notIndexed source pixel lost its bc (%g instead of %g)',...
  q.bc,ebsd.bc(k));

assert(~q.isIndexed, ...
  'check_ebsdInterp: a notIndexed source pixel came back indexed');

end

% =========================================================================
function checkAlwaysAList
% interpolating at arbitrary positions yields a list, whatever the source

cases = makeCases;

for k = 1:size(cases,1)

  [name,ebsd] = cases{k,:};
  q = interp(ebsd,ebsd.pos(:));

  assert(~isa(q,'EBSDgrid'), ...
    'check_ebsdInterp: %s interpolated to %s, expected a plain EBSD',name,class(q));

  assert(length(q) == length(ebsd), ...
    'check_ebsdInterp: %s interpolated %d measurements into %d',...
    name,length(ebsd),length(q));

end

end

% =========================================================================
function ebsd = smallMap(prop)
% a 4 x 6 map, 24 measurements, as a flat list
%
% Deliberately 2D and not a single scan line: calcUnitCell returns a unit
% cell with a NaN y for a collinear map (uniquetol on the constant y leaves
% one value, so mean(diff(...)) is NaN), which makes any test built on one
% test the fallback path rather than the intended one

d = 0.3;
[Y,X] = ndgrid((0:3)*d,(0:5)*d);
n = numel(X);

ebsd = EBSD(vector3d(X(:),Y(:),zeros(n,1)), rotation.rand(n,1), ...
  ones(n,1), {crystalSymmetry('m-3m')}, prop);

end

% =========================================================================
function cases = makeCases
% a plain list, a square grid, the same rotated, and a real hexagonal map -
% each tagged so a lost measurement is identifiable

d = 0.3; sz = 12; n = sz^2;
[Y,X] = ndgrid((0:sz-1)*d,(0:sz-1)*d);

list = EBSD(vector3d(X(:),Y(:),zeros(n,1)), rotation.rand(n,1), ones(n,1), ...
  {crystalSymmetry('m-3m')}, struct('bc',rand(n,1)));

grid = gridify(list);
rot  = rotate(grid,27*degree,'keepEuler');
hex  = EBSD(mtexdata('titanium','silent'));

cases = {'a plain list', list; 'a square grid', grid; ...
  'a square grid rotated by 27 degree', rot; 'a hexagonal map', hex};

for k = 1:size(cases,1)
  e = cases{k,2};
  e.prop.tag = reshape(1:length(e),size(e));
  cases{k,2} = e;
end

end

% =========================================================================
function checkIndexing
% ebsd(x,y) means two different things and is therefore refused
%
% On a gridded map ebsd(i,j) is the pixel in row i and column j, plain
% matrix indexing (EBSDgrid/subsind). On a list the same expression used to
% be the measurement CLOSEST TO THE COORDINATE (x,y) - a different pixel,
% chosen silently, and since EBSD.load puts data on its grid whenever that
% is lossless, one and the same script could hit either meaning depending on
% the file it was given. The coordinate lookup now has to be asked for by
% name, ebsd('xy',x,y), which means the same on a grid and on a list.

cs = crystalSymmetry('m-3m');
n = 6;
rot = rotation.byAxisAngle(zvector,reshape((1:n*n)*2*degree,n,n));

grid = EBSDsquare([],rot,2*ones(n,n),[0 1],{'notIndexed',cs},'dxy',[1 1]);
list = EBSD(grid.pos(:),grid.rotations(:),grid.phaseId(:), ...
  {'notIndexed',cs},struct());

% the two used to disagree on this very expression
accepted = false;
try
  list(2,3); %#ok<VUNUS>
  accepted = true;
catch err
  assert(strcmp(err.identifier,'MTEX:EBSD:ambiguousIndex'), ...
    'check_ebsd: ebsd(x,y) threw %s instead of MTEX:EBSD:ambiguousIndex', ...
    err.identifier);
  assert(contains(err.message,"ebsd('xy',x,y)"), ...
    'check_ebsd: the error has to name the replacement syntax');
end
assert(~accepted,'check_ebsd: ebsd(x,y) on a list has to be an error');

% while the grid keeps its matrix indexing
p = grid(2,3).pos;
assert(length(grid(2,3))==1 && p.x == grid.pos.x(2,3) && p.y == grid.pos.y(2,3), ...
  'check_ebsd: ebsd(i,j) on a grid must stay the pixel in row i, column j');

% and 'xy' is the coordinate lookup on both, giving the same pixel
for e = {grid,list}
  p = e{1}('xy',2,3).pos;
  assert(length(e{1}('xy',2,3))==1 && abs(p.x-2) < 1e-10 && abs(p.y-3) < 1e-10, ...
    'check_ebsd: ebsd(''xy'',2,3) must be the pixel at the coordinate (2,3)');
end

% everything else a list is indexed by is untouched
assert(length(list(1:10))==10,'check_ebsd: linear indexing broke');
assert(length(list(5))==1,'check_ebsd: scalar indexing broke');
assert(length(list(list.pos.x > 2))==nnz(list.pos.x > 2), ...
  'check_ebsd: logical indexing broke');
assert(length(list('id',3))==1,'check_ebsd: indexing by id broke');

end
