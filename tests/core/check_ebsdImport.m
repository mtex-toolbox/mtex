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
% EBSD.load loadEBSD_ctf loadEBSD_ang loadEBSD_crc check_ebsdImportH5

checkSquareCtf;
checkHexCtf;
checkMultiPhaseCtf;
checkAng;
checkEMSphInxAngROI;
checkCprMissingPhase;
checkGridDispatch;
checkGridOnImport;
checkWizardScript;

disp('check_ebsdImport: passed');

end

% =========================================================================
function checkWizardScript
% the wizard script must reproduce every phase edit and its named first plot

ni = notIndexed('not'' indexed',[0.1 0.2 0.3]);
cs2 = crystalSymmetry('1',[2 3 4],[75 85 105]*degree, ...
  'Z||b','X||a*','mineral','O''Brien phase','color',[0.2 0.4 0.6]);
cs3 = crystalSymmetry('m-3m',[3.6 3.6 3.6], ...
  'mineral','name before table edit','color',[0.7 0.3 0.1]);
% an HDF5 lattice parameter is a float32 widened to double, and this color
% is exactly CSS LightSkyBlue
cs4 = crystalSymmetry('m-3m',double(single([4.04 4.04 4.04])), ...
  'mineral','Al','color',[135 206 250]/255);

phaseId = [1; 2; 2; 3; 3; 3; 3];
n = numel(phaseId);
ebsd = EBSD(vector3d((1:n).',zeros(n,1),zeros(n,1)), ...
  rotation.id(n),phaseId,[ni cs2 cs3 cs4],struct());

mapConvention = plottingConvention('y↑→x');
eulerConvention = plottingConvention('x↓→y');
filePath = fullfile(tempdir,'O''Brien.ctf');
str = buildImportWizardScript(ebsd,filePath,mapConvention,eulerConvention, ...
  1,[false true true],["not' indexed" "O'Brien phase" "dominant"]);

% evaluate only the generated phase declaration, never the fake file load
first = strfind(str,'csList = ');
last = strfind(str,'% how the map is aligned');
assert(isscalar(first) && isscalar(last) && last > first, ...
  'check_ebsdImport: generated script has no isolated csList declaration')
eval(str(first:last-1));

assert(strcmp(csList(1).mineral,ni.mineral) && ...
  max(abs(csList(1).color-ni.color)) < 1e-12, ...
  'check_ebsdImport: generated script lost the notIndexed name or color')
assert(strcmp(csList(2).mineral,cs2.mineral) && ...
  max(angle(csList(2).axes,cs2.axes)) < 1e-10 && ...
  max(abs(csList(2).color-cs2.color)) < 1e-12, ...
  'check_ebsdImport: generated script lost the crystal alignment, name or color')
assert(max(abs(csList(3).color-cs3.color)) < 1e-12, ...
  'check_ebsdImport: generated script lost an indexed phase color')
assert(strcmp(csList(3).mineral,'dominant'), ...
  'check_ebsdImport: generated script ignored the edited table mineral name')

assert(contains(str,'''dataSet'',1'), ...
  'check_ebsdImport: generated script lost the first selected data set')
assert(contains(str,"pC = plottingConvention('y↑→x');"), ...
  'check_ebsdImport: generated script did not use MTEX 7 plotting syntax')
% data landing in a named frame - anything from an Oxford instrument - keeps
% that frame's convention, so the import has to be told, not just the session
assert(contains(str,"'EulerCorrection',EulerCorrection,pC)"), ...
  'check_ebsdImport: generated script did not pass the convention to EBSD.load')
assert(contains(str,'plottingConvention.default(pC);'), ...
  'check_ebsdImport: generated script did not set the session convention')
assert(contains(str,'O''''Brien.ctf'), ...
  'check_ebsdImport: generated script did not quote the source path')
assert(contains(str,"'mineral', 'O''Brien phase', 'color', [0.2 0.4 0.6]"), ...
  'check_ebsdImport: generated script misplaced the mineral name or color')
assert(contains(str,"plot(ebsd('dominant'),ebsd('dominant').orientations)"), ...
  'check_ebsdImport: generated script did not plot the dominant mineral by name')

% a lattice long enough to push the mineral name off the screen is what the
% line break is for, so the two are asserted together
assert(contains(str,['crystalSymmetry(''m-3m'', [4.04 4.04 4.04], ...' newline]), ...
  'check_ebsdImport: generated script kept float32 noise in a lattice parameter')
assert(contains(str,"'mineral', 'Al', 'color', 'LightSkyBlue'"), ...
  'check_ebsdImport: generated script did not name a palette color')
assert(isempty(regexp(str,'\{[^\n}]+\}','once')), ...
  'check_ebsdImport: generated script contains an unresolved template token')

% UTF8Output says what the console can render, so it must not reach a script
% that is read in the editor - see plottingConvention.arrows
old = getMTEXpref('UTF8Output',true);
restore = onCleanup(@() setMTEXpref('UTF8Output',old));
setMTEXpref('UTF8Output',false)
ascii = buildImportWizardScript(ebsd,filePath,mapConvention,eulerConvention, ...
  1,[false true true],["not' indexed" "O'Brien phase" "dominant"]);
clear restore
assert(strcmp(ascii,str), ...
  'check_ebsdImport: generated script follows the UTF8Output preference')

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

% the scan is not a full rectangle, so what has to survive is the number of
% indexed pixels - 565, since its 613 measurements fall into 565 lattice cells
% and gridify keeps one per cell, which is also why EBSD.load refuses to grid it
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

% 15 × 15 at a 2 um step - if the first row had been dropped the map would
% not be square any more
assert(length(e) == 225, ...
  'check_ebsdImport: ACOM.ang has %d pixels, expected 225', length(e))

end

% =========================================================================
function checkEMSphInxAngROI
% a region of interest EMSphInx left out of the run must import as notIndexed
%
% EMSphInx writes a value for every pixel of the scan grid but only indexes
% the pixels inside a ROI mask, and it flags nothing: a masked pixel arrives
% with a valid looking phase number at orientation (0,0,0) with every quality
% measure zero. Left indexed they fuse into one huge grain at that
% orientation, which is what the map then looks like.
%
% The file written here carries an SEM signal column that keeps reading
% outside the ROI, because that is what defeated the first version of
% markUnmeasured: it asked for every numeric property of a pixel to be zero,
% so one column that is legitimately not zero out there switched the whole
% check off without a word. Only quality measures may count.
%
% The EDAX flavour of the same map is the control. It is byte for byte the
% same layout - the two are only told apart by the header fingerprint - and
% it must come back untouched, since a zero orientation in a real EDAX
% export is a measurement like any other.

nx = 12; ny = 10; nOutside = ny*numel(nx/2:nx-1);

f = writeSyntheticAng('EMSphInx',nx,ny);
c = onCleanup(@() delete(f));

evalc('e = EBSD.load(f,''noGrid'');');

assert(nnz(~e.isIndexed) == nOutside, ...
  ['check_ebsdImport: an EMSphInx .ang with a %d pixel ROI mask imported %d ' ...
   'notIndexed pixels, expected %d - the masked region is being read as data'], ...
  nOutside, nnz(~e.isIndexed), nOutside)

% and it has to be the masked half, not just the right count
assert(all(~e.isIndexed(e.x >= (nx/2)*0.5)) && all(e.isIndexed(e.x < (nx/2)*0.5)), ...
  'check_ebsdImport: the pixels marked notIndexed are not the ones outside the ROI')

assert(all(isnan(e.rotations(~e.isIndexed))), ...
  'check_ebsdImport: an unmeasured pixel kept its (0,0,0) orientation instead of NaN')

fEDAX = writeSyntheticAng('EDAX',nx,ny);
cEDAX = onCleanup(@() delete(fEDAX));

evalc('eEDAX = EBSD.load(fEDAX,''noGrid'');');

assert(nnz(~eEDAX.isIndexed) == 0, ...
  ['check_ebsdImport: the same map in the EDAX flavour lost %d pixels to ' ...
   'notIndexed - a zero orientation in a genuine EDAX export is a measurement'], ...
  nnz(~eEDAX.isIndexed))

end

% =========================================================================
function f = writeSyntheticAng(flavour,nx,ny)
% write an nx × ny .ang whose right half was never measured
%
% Both flavours write the identical layout - ten columns, phase in column 8 -
% and differ only in what loadEBSD_ang fingerprints them by: EMSphInx fills
% in no phase description at all (no material name, no reflectors, no
% VERSION line) and numbers the phases from 0, EDAX names the material,
% lists reflectors and numbers from 1.

isEMSphInx = strcmp(flavour,'EMSphInx');

if isEMSphInx
  mineral = ''; nFamilies = 0; version = {};
else
  mineral = 'Iron'; nFamilies = 2; version = {'# VERSION 5'};
end

hdr = [{'# TEM_PIXperUM     1.000000'
        '# x-star           0.500000'
        '# y-star           0.500000'
        '# z-star           0.500000'}
       version(:)
      {'#'
       '# Phase            1'
      ['# MaterialName     ' mineral]
       '# Formula          '
       '# Info             '
       '# Symmetry         43'
      ['# NumberFamilies   ' num2str(nFamilies)]
       '# LatticeConstants 2.870 2.870 2.870 90.000 90.000 90.000'}];

for k = 1:nFamilies
  hdr{end+1,1} = sprintf('# hklFamilies    %d  %d  0 1 0.000000 1',2-k,k-1); %#ok<AGROW>
end

hdr = [hdr
      {'# Categories 0 0 0 0 0 '
       '#'
       '# GRID:            SqrGrid'
       '# XSTEP:           0.500000'
       '# YSTEP:           0.500000'
      ['# NCOLS_ODD:       ' num2str(nx)]
      ['# NCOLS_EVEN:      ' num2str(nx)]
      ['# NROWS:           ' num2str(ny)]
       '#'
       '# OPERATOR:        unknown'
       '#'}];

f = [tempname '.ang'];
fid = fopen(f,'w');

assert(fid > 0, 'check_ebsdImport: could not write the synthetic .ang to %s', f)

fprintf(fid,'%s\n',hdr{:});

for iy = 0:ny-1
  for ix = 0:nx-1

    if ix < nx/2
      % phi1 Phi phi2   x      y     IQ   CI  phase  SEM   fit
      row = [0.3 0.4 0.5, ix*0.5, iy*0.5, 0.7, 0.9, 0, 130+ix, 1.2];
    else
      % outside the ROI: no orientation and no quality at all - but the SEM
      % detector went on reading, and that reading is not zero
      row = [0   0   0,   ix*0.5, iy*0.5, 0,   0,   0, 130+ix, 0];
    end

    if ~isEMSphInx, row(8) = 1; end

    fprintf(fid,'%9.5f %9.5f %9.5f %12.5f %12.5f %8.1f %6.3f %2d %7.1f %6.3f\n',row);

  end
end

fclose(fid);

end

% =========================================================================
function checkCprMissingPhase
% a phase the .cpr counts but never describes must not shift the others
%
% [Phases] Count is not always matched by that many [PhaseN] sections. A
% Channel-5 stitch of six projects announced 13 phases, wrote 12 sections,
% and its .crc did use phase 13 on 1949 pixels. Reading the count as
% "sections present" throws on the missing field, which is how the file was
% found - but the failure worth a test is the other one: reading the
% sections in the order they appear moves every phase after the gap onto
% the wrong crystallography, silently. So the undescribed phase has to keep
% its slot, and its pixels become notIndexed rather than someone else's
% mineral.
%
% All three positions are covered, because only a gap that is not last can
% shift anything, and the file that produced the bug had the last one
% missing. omit = 0 is the control: a complete file must import unchanged
% and must not warn.

names = {'Iron','Quartz','Calcite'};
nx = 8; ny = 5;

for omit = [1 2 3 0]

  f = writeSyntheticCpr(nx,ny,omit);
  c = onCleanup(@() delete(f,[f(1:end-4) '.crc'])); %#ok<NASGU>

  % state the Euler correction, a disabled warning would still update lastwarn
  lastwarn('');
  evalc(['e = EBSD.load(f,''noGrid'',''EulerCorrection'',' ...
    'rotation.byAxisAngle(zvector,180*degree));']);
  [~,warnId] = lastwarn;

  % the announced phases all keep their slot, described or not
  assert(numel(e.CSList) == numel(names)+1, ...
    ['check_ebsdImport: a .cpr announcing %d phases with section %d missing ' ...
     'gave %d phases, expected %d - a gap must not drop a slot'], ...
    numel(names), omit, numel(e.CSList), numel(names)+1)

  assert(isequal(reshape(e.phaseMap,1,[]),0:numel(names)), ...
    'check_ebsdImport: the .cpr phase map is %s, expected %s', ...
    mat2str(reshape(e.phaseMap,1,[])), mat2str(0:numel(names)))

  % and the described ones stay on their own mineral - this is the
  % assertion that catches a shift
  want = [{'notIndexed'} names];
  if omit > 0, want{omit+1} = 'notIndexed'; end

  assert(isequal(reshape(e.mineralList,1,[]),want), ...
    ['check_ebsdImport: a .cpr with section %d missing gave the minerals ' ...
     '{%s}, expected {%s}'], omit, strjoin(e.mineralList,','), strjoin(want,','))

  if omit > 0
    assert(strcmp(warnId,'MTEX:cprPhaseMissing'), ...
      ['check_ebsdImport: a .cpr with section %d missing warned ''%s'', ' ...
       'expected MTEX:cprPhaseMissing'], omit, warnId)
  else
    assert(isempty(warnId), ...
      ['check_ebsdImport: a complete .cpr warned ''%s'' - the missing phase ' ...
       'notice must only fire on a file that is short a section'], warnId)
  end

  % what the .crc states per pixel, in file order - 'noGrid' keeps that order
  filePhase = reshape(mod(0:nx*ny-1,numel(names)+1),[],1);

  % phase 0 is unindexed in every file; a phase left undescribed joins it
  unindexed = filePhase == 0 | filePhase == omit;

  assert(isequal(reshape(~e.isIndexed,[],1),unindexed), ...
    ['check_ebsdImport: with section %d missing, %d pixels came back ' ...
     'notIndexed and %d should have - an undescribed phase must lose its ' ...
     'measurements, and no described phase may'], ...
    omit, nnz(~e.isIndexed), nnz(unindexed))

  % and every described phase keeps its own crystallography, pixel by pixel
  for p = setdiff(1:numel(names),omit)
    got = unique(e.mineralList(e.phaseId(filePhase == p)));
    assert(isequal(got,names(p)), ...
      ['check_ebsdImport: with section %d missing, the pixels of phase %d ' ...
       'came back as {%s}, expected %s - the phases shifted across the gap'], ...
      omit, p, strjoin(got,','), names{p})
  end

end

end

% =========================================================================
function f = writeSyntheticCpr(nx,ny,omit)
% write a tiny Oxford .cpr/.crc pair announcing three phases
%
% omit is the number of the [PhaseN] section left out of the .cpr, 0 for a
% complete file. [Phases] Count always says three, which is the point: the
% count and the sections disagree exactly as they do in the stitched file.
%
% The .crc is the raw record layout the .cpr's [Fields] describes - here one
% phase byte followed by phi1, Phi, phi2 and MAD as 4 byte floats - with the
% coordinates implicit in xCells/yCells. Phase numbers cycle 0..3, so every
% announced phase and the notIndexed 0 occur equally often.

phases = {
  'Iron',    [2.870 2.870 2.870],  [90 90 90],  11, 229
  'Quartz',  [4.913 4.913 5.504],  [90 90 120],  7, 152
  'Calcite', [4.989 4.989 17.053], [90 90 120],  7, 167};

f = [tempname '.cpr'];

fid = fopen(f,'w');
assert(fid > 0, 'check_ebsdImport: could not write the synthetic .cpr to %s', f)

fprintf(fid,'[General]\nVersion=5.0\n');
fprintf(fid,'[Job]\nGridDistX=1.0000\nGridDistY=1.0000\nxCells=%d\nyCells=%d\n',nx,ny);
fprintf(fid,'[Fields]\nCount=4\nField1=3\nField2=4\nField3=5\nField4=6\n');
fprintf(fid,'[Phases]\nCount=%d\nNoReflectors=75\n',size(phases,1));

for p = 1:size(phases,1)

  if p == omit, continue, end

  fprintf(fid,'[Phase%d]\nStructureName=%s\nEnabled=True\n',p,phases{p,1});
  fprintf(fid,'a=%.4f\nb=%.4f\nc=%.4f\n',phases{p,2});
  fprintf(fid,'alpha=%.2f\nbeta=%.2f\ngamma=%.2f\n',phases{p,3});
  fprintf(fid,'LaueGroup=%d\nSpaceGroup=%d\n',phases{p,4},phases{p,5});

end

fclose(fid);

% the binary companion - 17 bytes per pixel, in the order [Fields] gives
n = nx*ny;
rec = zeros(17,n,'uint8');
rec(1,:) = uint8(mod(0:n-1,size(phases,1)+1));                % phase
rec(2:end,:) = reshape(typecast(single(repmat([0.3;0.4;0.5;0.7],n,1)),'uint8'),16,n);

fid = fopen([f(1:end-4) '.crc'],'w');
assert(fid > 0, 'check_ebsdImport: could not write the synthetic .crc')

fwrite(fid,rec,'uint8');
fclose(fid);

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
