function ebsd = loadEBSD_ctf(fname,varargin)
% read Oxford *.ctf file
%
% Syntax
%
%   ebsd = loadEBSD_ctf(fname)
%
% Input
%  fname - file name
%
% Options
%  EulerCorrection - @rotation that is used to correct the Euler angles
%  headerOnly - return only phase/header metadata, skip reading the data
%

assertExtension(fname,'.ctf');

% read file header
hl = file2cell(fname,100);

% check that this is a channel text file
if isempty(strfind(hl{1},'Channel Text File'))
  interfaceError(fname);
end
   
phase_line = find(contains(hl,'Phases'));

nphase = sscanf(hl{phase_line},'%s\t%u');
nphase = nphase(end);
  
% Crystallographic Parameters of all phases
Laue = {'-1','2/m','mmm','4/m','4/mmm','-3','-3m','6/m','6/mmm','m-3','m-3m'};
  
cs(1) = notIndexed;
for K = 1:nphase
    
  % load phase
  mpara = regexpsplit(hl{phase_line+K},'\t');
    
  abc = sscanf( strrep(mpara{1},',','.'),'%f;%f;%f'); % Lattice ABC
  abg = sscanf( strrep(mpara{2},',','.'),'%f;%f;%f'); % Lattice alpha beta gamma
    
  if isempty(mpara{3}), mpara(3) = []; end

  % Phase name
  mineral = mpara{3};
    
  % Laue group (class) number
  try % some ctf files might be broken
    laue = Laue{sscanf(mpara{4},'%u')};
    cs(K+1) = crystalSymmetry(laue,abc(:)',abg(:)','mineral',mineral);
  catch
    spaceId = sscanf(mpara{5},'%u'); % try spaceid
    cs(K+1) = crystalSymmetry('SpaceId',spaceId,',abc(:)',abg(:)','mineral',mineral);     
  end

end

% capture all remaining header metadata (phase/symmetry data is excluded,
% it is already captured by cs/CSList above; the column-schema line right
% after the phase table is excluded too, it is redundant with ColumnNames)
header = ctfHeaderStruct(hl,phase_line);

% hint the exact step size from the header, preferred over EBSD's own
% position-based estimate (see EBSD/updateUnitCell)
unitCellHint = {};
if isfield(header,'XStep') && isfield(header,'YStep')
  xs = header.XStep; ys = header.YStep;
  unitCellHint = {'unitCellHint',vector3d([xs,xs,-xs,-xs]/2,[-ys,ys,ys,-ys]/2,0)};
end

if check_option(varargin,'headerOnly')
  ebsd = emptyHeaderOnlyEBSD(cs,header,unitCellHint{:});
  return
end

try
  ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','degree',...
    'ColumnNames',{'Phase' 'X' 'Y' 'Bands' 'Error' 'Euler 1' 'Euler 2' 'Euler 3' 'MAD' 'BC' 'BS'}, ...
    'Columns',1:11,varargin{:},unitCellHint{:});
catch
  ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','degree',...
    'ColumnNames',{'Phase' 'X' 'Y' 'Bands' 'Error' 'Euler 1' 'Euler 2' 'Euler 3'}, ...
    'Columns',1:8,varargin{:},unitCellHint{:});
end

ebsd.opt.header = header;

% x||a*, z||c

% change reference frame
ebsd = applyEulerCorrectionFixed(ebsd,'.ctf',rotation.byEuler(pi,0,0),varargin{:});

end

function header = ctfHeaderStruct(hl,phase_line)
% flatten every general header line (before the phase table) into a
% struct; lines may pack multiple key/value pairs separated by tabs

keys = {}; values = {};
for i = 1:phase_line
  [k,v] = ctfSplitLine(hl{i});
  keys = [keys,k]; %#ok<AGROW>
  values = [values,v]; %#ok<AGROW>
end

header = buildHeaderStruct(keys,values);

end

function [keys,values] = ctfSplitLine(line)
% split a tab-separated header line into key/value pairs
%
% Lines with an even number of tab-separated fields are read as
% sequential key/value pairs (this also covers the common single-pair
% case). Lines with an odd number of fields carry a leading free-text
% note (dropped) followed by the key/value pairs.

parts = regexpsplit(line,'\t');

if mod(numel(parts),2) == 1
  parts = parts(2:end);
end

keys = parts(1:2:end);
values = parts(2:2:end);

end
