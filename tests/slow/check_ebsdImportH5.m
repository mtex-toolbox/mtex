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

% synthetic and does not need the 50 MB asset below
checkExportIntoReference;

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
checkEMSphInxROI;

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
function checkEMSphInxROI
% a region of interest EMSphInx left out of the run must import as notIndexed
%
% EMSphInx writes a value for every pixel of the scan grid but only indexes
% the pixels inside a ROI mask, and it flags nothing: a masked pixel arrives
% with a valid looking phase number at orientation (0,0,0) and every quality
% measure zero, and left indexed the whole masked region fuses into one grain
% at that orientation. markUnmeasured is what recognises them.
%
% The result must not depend on whether the caller states a 'setting'. It did:
% the check ran after the Euler correction and compared the orientations
% against the correction the data carries, and re-applying a correction
% composes three rotations, leaving some 1e-7 radian of round-off - just
% enough to miss an exact equality test, so a stated 'setting' silently
% turned the whole thing off and only the 255 flagged pattern survived.
%
% Synthetic and 120 pixels, unlike the rest of this file: nothing here needs
% real data, and it lives with the HDF5 interface it exercises rather than in
% core/ so the format stays in one place. The .ang half of the same problem is
% in core/check_ebsdImport.

nx = 12; ny = 10; nOutside = ny*numel(nx/2:nx-1);

f = writeSyntheticEMSphInxH5(nx,ny);
c = onCleanup(@() delete(f));

% one pattern inside the ROI carries the 255 EMSphInx uses for "could not
% index this", so the two mechanisms are told apart rather than confused
for opts = {{}, {'setting',2}, {'EulerCorrection',rotation.byAxisAngle(xvector,180*degree)}}

  e = load1(f,opts{1});

  assert(nnz(~e.isIndexed) == nOutside + 1, ...
    ['check_ebsdImportH5: with %s the ROI masked map imported %d notIndexed ' ...
     'pixels, expected %d - %d outside the ROI plus the one flagged pattern'], ...
    optionName(opts{1}), nnz(~e.isIndexed), nOutside+1, nOutside)

  assert(all(~e.isIndexed(e.x >= (nx/2)*0.5)), ...
    'check_ebsdImportH5: with %s a pixel outside the ROI stayed indexed', ...
    optionName(opts{1}))

end

end

% =========================================================================
function checkExportIntoReference
% exporting to HDF5 writes into a copy of the file the data came from
%
% There is no such thing as "the" EBSD HDF5 format, so exportEBSD_h5 does not
% write one: it copies the reference file and writes the changed data into
% the very data sets loadEBSD_h5 read, which are recorded in ebsd.opt.h5.
% What has to hold is that the changed values arrive, that everything else
% in the file survives untouched, and that a property MTEX added shows up as
% a new data set next to the ones the file brought along.
%
% Synthetic, on the same 120 pixel file the ROI check above writes.

nx = 12; ny = 10;

ref = writeSyntheticEMSphInxH5(nx,ny);
tgt = [tempname '.h5'];
c = onCleanup(@() cellfun(@(f) delete(f),{ref,tgt}));

e0 = load1(ref,{});

% turn the map and overwrite one of the columns the file brought along
turn = rotation.byAxisAngle(zvector,13*degree);
e1 = e0;
e1.rotations = turn .* e0.rotations;
e1.prop.IQ = 42 * ones(size(e1));
e1.prop.grainId = reshape(1:length(e1),size(e1));

% the phase list is part of the map too - renaming a mineral used to be
% silently dropped, since only the per pixel data was written back
csList = e1.CSList;
if iscell(csList), csList{2}.mineral = 'Fe(alpha-iron)';
else, csList(2).mineral = 'Fe(alpha-iron)'; end
e1.CSList = csList;

evalc('export(e1,tgt,''reference'',ref)');

e2 = load1(tgt,{});

assert(length(e2) == length(e1), ...
  'check_ebsdImportH5: the exported file holds %d of %d measurements', ...
  length(e2),length(e1))

ok = e1.isIndexed(:) & e2.isIndexed(:);
d = angle(e1.rotations(ok),e2.rotations(ok))/degree;
assert(max(d) < 1e-3, ...
  'check_ebsdImportH5: the exported orientations came back %.3g degree off',max(d))

assert(isequal(e1.phaseId(:),e2.phaseId(:)), ...
  'check_ebsdImportH5: the exported file changed the phase of %d pixels', ...
  nnz(e1.phaseId(:) ~= e2.phaseId(:)))

assert(isfield(e2.prop,'IQ') && all(e2.prop.IQ(:) == 42), ...
  'check_ebsdImportH5: the overwritten IQ column did not arrive')

assert(isfield(e2.prop,'grainId') && isequal(e2.prop.grainId(:),e1.prop.grainId(:)), ...
  'check_ebsdImportH5: grainId was not added to the exported file')

assert(strcmp(e2.mineralList{2},'Fe(alpha-iron)'), ...
  'check_ebsdImportH5: the renamed mineral came back as %s',e2.mineralList{2})

% everything the export does not touch has to be passed through
for ds = {'/Manufacturer','/Scan 1/EBSD/Header/Step X', ...
    '/Scan 1/EBSD/Header/nColumns','/Scan 1/EBSD/Header/Phase/1/Symmetry', ...
    '/Scan 1/EBSD/Data/Metric'}
  assert(isequaln(h5read(ref,ds{1}),h5read(tgt,ds{1})), ...
    'check_ebsdImportH5: the export changed %s, which it never read',ds{1})
end

% and the reference must not be writable over
ok = false;
try
  evalc('export(e1,ref,''reference'',ref)');
catch ME
  ok = strcmp(ME.identifier,'MTEX:exportEBSD_h5:overwriteReference');
end
assert(ok,'check_ebsdImportH5: exporting onto the reference file was allowed')

end

% =========================================================================
function name = optionName(opts)

if isempty(opts)
  name = 'no options';
else
  name = ['''' char(opts{1}) ''''];
end

end

% =========================================================================
function f = writeSyntheticEMSphInxH5(nx,ny)
% write the smallest file interfaces/hdf5_config/EMSphInx.json will read
%
% Data runs along x first. The right half of the map is what a ROI mask kept
% out of the run: zero Euler angles, zero image quality, zero metric, and a
% phase number that looks perfectly valid.

n = nx*ny;

[X,~] = meshgrid(0:nx-1,0:ny-1);
inROI = reshape((X < nx/2).',[],1);

phi1 = zeros(n,1); Phi = zeros(n,1); phi2 = zeros(n,1);
IQ = zeros(n,1);   metric = zeros(n,1);
phase = zeros(n,1,'uint8');

phi1(inROI) = 0.3; Phi(inROI) = 0.4; phi2(inROI) = 0.5;
IQ(inROI)   = 0.7; metric(inROI) = 0.9;

% EMSphInx marks a pattern it failed to index with the largest value its
% uint8 phase column can hold
phase(find(inROI,1)) = 255;

f = [tempname '.h5'];
scan = '/Scan 1/EBSD';

writeStr(f,'/Manufacturer','EMSphInx');
writeStr(f,[scan '/Header/Grid Type'],'SqrGrid');
writeNum(f,[scan '/Header/Step X'],0.5);
writeNum(f,[scan '/Header/Step Y'],0.5);
writeNum(f,[scan '/Header/nColumns'],nx);
writeNum(f,[scan '/Header/nRows'],ny);

writeStr(f,[scan '/Header/Phase/1/MaterialName'],'Iron');
writeNum(f,[scan '/Header/Phase/1/Symmetry'],43);
for lc = {'a','b','c'}
  writeNum(f,[scan '/Header/Phase/1/Lattice Constant ' char(lc)],2.87);
end
for lc = {'alpha','beta','gamma'}
  writeNum(f,[scan '/Header/Phase/1/Lattice Constant ' char(lc)],90);
end

writeNum(f,[scan '/Data/Phi1'],phi1);
writeNum(f,[scan '/Data/Phi'],Phi);
writeNum(f,[scan '/Data/Phi2'],phi2);
writeNum(f,[scan '/Data/IQ'],IQ);
writeNum(f,[scan '/Data/Metric'],metric);

h5create(f,[scan '/Data/Phase'],n,'Datatype','uint8');
h5write(f,[scan '/Data/Phase'],phase);

end

% =========================================================================
function writeStr(f,ds,val)

h5create(f,ds,1,'Datatype','string');
h5write(f,ds,string(val));

end

% =========================================================================
function writeNum(f,ds,val)

h5create(f,ds,numel(val));
h5write(f,ds,double(val));

end

% =========================================================================
function e = load1(fname,opts)
% the importer prints a configuration banner, which is of no interest here

args = [{fname},opts,{'silent'}];
[~,e] = evalc('EBSD.load(args{:})');

end
