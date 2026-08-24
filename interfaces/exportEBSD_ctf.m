function exportEBSD_ctf(ebsd,fName,varargin)
% export EBSD data to a Channel 5 text file (ctf)
%
% Description
%
% The resulting ctf file can for instance be opened with Channel 5, Aztec
% or Atex. Where the data was imported from a ctf file, the acquisition
% parameters that MTEX does not model - magnification, tilt, detector
% orientation - are taken over from |ebsd.opt.header| instead of being
% written as zeros. They can also be handed over as the structure a cpr
% file import returns, or typed in.
%
% Phases are written the way Channel numbers them: 1 to N in the order of
% the phase table, with 0 for not indexed.
%
% Syntax
%
%   ebsd = EBSD.load('myfile.ang')
%
%   export(ebsd,'myFile.ctf')
%   exportEBSD_ctf(ebsd,'myFile.ctf',cprStruct)
%   exportEBSD_ctf(ebsd,'myFile.ctf','manual')
%
% Input
%  ebsd      - @EBSD
%  fName     - Filename, optionally including relative or absolute path
%  cprStruct - structure with properties from a cpr file import
%
% Options
%  EulerCorrection - alignment of the Euler angle and the map reference
%                    frame the file is written for, default is the rotation
%                    of 180 degree about z that loadEBSD_ctf reads with
%
% Flags
%  manual - prompt for the microscopy parameters
%  flipud - flip ebsd spatial data upside down (not the orientation data)
%  fliplr - flip ebsd spatial data left right (not the orientation data)
%  silent - do not print what is being written
%
% Authors
% Originally contributed by Dr. Frank Niessen, University of Wollongong,
% 2019, with acknowledgements to Dr. Azdiar A. Gazder - see the license at
% the end of this file.
%
% See also
% EBSD.export exportEBSD_ang exportEBSD_h5

silent = check_option(varargin,'silent');
scrPrnt(silent,'SegmentStart','Exporting ''ctf'' file');
scrPrnt(silent,'Step','Collecting data');

if check_option(varargin,'flipud')
  ebsd = flipud(ebsd);
  scrPrnt(silent,'SubStep','flipping EBSD spatial data upside down');
end
if check_option(varargin,'fliplr')
  ebsd = fliplr(ebsd);
  scrPrnt(silent,'SubStep','flipping EBSD spatial data left right');
end

% the MTEX point group id of every Channel Laue group
mtexId2ctfId = [1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,6,6,7,7,7,7,7,7,4,4,...
  4,5,5,5,5,5,8,8,8,9,9,9,9,9,10,10,11,11,11];

% undo the Euler correction loadEBSD_ctf applies, the file states its own frame
cor = get_option(varargin,'EulerCorrection',rotation.byEuler(pi,0,0));
ebsd.rotations = inv(cor) .* ebsd.rotations;

% a ctf states every position, so it can also hold a map that is no axis aligned grid
isGrid = true;
try
  [g,keep] = gridCells(ebsd);
  [xStep,yStep] = gridSteps(g,'ctf');
catch
  isGrid = false;
  g = ebsd;
  keep = true(size(ebsd));
  uc = ebsd.unitCell;
  xStep = max(uc.x) - min(uc.x);
  yStep = max(uc.y) - min(uc.y);
end

hdr = importedHeader(ebsd);

% -- acquisition parameters ----------------------------------------------
% names and formats as a Channel text file states them, see loadEBSD_ctf
AcquParam.Str = {'Mag','Coverage','Device','KV','TiltAngle','TiltAxis',...
  'DetectorOrientationE1','DetectorOrientationE2','DetectorOrientationE3',...
  'WorkingDistance','InsertionDistance'};

AcquParam.Fmt = {'%.4f','%.0f','%s','%.4f','%.4f','%.0f','%.4f','%.4f',...
  '%.4f','%.4f','%.4f'};

cprStruct = getClass(varargin,'struct');

if isstruct(cprStruct) && isfield(cprStruct,'job') && isfield(cprStruct,'semfields')

  scrPrnt(silent,'SubStep','acquisition parameters from the cpr structure');
  AcquParam.Data{1} = cprStruct.job.magnification;
  AcquParam.Data{2} = cprStruct.job.coverage;
  AcquParam.Data{3} = cprStruct.job.device;
  AcquParam.Data{4} = cprStruct.job.kv;              % acceleration voltage
  AcquParam.Data{5} = cprStruct.job.tiltangle;
  AcquParam.Data{6} = cprStruct.job.tiltaxis;
  AcquParam.Data{7} = cprStruct.semfields.doeuler1;  % detector orientation
  AcquParam.Data{8} = cprStruct.semfields.doeuler2;
  AcquParam.Data{9} = cprStruct.semfields.doeuler3;
  AcquParam.Data{10} = 0;
  AcquParam.Data{11} = 0;

elseif check_option(varargin,'manual')

  scrPrnt(silent,'SubStep','acquisition parameters typed in');

  answer = inputdlg(strcat(AcquParam.Str,':'),'Input parameters - numeric only',...
    [1 100],sprintfc('%d',zeros(1,11)));

  if isempty(answer), error('Terminated by user'); end

  AcquParam.Data = arrayfun(@str2double, answer, 'Uniform', false);

else

  % whatever the file the data came from stated, zero for the rest
  AcquParam.Data = cell(1,numel(AcquParam.Str));
  fromHeader = false;
  for i = 1:numel(AcquParam.Str)
    if strcmp(AcquParam.Fmt{i},'%s')
      AcquParam.Data{i} = hdrGet(hdr,AcquParam.Str(i),'');
    else
      AcquParam.Data{i} = hdrGet(hdr,AcquParam.Str(i),0);
    end
    fromHeader = fromHeader || ~isempty(hdrGet(hdr,AcquParam.Str(i),''));
  end

  if fromHeader
    scrPrnt(silent,'SubStep','acquisition parameters from the imported header');
  else
    scrPrnt(silent,'SubStep','acquisition parameters not available, set to 0');
  end

end

% -- header --------------------------------------------------------------
scrPrnt(silent,'Step','Writing file header');

filePh = fopen(fName,'w');
if filePh < 0
  error('MTEX:exportEBSD_ctf:openFailed','Could not open %s for writing.',fName);
end
cleanup = onCleanup(@() fclose(filePh));

fprintf(filePh,'Channel Text File\r\n');
fprintf(filePh,'Prj %s\r\n',hdrGet(hdr,{'Prj'},fName));
fprintf(filePh,'Author\t%s\r\n',hdrGet(hdr,{'Author'},getenv('USERNAME')));
fprintf(filePh,'JobMode\t%s\r\n',hdrGet(hdr,{'JobMode'},'Grid'));

if isGrid
  fprintf(filePh,'XCells\t%.0f\r\n',size(keep,2));
  fprintf(filePh,'YCells\t%.0f\r\n',size(keep,1));
else
  fprintf(filePh,'XCells\t%.0f\r\n',numel(unique(g.pos.x)));
  fprintf(filePh,'YCells\t%.0f\r\n',numel(unique(g.pos.y)));
end
fprintf(filePh,'XStep\t%.4f\r\n',xStep);
fprintf(filePh,'YStep\t%.4f\r\n',yStep);

% the acquisition surface orientation - reported by the file, not applied
% to the data, see applyEulerCorrectionFixed
fprintf(filePh,'AcqE1\t%.4f\r\n',hdrGet(hdr,{'AcqE1'},0));
fprintf(filePh,'AcqE2\t%.4f\r\n',hdrGet(hdr,{'AcqE2'},0));
fprintf(filePh,'AcqE3\t%.4f\r\n',hdrGet(hdr,{'AcqE3'},0));

fprintf(filePh,'Euler angles refer to Sample Coordinate system (CS0)!\t');
for i = 1:length(AcquParam.Str)
  if ~strcmp(AcquParam.Fmt{i},'%s')
    AcquParam.Data{i} = num2str(AcquParam.Data{i},AcquParam.Fmt{i});
  elseif ~ischar(AcquParam.Data{i})
    AcquParam.Data{i} = num2str(AcquParam.Data{i});
  end
  fprintf(filePh,'%s\t%s\t',AcquParam.Str{i},AcquParam.Data{i});
end
fprintf(filePh,'\r\n');

% -- phases --------------------------------------------------------------
% Channel numbers the phases 1 to N in the order of this table, 0 is not indexed
phaseId = ebsd.indexedPhasesId;

fprintf(filePh,'Phases\t%.0f\r\n',numel(phaseId));

for i = 1:numel(phaseId)

  cs = csOf(ebsd,phaseId(i));

  laueGr = mtexId2ctfId(cs.id);
  spaceGr = 0;                       % not modelled by MTEX
  if isfield(cs.opt,'spaceId'), spaceGr = double(cs.opt.spaceId); end

  fprintf(filePh,'%.3f;%.3f;%.3f\t%.3f;%.3f;%.3f\t%s\t%.0f\t%.0f\t\t\t%s\r\n',...
    cs.aAxis.abs,cs.bAxis.abs,cs.cAxis.abs,...
    cs.alpha/degree,cs.beta/degree,cs.gamma/degree,...
    cs.mineral,laueGr,spaceGr,'Created from mtex');

end

% -- data ----------------------------------------------------------------
scrPrnt(silent,'Step','Assembling data array');

fprintf(filePh,'Phase\tX\tY\tBands\tError\tEuler1\tEuler2\tEuler3\tMAD\tBC\tBS\r\n');

% gridify orders y then x, so the file order - x fastest - is the transposed matrix
if isGrid
  ordAll = reshape(reshape(1:numel(g),size(g)).',[],1);
  sel = ordAll(reshape(keep.',[],1));
else
  [~,sel] = sortrows([g.pos.y(:),g.pos.x(:)]);
end

notes = {};
if ~isGrid
  notes{end+1} = sprintf(...
    ['the map is no grid aligned with x and y - the measurements are '...
    'written as they are and XStep/YStep state the unit cell (%.4g, %.4g)'],...
    xStep,yStep);
end
[bands,notes] = getColumn(g,{'bands','nindexedbands','radonbandcount'},0,'Bands',notes);
[err,notes] = getColumn(g,{'error'},0,'Error',notes);
[mad,notes] = getColumn(g,{'mad','meanangulardeviation','fit'},0,'MAD',notes);
[bc,notes] = getColumn(g,{'bc','bandcontrast','iq','imagequality','radonquality'},0,'BC',notes);
[bs,notes] = getColumn(g,{'bs','bandslope','semsignal','sem_signal'},0,'BS',notes);

A = zeros(numel(sel),11);
A(:,1) = fileOrder(phaseColumn(g,phaseId),sel);
A(:,2) = fileOrder(g.pos.x,sel);
A(:,3) = fileOrder(g.pos.y,sel);
A(:,4) = fileOrder(bands,sel);
A(:,5) = fileOrder(err,sel);
A(:,6) = fileOrder(g.rotations.phi1,sel)/degree;
A(:,7) = fileOrder(g.rotations.Phi,sel)/degree;
A(:,8) = fileOrder(g.rotations.phi2,sel)/degree;
A(:,9) = fileOrder(mad,sel);
A(:,10) = fileOrder(bc,sel);
A(:,11) = fileOrder(bs,sel);

A(isnan(A)) = 0;

% the file states positions relative to its own origin
A(:,2) = A(:,2) - min(A(:,2));
A(:,3) = A(:,3) - min(A(:,3));

for i = 1:numel(notes), scrPrnt(silent,'SubStep',notes{i}); end

scrPrnt(silent,'Step',sprintf('Writing %d measurements to ''%s''',size(A,1),fName));
fprintf(filePh,'%.0f\t%.4f\t%.4f\t%.0f\t%.0f\t%.4f\t%.4f\t%.4f\t%.4f\t%.0f\t%.0f\r\n',A.');

scrPrnt(silent,'Step','All done');

end

% ------------------------------------------------------------------------
function p = phaseColumn(g,phaseId)
% the phase column: the position in the phase table written above, 0 for
% not indexed

p = zeros(size(g));

for k = 1:numel(phaseId)
  p(reshape(g.phaseId,size(g)) == phaseId(k)) = k;
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

% MIT License
%
% Copyright (c) 2019 Frank Niessen
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
