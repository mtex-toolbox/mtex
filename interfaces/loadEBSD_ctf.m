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
%

% read file header
hl = file2cell(fname,100);
  
% check that this is a channel text file
if isempty(strfind(hl{1},'Channel Text File'))
  error('MTEX:wrongInterface','Interface ctf does not fit file format!');
elseif check_option(varargin,'check')
  return
end
   
phase_line = find(contains(hl,'Phases'));

nphase = sscanf(hl{phase_line},'%s\t%u');
nphase = nphase(end);
  
% Crystallographic Parameters of all phases
Laue = {'-1','2/m','mmm','4/m','4/mmm','-3','-3m','6/m','6/mmm','m3','m3m'};
  
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
  
try
  ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','degree',...
    'ColumnNames',{'Phase' 'X' 'Y' 'Bands' 'Error' 'Euler 1' 'Euler 2' 'Euler 3' 'MAD' 'BC' 'BS'}, ...
    'Columns',1:11,varargin{:});
catch
  ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','degree',...
    'ColumnNames',{'Phase' 'X' 'Y' 'Bands' 'Error' 'Euler 1' 'Euler 2' 'Euler 3'}, ...
    'Columns',1:8,varargin{:});
end

% capture all remaining header metadata (phase/symmetry data is excluded,
% it is already captured by cs/CSList above; the column-schema line right
% after the phase table is excluded too, it is redundant with ColumnNames)
ebsd.opt.header = ctfHeaderStruct(hl,phase_line);

% x||a*, z||c


% change reference frame
correction = get_option(varargin,'EulerCorrection',rotation.byEuler(pi,0,0));

if ~check_option(varargin,'EulerCorrection') && ~check_option(varargin,'wizard') 

  fprintf(2,wraptext(['\nWarning: .ctf files usually come with different ' ...
    'coordinate systems for the Euler angles and the spatial coordinates. ' ...
    'I assumed the relative alignment of these coordinate systems to be a ' ...
    'rotation about the z-axis by 180 degree. You may want to verify this ' ...
    'and specify the correct alignment explicitely by\n\n' ...
    'ebsd = EBSD.load(fileName,''EulerCorrection'', rotation.byAxisAngle(zvector,180*degree))' ...
    '\n\n' ...
    'Click <a href="matlab:MTEXdoc(''EBSDReferenceFrame'')">here</a> for more information.'...
    '\n']))

end

ebsd.EulerCorrection = correction;

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
