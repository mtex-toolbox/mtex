function exportEBSD_ang(ebsd,fName,varargin)
% export EBSD data to a TSL/EDAX text file (ang)
%
% Description
%
% The written file follows the layout EDAX documents as version 5, i.e. the
% columns
%
%   phi1 PHI phi2 x y IQ CI phase SEM fit
%
% and states so in the header, which is what makes it read back without
% guessing. Where the data was imported from an .ang file, the header
% values that MTEX does not model - the pattern center, the working
% distance, the operator - are taken over from |ebsd.opt.header| instead of
% being written as zeros.
%
% Pixels MTEX holds as not indexed are written the way OIM writes them:
% phase 0 and a confidence index of -1.
%
% Syntax
%
%   % import a ctf file
%   ebsd = EBSD.load('myfile.ctf')
%
%   % export as ang
%   export(ebsd,'myFile.ang')
%
% Input
%  ebsd  - @EBSD
%  fName - Filename, optionally including relative or absolute path
%
% Options
%  setting         - alignment of the Euler angle and the map reference
%                    frame the file is written for, 1 to 4, 0 switches the
%                    correction off, default is 2 - the same convention
%                    loadEBSD_ang reads with
%  EulerCorrection - explicit correction @rotation, overrides setting
%
% Flags
%  flipud - flip ebsd spatial data upside down (not the orientation data)
%  fliplr - flip ebsd spatial data left right (not the orientation data)
%  silent - do not print what is being written
%
% See also
% EBSD.export exportEBSD_ctf exportEBSD_h5

roundOff = 3; % rounding coordinates to 'roundOff' digits

silent = check_option(varargin,'silent');
scrPrnt(silent,'SegmentStart','Exporting ''ang'' file');
scrPrnt(silent,'Step','Collecting data');

if check_option(varargin,'flipud')
  ebsd = flipud(ebsd);
  scrPrnt(silent,'SubStep','flipping EBSD spatial data upside down');
end
if check_option(varargin,'fliplr')
  ebsd = fliplr(ebsd);
  scrPrnt(silent,'SubStep','flipping EBSD spatial data left right');
end

% The Euler angles of an .ang file are stated in the Euler reference frame,
% which the map reference frame is aligned with by one of the four settings
% - loadEBSD_ang applies that rotation on import, so writing has to undo it
% again. Without this an import/export cycle turned the whole map, the .ctf
% and the .ang correction being 180 degree apart.
cor = get_option(varargin,'EulerCorrection',...
  eulerCorrectionRotation(get_option(varargin,'setting',2)));
ebsd.rotations = inv(cor) .* ebsd.rotations;

% the map on its grid, and which of its cells the file lists
[g,keep] = gridCells(ebsd);
[xStep,yStep] = gridSteps(g,'ang');
isHex = isa(g,'EBSDhex');

% header values the file states but MTEX does not model - taken over from
% the file the data came from wherever it stated them
hdr = importedHeader(ebsd);

% the phase numbers to write. A file numbers its phases from 1 and keeps 0
% for not indexed, so a map whose own numbering does not fit - a single
% phase .ang numbers its one phase 0 - is renumbered rather than written
% ambiguously.
[phaseNr,renumbered] = angPhaseNumbers(ebsd);
if renumbered
  scrPrnt(silent,'SubStep','phases renumbered from 1, 0 is not indexed');
end

% Open ang file
scrPrnt(silent,'Step','Writing file header');
filePh = fopen(fName,'w');
if filePh < 0
  error('MTEX:exportEBSD_ang:openFailed','Could not open %s for writing.',fName);
end
cleanup = onCleanup(@() fclose(filePh));

% -- SEM / acquisition info ----------------------------------------------
fprintf(filePh,'# %-22s%.6f\n','TEM_PIXperUM',hdrGet(hdr,{'TEM_PIXperUM'},1));
fprintf(filePh,'# %-22s%.6f\n','x-star',hdrGet(hdr,{'x_star','xstar'},0));
fprintf(filePh,'# %-22s%.6f\n','y-star',hdrGet(hdr,{'y_star','ystar'},0));
fprintf(filePh,'# %-22s%.6f\n','z-star',hdrGet(hdr,{'z_star','zstar'},0));
fprintf(filePh,'# %-22s%.6f\n','WorkingDistance',hdrGet(hdr,{'WorkingDistance'},0));
fprintf(filePh,'#\n');

% -- phase blocks --------------------------------------------------------
for k = 1:numel(ebsd.indexedPhasesId)

  phaseId = ebsd.indexedPhasesId(k);
  cs = csOf(ebsd,phaseId);

  fprintf(filePh,'# %s %.0f\n','Phase',phaseNr(k));
  fprintf(filePh,'# %s  \t%s\n','MaterialName',cs.mineral);
  fprintf(filePh,'# %s     \t%s\n','Formula','');
  fprintf(filePh,'# %s \t\t%s\n','Info','');

  % the Laue code every .ang has, plus the point group id newer ones state
  % - the former alone would lose e.g. the difference between 622 and 6/mmm
  [laueCode,pgId] = tslSymmetryCodes(cs);
  fprintf(filePh,'# %-22s%d\n','Symmetry',laueCode);
  if ~isempty(pgId)
    fprintf(filePh,'# %-22s%d\n','PointGroupID',pgId);
  end

  fprintf(filePh,'# %-22s %4.3f %5.3f %5.3f %7.3f %7.3f %7.3f\n',...
    'LatticeConstants',cs.aAxis.abs,cs.bAxis.abs,cs.cAxis.abs,...
    cs.alpha/degree,cs.beta/degree,cs.gamma/degree);
  fprintf(filePh,'# %-22s%.0f\n','NumberFamilies',0);
  for jj = 1:6
    fprintf(filePh,'# %s \t%.6f %.6f %.6f %.6f %.6f %.6f\n',...
      'ElasticConstants',0,0,0,0,0,0);
  end
  fprintf(filePh,'# %s%.0f %.0f %.0f %.0f %.0f \n','Categories',0,0,0,0,0);
  fprintf(filePh,'#\n');

end

% -- map info ------------------------------------------------------------
if isHex
  fprintf(filePh,'# %s: %s\n','GRID','HexGrid');
else
  fprintf(filePh,'# %s: %s\n','GRID','SqrGrid');
end
fprintf(filePh,'# %s: %.6f\n','XSTEP',round(xStep,roundOff));
fprintf(filePh,'# %s: %.6f\n','YSTEP',round(yStep,roundOff));

% how many cells the rows of the file hold - on a hex grid the staggered
% rows differ by one, on a square grid they do not
nCols = sum(keep,2);
fprintf(filePh,'# %s: %.0f\n','NCOLS_ODD',nCols(1));
fprintf(filePh,'# %s: %.0f\n','NCOLS_EVEN',nCols(min(2,end)));
fprintf(filePh,'# %s: %.0f\n','NROWS',size(keep,1));
fprintf(filePh,'#\n');
fprintf(filePh,'# %s: \t%s\n','OPERATOR',hdrGet(hdr,{'OPERATOR'},'Administrator'));
fprintf(filePh,'#\n');
fprintf(filePh,'# %s: \t%s\n','SAMPLEID',hdrGet(hdr,{'SAMPLEID'},''));
fprintf(filePh,'#\n');
fprintf(filePh,'# %s: \t%s\n','SCANID',hdrGet(hdr,{'SCANID'},''));
fprintf(filePh,'#\n');

% the column layout is stated rather than left to be guessed on import
fprintf(filePh,'# %s %d\n','VERSION',5);
fprintf(filePh,'# %s\n','COLUMN_NOTES: phi1, PHI, phi2, x, y, iq, ci, phase, sem, fit');
fprintf(filePh,'#\n');

% -- data ----------------------------------------------------------------
scrPrnt(silent,'Step','Assembling data array');

% gridify orders its first dimension along y and its second along x, both
% increasing, so the file order - x fastest - is the transposed matrix read
% column wise
sel = reshape(keep.',[],1);

notes = {};
[iq,notes] = getColumn(g,{'iq','imagequality','bc','bandcontrast','radonquality'},0,'IQ',notes);
[ci,notes] = getColumn(g,{'ci','confidenceindex','bs','bandslope'},0,'CI',notes);
[sem,notes] = getColumn(g,{'sem','sem_signal','semsignal'},1,'SEM',notes);
[fit,notes] = getColumn(g,{'fit','mad','meanangulardeviation'},0,'fit',notes);

A = zeros(sum(sel),10);
A(:,1) = fileOrder(g.rotations.phi1,sel);
A(:,2) = fileOrder(g.rotations.Phi,sel);
A(:,3) = fileOrder(g.rotations.phi2,sel);
A(:,4) = fileOrder(g.pos.x,sel);
A(:,5) = fileOrder(g.pos.y,sel);
A(:,6) = fileOrder(iq,sel);
A(:,7) = fileOrder(ci,sel);
A(:,8) = fileOrder(phaseColumn(g,ebsd,phaseNr),sel);
A(:,9) = fileOrder(sem,sel);
A(:,10) = fileOrder(fit,sel);

% a pixel without an orientation is marked the way OIM marks it
notIndexed = fileOrder(~g.isIndexed,sel) > 0;
A(notIndexed,7) = -1;

A(isnan(A)) = 0;

% the file states positions relative to its own origin
A(:,4) = round(A(:,4) - min(A(:,4)),roundOff);
A(:,5) = round(A(:,5) - min(A(:,5)),roundOff);

for i = 1:numel(notes), scrPrnt(silent,'SubStep',notes{i}); end

scrPrnt(silent,'Step',sprintf('Writing %d measurements to ''%s''',size(A,1),fName));
fprintf(filePh,'%9.5f %9.5f %9.5f %12.5f %12.5f %6.1f %6.3f %2.0f %6.0f %6.3f \n',A.');

scrPrnt(silent,'Step','All done');

end

% ------------------------------------------------------------------------
function [nr,renumbered] = angPhaseNumbers(ebsd)
% the number every indexed phase gets in the file
%
% Kept as the file the data came from stated them wherever that is a valid
% .ang numbering - phases counted from 1, 0 reserved for not indexed.

nr = double(ebsd.phaseMap(ebsd.indexedPhasesId));
nr = nr(:).';

% OIM numbers the phases by their position in the very table the header
% writes, so anything else - a single phase .ang numbering its one phase 0,
% or a gap left by a deleted phase - is renumbered rather than written
% ambiguously
renumbered = ~isequal(nr,1:numel(nr));

if renumbered, nr = 1:numel(ebsd.indexedPhasesId); end

end

% ------------------------------------------------------------------------
function p = phaseColumn(g,ebsd,phaseNr)
% the phase column, in the numbering of the header written above

p = zeros(size(g));

for k = 1:numel(ebsd.indexedPhasesId)
  p(g.phaseId == ebsd.indexedPhasesId(k)) = phaseNr(k);
end

end

% ------------------------------------------------------------------------
function scrPrnt(silent,mode,varargin)

if silent, return; end

switch mode
  case 'SegmentStart'
    fprintf('\n------------------------------------------------------');
    fprintf(['\n     ',varargin{1},' \n']);
    fprintf('------------------------------------------------------\n');
  case 'Step'
    fprintf([' -> ',varargin{1},'\n']);
  case 'SubStep'
    fprintf(['    - ',varargin{1},'\n']);
end

end
