%% Sample Import of EBSD Data

%% Open in Editor
%

% crystal symmetry
CS = {...
  symmetry('m-3m','mineral','Fe'),...
  symmetry('m-3m','mineral','Mg')};

% specimen symmetry
SS = symmetry('-1');

% specify file name
fname = fullfile(mtexDataPath,'EBSD','85_829grad_07_09_06.txt');


% create an EBSD variable containing the data
ebsd = loadEBSD(fname,CS,SS,'interface','generic' ...
  , 'ColumnNames', { 'Index' 'Phase' 'x' 'y' 'Euler1' 'Euler2' 'Euler3' 'MAD' 'BC' 'BS' 'Bands' 'Error' 'ReliabilityIndex'}, 'Bunge', 'ignorePhase', 0);

% plotting convention
plotx2east
