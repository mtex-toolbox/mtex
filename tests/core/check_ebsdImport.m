function check_ebsdImport
% EBSD import must produce the right data, not merely not throw
%
% Replaces checkInterfaces, which walked every file in data/EBSD - about
% 470 MB, including a 179 MB .mat and a 176 MB dream3d - called
% EBSD.load(...,'wizard') on each, and swallowed every failure in a bare
% catch. Its entire output was disp'ed, so it could not fail, and running it
% was minutes of parsing.
%
% This one asserts, on the small files that are committed to the repo, and
% it asserts on CONTENT. That is the point: the import bugs that actually
% happened were silent wrong data rather than exceptions - a lone CR in an
% .ang file made txt2mat and fgetl disagree so the first data row was
% dropped, shifting the whole map by one pixel, and the EDAX reference frame
% work turned up four more of the same shape. A test that only checks
% "did not throw" catches none of those, which is why the first and last
% data row of every file are pinned here by value.
%
% Reference values were read off the current importer and cross-checked
% against the file contents. If one of them changes, the question to answer
% is which of the two is right - not to update the number.
%
% HDF5 is not covered here - it is a separate interface with its own
% multi-scan selection, and its sample file is 50 MB, so it lives in
% slow/check_ebsdImportH5.
%
% See also
% EBSD.load loadEBSD_ctf loadEBSD_ang check_ebsdImportH5

checkSquareCtf;
checkHexCtf;
checkMultiPhaseCtf;
checkAng;
checkGridDispatch;
checkGridOnImport;

disp('check_ebsdImport: passed');

end

% =========================================================================
function checkSquareCtf
% a plain single phase square .ctf

e = load1('testdata_sqr.ctf');

expect(e, 'testdata_sqr.ctf', ...
  'n', 900, 'nPhases', 2, 'unit', 'um', 'dPos', 1, 'nCorners', 4, ...
  'minerals', {'notIndexed','Glaucophane'}, 'nIndexed', 900);

expectRow(e, 'testdata_sqr.ctf', 'first', 1,   [1 0],       [211.15 30.45 6.13]);
expectRow(e, 'testdata_sqr.ctf', 'last',  900, [30 29],     [263.31 34.70 45.55]);

% an Oxford format states its data in the sample frame CS1 - the map
% carries the registered measurement frame X1, Y1, Z1
assert(e.frame == specimenFrame.measurement, ...
  'check_ebsdImport: a .ctf import must attach the measurement frame');
assert(isequal(e.frame.axesNames,{'X1','Y1','Z1'}), ...
  'check_ebsdImport: the measurement frame must use the Oxford axes X1, Y1, Z1');

end

% =========================================================================
function checkHexCtf
% the same map on a hexagonal grid - the row offset is what distinguishes it

e = load1('testdata_hex.ctf');

expect(e, 'testdata_hex.ctf', ...
  'n', 900, 'nPhases', 2, 'unit', 'um', 'dPos', 0.5774, 'nCorners', 6, ...
  'minerals', {'notIndexed','Glaucophane'}, 'nIndexed', 900);

expectRow(e, 'testdata_hex.ctf', 'first', 1,   [1 0],            [201.84 80.66 87.84]);
expectRow(e, 'testdata_hex.ctf', 'last',  900, [30.5 25.1147],   [203.45 74.12 82.74]);

% a hex unit cell has six corners, a square one four - getting this wrong
% silently turns a hex map into a square one
assert(length(e.unitCell) == 6, ...
  'check_ebsdImport: testdata_hex.ctf gave a %d corner unit cell, expected 6', ...
  length(e.unitCell))

end

% =========================================================================
function checkMultiPhaseCtf
% eight phases and a partially indexed, non rectangular scan

e = load1('eclogite.ctf');

expect(e, 'eclogite.ctf', ...
  'n', 617, 'nPhases', 8, 'unit', 'um', 'nIndexed', 613);

expectRow(e, 'eclogite.ctf', 'first', 1,   [87.89 19.1],    [260.51 25.17 33.73]);
expectRow(e, 'eclogite.ctf', 'last',  617, [500.6 108.9],   [345.03 130.90 75.43]);

% every phase in the file must have reached the phase map, and the ones that
% are not notIndexed must carry a real crystal symmetry
assert(numel(e.mineralList) == 8, ...
  'check_ebsdImport: eclogite.ctf gave %d minerals, expected 8', numel(e.mineralList))
assert(strcmp(e.mineralList{1},'notIndexed'), ...
  'check_ebsdImport: eclogite.ctf - phase 1 is %s, expected notIndexed', e.mineralList{1})

for k = 2:numel(e.CSList)
  assert(isa(e.CSList(k),'crystalSymmetry'), ...
    'check_ebsdImport: eclogite.ctf - phase %d is a %s, not a crystalSymmetry', ...
    k, class(e.CSList(k)))
end

% the scan is not a full rectangle. gridify fills the raster out - the cells
% with no measurement become notIndexed rather than NaN, and they do get an
% id - so what has to survive is the number of INDEXED pixels, not the
% number of cells.
%
% 565, not 613: this scan does not sit on one regular lattice. Its 613
% indexed measurements have 605 distinct positions but fall into only 565
% distinct cells of the fitted lattice, and gridify keeps one measurement
% per cell. The count below is exactly that number of cells, so this pins
% "one per cell, none lost beyond the collisions" rather than a magic
% constant - if it ever drops below 565, measurements are being lost for
% some other reason.
%
% Those collisions are also why EBSD.load refuses to grid this file at all;
% checkGridOnImport pins that.
g = gridify(e);
assert(isequal(size(g),[64 73]), ...
  'check_ebsdImport: eclogite.ctf gridified to %s, expected [64 73]', mat2str(size(g)))

nCells = size(unique(e.lattice.ij(e.isIndexed,:),'rows'),1);
assert(nnz(g.isIndexed) == nCells, ...
  ['check_ebsdImport: eclogite.ctf - gridify kept %d indexed pixels but the ' ...
   'indexed measurements occupy %d distinct lattice cells'], ...
  nnz(g.isIndexed), nCells)
assert(nCells == 565, ...
  'check_ebsdImport: eclogite.ctf now occupies %d lattice cells, expected 565', nCells)

end

% =========================================================================
function checkAng
% an .ang file, i.e. the EDAX side of the importer

e = load1('ACOM.ang');

expect(e, 'ACOM.ang', ...
  'n', 225, 'nPhases', 2, 'unit', 'um', 'dPos', 2, 'nCorners', 4, ...
  'nIndexed', 219);

% the first row is the one a stray carriage return used to eat
expectRow(e, 'ACOM.ang', 'first', 1,   [0 0],     [346.01 144.59 252.14]);
expectRow(e, 'ACOM.ang', 'last',  225, [28 28],   [264.02 39.57 56.00]);

% 15 x 15 at a 2 um step - if the first row had been dropped the map would
% not be square any more
assert(length(e) == 225, ...
  'check_ebsdImport: ACOM.ang has %d pixels, expected 225', length(e))

end

% =========================================================================
function checkGridDispatch
% gridify has to pick the grid class from the data, not from the extension

cases = {'testdata_sqr.ctf','EBSDsquare',[30 30]; ...
         'testdata_hex.ctf','EBSDhex',   [30 30]; ...
         'ACOM.ang',        'EBSDsquare',[15 15]};

for k = 1:size(cases,1)

  g = gridify(load1(cases{k,1}));

  assert(isa(g,cases{k,2}), ...
    'check_ebsdImport: %s gridified to a %s, expected a %s', ...
    cases{k,1}, class(g), cases{k,2})

  assert(isequal(size(g),cases{k,3}), ...
    'check_ebsdImport: %s gridified to %s, expected %s', ...
    cases{k,1}, mat2str(size(g)), mat2str(cases{k,3}))

end

end

% =========================================================================
function checkGridOnImport
% EBSD.load grids what it can, and refuses to grid what it cannot
%
% The refusal is the part that matters. gridify writes measurements into a
% raster keyed by lattice cell, and squarify scatters with phaseId(ind) =
% ..., so two measurements in one cell leave only the last - silently.
% eclogite.ctf is exactly that case: 613 indexed measurements occupy 565
% cells, so gridding it on import would throw away 48 of them. Nothing may
% be lost by merely opening a file, so load falls back to the plain list.

cases = {'testdata_sqr.ctf','EBSDsquare',[30 30]; ...
         'testdata_hex.ctf','EBSDhex',   [30 30]; ...
         'ACOM.ang',        'EBSDsquare',[15 15]};

for k = 1:size(cases,1)

  g = load1raw(cases{k,1});

  assert(isa(g,cases{k,2}), ...
    'check_ebsdImport: %s imported as a %s, expected a %s', ...
    cases{k,1}, class(g), cases{k,2})

  assert(isequal(size(g),cases{k,3}), ...
    'check_ebsdImport: %s imported at %s, expected %s', ...
    cases{k,1}, mat2str(size(g)), mat2str(cases{k,3}))

  % gridding may not lose or invent a measurement
  e = load1(cases{k,1});
  assert(nnz(g.isIndexed) == nnz(e.isIndexed), ...
    'check_ebsdImport: %s has %d indexed pixels gridded but %d as a list', ...
    cases{k,1}, nnz(g.isIndexed), nnz(e.isIndexed))

  % 'noGrid' has to be honoured, otherwise there is no way back out
  assert(~isa(e,'EBSDgrid'), ...
    'check_ebsdImport: %s ignored ''noGrid'' and returned a %s', ...
    cases{k,1}, class(e))

end

% eclogite is not on one lattice, so it must come back as a plain list with
% every measurement intact, and it must say so rather than fail quietly
lastwarn('');
g = load1raw('eclogite.ctf');
[~,warnId] = lastwarn;

assert(~isa(g,'EBSDgrid'), ...
  'check_ebsdImport: eclogite.ctf was gridded on import (as %s) although %d of its 613 indexed measurements share a lattice cell', ...
  class(g), 613 - 565)

assert(nnz(g.isIndexed) == 613, ...
  'check_ebsdImport: eclogite.ctf kept %d indexed measurements on import, expected all 613', ...
  nnz(g.isIndexed))

assert(strcmp(warnId,'MTEX:load:notOnGrid'), ...
  'check_ebsdImport: eclogite.ctf fell back to a list but warned ''%s'', expected MTEX:load:notOnGrid', ...
  warnId)

end

% =========================================================================
function e = load1(name)
% load one of the committed sample files, quietly, as a plain list
%
% 'noGrid' on purpose: EBSD.load now puts data on its grid by default, and
% gridify reorders the measurements into its own layout (dim 1 along y,
% dim 2 along x, both increasing - see EBSD/gridify). Every expectRow below
% pins a row by linear index to catch a row the IMPORTER dropped or shifted,
% which is only meaningful against the importer's own order. The default,
% gridded result is pinned separately in checkGridOnImport.

e = load1raw(name,'noGrid');

end

% =========================================================================
function e = load1raw(name,varargin)
% load one of the committed sample files, quietly

f = fullfile(mtexDataPath,'EBSD',name);

assert(isfile(f), ...
  'check_ebsdImport: the sample file %s is missing from the repository', f)

% the importer prints a reference frame notice for .ang files
evalc('e = EBSD.load(f,''silent'',varargin{:});');

end

% =========================================================================
function expect(e,name,varargin)
% check the scalar properties given as name/value pairs

for k = 1:2:numel(varargin)

  what = varargin{k};
  want = varargin{k+1};

  switch what
    case 'n',        got = length(e);
    case 'nPhases',  got = numel(e.CSList);
    case 'unit',     got = e.scanUnit;
    case 'dPos',     got = e.dPos;
    case 'nCorners', got = length(e.unitCell);
    case 'nIndexed', got = nnz(e.isIndexed);
    case 'minerals', got = e.mineralList;
  end

  if ischar(want)
    ok = strcmp(got,want);
    gotStr = got; wantStr = want;
  elseif iscell(want)
    ok = isequal(got(:),want(:));
    gotStr = strjoin(got,','); wantStr = strjoin(want,',');
  else
    ok = abs(got - want) <= 1e-3*max(1,abs(want));
    gotStr = num2str(got); wantStr = num2str(want);
  end

  assert(ok, 'check_ebsdImport: %s - %s is %s, expected %s', ...
    name, what, gotStr, wantStr)

end

end

% =========================================================================
function expectRow(e,name,which,idx,pos,eulerDeg)
% pin one data row by position and orientation
%
% This is the assertion that catches a dropped or shifted row, which is the
% shape the real import bugs took.

p = e.pos(idx);
assert(max(abs([p.x p.y] - pos)) < 1e-3, ...
  'check_ebsdImport: %s - the %s position is (%.4f,%.4f), expected (%.4f,%.4f)', ...
  name, which, p.x, p.y, pos(1), pos(2))

[a,b,c] = Euler(e.rotations(idx),'Bunge');
got = [a b c]/degree;

assert(max(abs(got - eulerDeg)) < 0.01, ...
  'check_ebsdImport: %s - the %s orientation is (%.2f,%.2f,%.2f), expected (%.2f,%.2f,%.2f)', ...
  name, which, got, eulerDeg)

end
