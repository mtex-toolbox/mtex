function check_ebsdInterp
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

disp('check_ebsdInterp: passed');

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
