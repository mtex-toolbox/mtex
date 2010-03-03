function ebsd = loadEBSD_ctf(fname,varargin)

% read file header
hl = file2cell(fname,100);

% check that this is a channel text file
if isempty(strmatch('Channel Text File',hl{1})); 
  error('MTEX:wrongInterface','Interface ctf does not fit file format!');
elseif check_option(varargin,'check')
  return
end

% Line 2 - Prj
project = hl{2};

% Author
author = sscanf(hl{3},'Author\t%s');

% JobMode
Job = sscanf(hl{4},'JobMode\t%s');


%********************************************************
% Grid Parameters for EBSD Map
%********************************************************
if strcmp(Job,'Grid')

  % XCells and YCells
  ixcells = sscanf(hl{5},'XCells\t%u',1);
  iycells = sscanf(hl{6},'YCells\t%u',1);
  
  % Xstep and Ystep
  xsteps = sscanf(hl{7},'XStep\t%u',1);
  ysteps = sscanf(hl{8},'YStep\t%u',1);
      
  nextline = 9;
  
elseif strcmp(Job,'Interactive')

  % Number of measurements
  NoMeas = sscanf(hl{5},'NoMeas\t%u',1);
  
  nextline = 6;
end

% AcqE1, AcqE2
iAcqE1 = sscanf(hl{nextline},'AcqE1\t%u',1);
iAcqE2 = sscanf(hl{nextline+1},'AcqE2\t%u',1);
iAcqE3 = sscanf(hl{nextline+2},'AcqE3\t%u',1);

%********************************************************
% Microscope Parameters
%********************************************************

mpara = regexpsplit(hl{nextline+3},'\t');
%mpara = splitstr(hl{nextline+3},char(9));

SCS = mpara{1}; % sample coordinate system
mag = mpara{3}; % Magnification
Cover = mpara{5}; % Coverage
Device= mpara{7};
KV = mpara{9};

Tilt_Angle = mpara{11}; % Tilt Angle
Tilt_Axis = mpara{13}; % Tilt Axis
ss = symmetry;

% Crystallogaphic Parameters of all phases
Laue = {'-1','2/m','mmm','4/m','4/mmm',...
  '-3','-3m','6/m','6/mmm','m3','m3m'};

% number of phases
NPHASES = sscanf(hl{nextline + 4},'Phases\t%u');

for K = 1:NPHASES
  
  % load phase
  mpara = regexpsplit(hl{nextline+4+K},'\t');
  %mpara = splitstr(hl{nextline+4+K},char(9));
    
  abc = sscanf( mpara{1},'%f;%f;%f'); % Lattice ABC
  abg = sscanf( mpara{2},'%f;%f;%f'); % Lattice alpha beta gamma
  
  % Phase name
  mineral = mpara{3};
  
  % Laue group (class) number
  laue = Laue{sscanf(mpara{4},'%u')};
  cs{K} = symmetry(laue,abc(:)',abg(:)','mineral',mineral); %#ok<AGROW>
     
end

ebsd = loadEBSD_generic(fname,'cs',cs,'ss',ss,'bunge','degree',...
  'ColumnNames',{'Phase' 'X' 'Y' 'Bands' 'Error' 'Euler 1' 'Euler 2' 'Euler 3' 'MAD' 'BC' 'BS'}, ...
  'Columns',1:11,varargin{:});
