function check_ebsdImportH5
% importing an HDF5 EBSD file, including picking one of several data sets
%
% core/check_ebsdImport covers the text formats - .ctf and .ang - on small
% committed files. HDF5 is a separate interface (interfaces/loadEBSD_h5.m,
% driven by the manufacturer configs in interfaces/hdf5_config) and it has
% one thing the text formats do not: a single file can hold several scans,
% selected with the 'dataSet' option by number or by name.
%
% In slow/ rather than core/ because EMSphinx.h5 is 50 MB. That breaks the
% "one file owns a subsystem" rule in tests/CLAUDE.md on purpose - import is
% owned by core/check_ebsdImport - and the reason is cost: core sits at about
% 53 s of its 60 s budget and this needs 5 s and a 50 MB asset.
%
% The file is an EMSphInx indexing of a steel: four scans of the same area
% (four indexing runs, so identical geometry and different orientations),
% with ferrite, austenite and a hexagonal phase.
%
% Two traps worth knowing, both of which cost time here:
%
%  * isequal is the WRONG comparison for two loads of the same scan. In scan
%    3 - the only one with unindexed points - 113995 of the 485140 pixels
%    carry NaN rotations, and isequal(NaN,NaN) is false, so two bit-identical
%    loads compare unequal. isequaln is used below. max(abs(a-b)) does not
%    catch it either, since max skips NaN and reports 0.
%  * angle() is the wrong comparison too: 2*acos(|dot|) next to dot == 1 is
%    only accurate to about sqrt(eps), so two identical loads measure as
%    7.3e-08 rad apart. Same trap as in core/check_eulerquat.
%
% See also
% loadEBSD_h5 EBSD.load check_ebsdImport

fname = fullfile(mtexDataPath,'EBSD','EMSphinx.h5');

if ~isfile(fname)
  fprintf('check_ebsdImportH5: %s is not present, skipping.\n', fname);
  return
end

checkHeaderOnly(fname);
checkPhases(fname);
scans = checkEveryDataSet(fname);
checkTheScansDiffer(scans);
checkDefaultAndNameSelection(fname,scans);

disp('check_ebsdImportH5: passed');

end

% =========================================================================
function checkHeaderOnly(fname)
% 'headerOnly' must give the phase metadata without reading 485140 pixels

h = load1(fname,{'headerOnly'});

assert(length(h) == 0, ...
  'check_ebsdImportH5: headerOnly returned %d pixels, expected none', length(h)) %#ok<ISMT>
assert(isempty(h.pos), ...
  'check_ebsdImportH5: headerOnly returned positions')
assert(numel(h.CSList) == 4, ...
  'check_ebsdImportH5: headerOnly found %d phases, expected 4', numel(h.CSList))

end

% =========================================================================
function checkPhases(fname)
% the phase headers must be parsed, not merely counted
%
% MaterialName is empty in this file - checked directly with h5read, it is
% empty in the HDF5 itself, so the blank mineral names are the file's doing
% and not the importer's. What has to survive is the symmetry and the
% lattice, which is what identifies the phases as a steel.

e = load1(fname,{});

assert(numel(e.CSList) == 4, ...
  'check_ebsdImportH5: %d phases, expected 4', numel(e.CSList))
assert(strcmp(e.mineralList{1},'notIndexed'), ...
  'check_ebsdImportH5: phase 1 is %s, expected notIndexed', e.mineralList{1})

% point group and a axis of the three indexed phases
expected = {'m-3m', 2.8665; 'm-3m', 3.5910; '6/mmm', 2.5071};

for k = 1:3
  cs = e.CSList(k+1);
  assert(isa(cs,'crystalSymmetry'), ...
    'check_ebsdImportH5: phase %d is a %s', k+1, class(cs))
  assert(strcmp(char(cs.pointGroup),expected{k,1}), ...
    'check_ebsdImportH5: phase %d has point group %s, expected %s', ...
    k+1, char(cs.pointGroup), expected{k,1})
  assert(abs(cs.aAxis.abs - expected{k,2}) < 1e-3, ...
    'check_ebsdImportH5: phase %d has a = %.4f, expected %.4f', ...
    k+1, cs.aAxis.abs, expected{k,2})
end

end

% =========================================================================
function scans = checkEveryDataSet(fname)
% all four scans must load, with the geometry they share

scans = cell(1,4);

% only scan 3 has unindexed points - the other three indexing runs assigned
% every pixel. That is what makes scan 3 the one carrying NaN rotations, and
% why the isequal trap in the header shows up there and nowhere else.
nNotIndexed = [0 0 113995 0];

for k = 1:4

  e = load1(fname,{'dataSet',k});
  scans{k} = e;

  assert(length(e) == 485140, ...
    'check_ebsdImportH5: scan %d has %d pixels, expected 485140', k, length(e))
  assert(strcmp(e.scanUnit,'um'), ...
    'check_ebsdImportH5: scan %d has unit %s, expected um', k, e.scanUnit)
  assert(abs(e.dPos - 0.4) < 1e-6, ...
    'check_ebsdImportH5: scan %d has step %.4f, expected 0.4', k, e.dPos)
  assert(nnz(~e.isIndexed) == nNotIndexed(k), ...
    'check_ebsdImportH5: scan %d has %d notIndexed pixels, expected %d', ...
    k, nnz(~e.isIndexed), nNotIndexed(k))
  assert(nnz(isnan(e.rotations.a)) == nNotIndexed(k), ...
    ['check_ebsdImportH5: scan %d has %d NaN rotations but %d notIndexed ' ...
     'pixels - the two must agree'], ...
    k, nnz(isnan(e.rotations.a)), nNotIndexed(k))

  g = gridify(e);
  assert(isequal(size(g),[508 955]), ...
    'check_ebsdImportH5: scan %d gridified to %s, expected [508 955]', ...
    k, mat2str(size(g)))

end

end

% =========================================================================
function checkTheScansDiffer(scans)
% four indexing runs of the same area - the geometry is shared, so if
% 'dataSet' were being ignored every scan would come back identical and
% every check above would still pass

for k = 2:numel(scans)
  assert(~isequaln(scans{k}.rotations,scans{1}.rotations), ...
    ['check_ebsdImportH5: scan %d is identical to scan 1 - the dataSet ' ...
     'option is not selecting anything'], k)
end

% pinned by value, so that a scan being silently swapped for another is
% caught rather than just "they differ"
firstEuler = [251.64 34.73 124.37; ...
              107.20 90.41 272.47; ...
              194.00 43.39 305.18; ...
              135.00 180.00 225.00];

for k = 1:numel(scans)
  [a,b,c] = Euler(scans{k}.rotations(1),'Bunge');
  got = [a b c]/degree;
  assert(max(abs(got - firstEuler(k,:))) < 0.01, ...
    'check_ebsdImportH5: scan %d starts at (%.2f,%.2f,%.2f), expected (%.2f,%.2f,%.2f)', ...
    k, got, firstEuler(k,:))
end

end

% =========================================================================
function checkDefaultAndNameSelection(fname,scans)
% the default is the first data set, and selecting by name is the same
% request as selecting by number

dflt = load1(fname,{});
assert(isequaln(dflt.rotations,scans{1}.rotations), ...
  'check_ebsdImportH5: the default data set is not the first one')

% the listing calls them 'Scan 1/EBSD' .. 'Scan 4/EBSD'
byName = load1(fname,{'dataSet','Scan 3/EBSD'});

assert(isequaln(byName.rotations,scans{3}.rotations), ...
  ['check_ebsdImportH5: ''dataSet'',''Scan 3/EBSD'' and ''dataSet'',3 give ' ...
   'different data'])
assert(isequal(byName.pos,scans{3}.pos), ...
  'check_ebsdImportH5: the two selection forms give different positions')

end

% =========================================================================
function e = load1(fname,opts)
% the importer prints a configuration banner, which is of no interest here

args = [{fname},opts,{'silent'}];
[~,e] = evalc('EBSD.load(args{:})');

end
