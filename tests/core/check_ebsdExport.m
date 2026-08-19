function check_ebsdExport
% round trips through the EBSD export interfaces
%
% Owns exportEBSD_ang, exportEBSD_ctf and EBSD/export. The HDF5 exporter
% needs a vendor file to copy and is checked by slow/check_ebsdImportH5.
%
% Every case here pins a silent wrong-number regression that an
% import/export cycle used to produce:
%
% * neither exporter undid the Euler angle correction its loader applies, so
%   a map came back turned by 180 degree - with nothing erroring
% * the .ang phase block stated symmetry codes 132 to 137 for the alignment
%   variants of the monoclinic and orthorhombic groups, which are outside
%   the 32 point groups EDAX numbers, so a monoclinic phase was read back as
%   a space group id and came out tetragonal
% * a hexagonal map lost the last cell of every scan row, whether or not it
%   held a measurement
% * the acquisition parameters of the imported header were replaced by zeros
%
% See also
% exportEBSD_ang exportEBSD_ctf exportEBSD_h5 EBSD.export

checkSquareRoundTrip;
checkHexKeepsEveryMeasurement;
checkMonoclinicSurvives;
checkHeaderIsTakenAlong;
checkNotIndexedMarker;

disp('check_ebsdExport: passed');

end

% =========================================================================
function checkSquareRoundTrip
% a two phase square map has to come back as it went in, through either
% format
%
% The orientations are the point: a .ctf is read with a correction of 180
% degree about z and a .ang with one of 180 degree about x-y, so an exporter
% that writes the map frame angles rather than the ones the format states
% produces a file whose import is turned - which is exactly what both did.

ebsd = makeMap;

for fmt = {'ang','ctf'}

  f = [tempname '.' fmt{1}];
  clean = onCleanup(@() delete(f));

  evalc('export(ebsd,f)');
  evalc('back = EBSD.load(f,''silent'');');

  assert(length(back) == length(ebsd), ...
    'check_ebsdExport: %s round trip returned %d of %d measurements', ...
    fmt{1},length(back),length(ebsd))

  % both are on the same grid in the same order, so they compare pixel wise
  d = angle(ebsd.rotations(:),back.rotations(:)) / degree;
  d = d(ebsd.isIndexed(:) & back.isIndexed(:));

  assert(max(d) < 1e-2, ...
    'check_ebsdExport: %s round trip turned the map by up to %.3g degree', ...
    fmt{1},max(d))

  assert(isequal(ebsd.isIndexed(:),back.isIndexed(:)), ...
    'check_ebsdExport: %s round trip changed %d pixels from indexed to not', ...
    fmt{1},nnz(ebsd.isIndexed(:) ~= back.isIndexed(:)))

  assert(isequal(mineralOf(ebsd),mineralOf(back)), ...
    'check_ebsdExport: %s round trip changed the phase of a pixel',fmt{1})

end

end

% =========================================================================
function checkHexKeepsEveryMeasurement
% a hexagonal map is written with every measurement it has
%
% MTEX stores the staggered rows of a hex grid in a rectangle, and the
% exporter used to drop the last column of it plus one more cell on every
% second row, on the assumption that those are never part of the grid. On a
% map whose rows are equally long they are, and 234 of 63180 measurements of
% ferrite.ang went missing.

for ragged = [false true]

  ebsd = makeHexMap(ragged);

  f = [tempname '.ang'];
  clean = onCleanup(@() delete(f));

  evalc('export(ebsd,f)');
  evalc('back = EBSD.load(f,''silent'');');

  assert(nnz(back.isIndexed) == nnz(ebsd.isIndexed), ...
    'check_ebsdExport: hex export kept %d of %d measurements (ragged = %d)', ...
    nnz(back.isIndexed),nnz(ebsd.isIndexed),ragged)

end

end

% =========================================================================
function checkMonoclinicSurvives
% the symmetry of a monoclinic phase has to survive the .ang phase block
%
% MTEX tells 12/m1, 112/m and 2/m11 apart, EDAX numbers 32 point groups and
% does not. The old table wrote 132 to 137 for those variants, values that
% are no point group id at all - crystalSymmetry took them for a space group
% id on import and built a tetragonal group from them, which then failed on
% the lattice constants with "a and b must be equal".

ebsd = makeMap;

f = [tempname '.ang'];
clean = onCleanup(@() delete(f));

evalc('export(ebsd,f)');
evalc('back = EBSD.load(f,''silent'');');

for id = ebsd.indexedPhasesId

  cs0 = csOfPhase(ebsd,id);
  cs1 = csOfPhase(back,idOfMineral(back,cs0.mineral));

  assert(~isempty(cs1), ...
    'check_ebsdExport: phase %s did not survive the ang export',cs0.mineral)

  assert(symmetry.pointGroups(cs0.id).LaueId == symmetry.pointGroups(cs1.id).LaueId, ...
    'check_ebsdExport: %s went from %s to %s through the ang export', ...
    cs0.mineral,cs0.pointGroup,cs1.pointGroup)

end

end

% =========================================================================
function checkHeaderIsTakenAlong
% values of the imported header that MTEX does not model are written back
%
% They used to be written as zeros, so an import/export cycle silently lost
% the pattern center, the working distance and the whole acquisition block.

ebsd = makeMap;
ebsd.opt.header = struct('WorkingDistance',17.5,'Mag',250,'TiltAngle',70, ...
  'OPERATOR','someone','AcqE2',12.5);

f = [tempname '.ang'];
clean = onCleanup(@() delete(f));
evalc('export(ebsd,f)');
txt = fileread(f);

assert(~isempty(regexp(txt,'WorkingDistance\s*17\.5','once')), ...
  'check_ebsdExport: the ang header dropped WorkingDistance')
assert(~isempty(regexp(txt,'OPERATOR:\s*someone','once')), ...
  'check_ebsdExport: the ang header dropped OPERATOR')

g = [tempname '.ctf'];
cleanG = onCleanup(@() delete(g));
evalc('export(ebsd,g)');
txt = fileread(g);

assert(~isempty(regexp(txt,'Mag\s*250','once')), ...
  'check_ebsdExport: the ctf header dropped Mag')
assert(~isempty(regexp(txt,'TiltAngle\s*70','once')), ...
  'check_ebsdExport: the ctf header dropped TiltAngle')
assert(~isempty(regexp(txt,'AcqE2\s*12\.5','once')), ...
  'check_ebsdExport: the ctf header dropped AcqE2')

end

% =========================================================================
function checkNotIndexedMarker
% a pixel without an orientation is written the way the format marks one
%
% OIM writes phase 0 and a confidence index of -1, and loadEBSD_ang reads
% both back. Writing the phase alone is not enough: a single phase .ang
% numbers its phase 0 as well.

ebsd = makeMap;

f = [tempname '.ang'];
clean = onCleanup(@() delete(f));
evalc('export(ebsd,f)');

data = readNumericBlock(f);

% a file runs x fastest while the list of an EBSD runs down its first
% dimension, so the rows have to be found by position rather than by index
key = round(([ebsd.pos.x(:),ebsd.pos.y(:)] - min([ebsd.pos.x(:),ebsd.pos.y(:)])) * 1e3);
[found,row] = ismember(key,round(data(:,4:5) * 1e3),'rows');

assert(all(found), ...
  'check_ebsdExport: %d of %d measurements are missing from the file', ...
  nnz(~found),numel(found))

isNI = ~ebsd.isIndexed(:);

assert(all(data(row(isNI),8) == 0), ...
  'check_ebsdExport: not indexed pixels were not written as phase 0')
assert(all(data(row(isNI),7) < 0), ...
  'check_ebsdExport: not indexed pixels were not marked by ci = -1')
assert(all(data(row(~isNI),8) > 0), ...
  'check_ebsdExport: indexed pixels were written as phase 0')

end

% =========================================================================
function ebsd = makeMap
% a small two phase square map with a few not indexed pixels, one of them
% cubic and one monoclinic

cs = {'notIndexed', ...
  crystalSymmetry('m-3m',[2.87 2.87 2.87],'mineral','Iron'), ...
  crystalSymmetry('12/m1',[5.2 9.0 20.1],[90 95.8 90]*degree,'mineral','Biotite')};

[X,Y] = meshgrid((0:11)*0.5,(0:8)*0.5);
n = numel(X);

rng(0);
rot = rotation.rand(n,1);

phaseId = 2*ones(n,1);
phaseId(1:3:end) = 3;
phaseId([2 7 13 44]) = 1;   % not indexed
rot(phaseId == 1) = rotation.nan;

ebsd = EBSD(vector3d(X(:),Y(:),0),rot,phaseId,cs,struct);

end

% =========================================================================
function ebsd = makeHexMap(ragged)
% a small hexagonal map, either as a full rectangle of cells or with every
% second row one cell shorter - the two cases the .ang header states as
% NCOLS_ODD and NCOLS_EVEN

d = 0.5;
nRow = 9; nCol = 12;

x = []; y = [];
for j = 0:nRow-1
  cols = nCol - (ragged && mod(j,2) == 1);
  i = (0:cols-1).';
  x = [x; i*d + mod(j,2)*d/2]; %#ok<AGROW>
  y = [y; ones(cols,1)*j*d*sqrt(3)/2]; %#ok<AGROW>
end

n = numel(x);
rng(1);

ebsd = EBSD(vector3d(x,y,0),rotation.rand(n,1),ones(n,1), ...
  {crystalSymmetry('m-3m','mineral','Iron')},struct);

ebsd = ebsd.gridify;

end

% =========================================================================
function m = mineralOf(ebsd)
% the mineral name of every pixel, as a string array

names = strings(1,numel(ebsd.CSList));
for i = 1:numel(ebsd.CSList)
  cs = csOfPhase(ebsd,i);
  if isa(cs,'crystalSymmetry'), names(i) = string(cs.mineral); else, names(i) = "notIndexed"; end
end

m = names(ebsd.phaseId(:));

end

% =========================================================================
function cs = csOfPhase(ebsd,id)

cs = [];
if isempty(id) || id < 1 || id > numel(ebsd.CSList), return; end

cs = ebsd.CSList(id);
if iscell(cs), cs = cs{1}; end

end

% =========================================================================
function id = idOfMineral(ebsd,mineral)

id = [];
for i = 1:numel(ebsd.CSList)
  cs = csOfPhase(ebsd,i);
  if isa(cs,'crystalSymmetry') && strcmp(cs.mineral,mineral), id = i; return; end
end

end

% =========================================================================
function d = readNumericBlock(f)
% the data rows of a text file, i.e. everything that is not a header line

txt = regexp(fileread(f),'\r?\n','split');
txt = txt(~cellfun(@isempty,txt));
txt = txt(~strncmp(txt,'#',1));

d = cell2mat(cellfun(@(l) sscanf(l,'%f').',txt(:),'UniformOutput',false));

end
