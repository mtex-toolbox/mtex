%% Modify EBSD Data
%

%% Abstract
% Support for EBSD data in MTEX is still at an early stage.
%
%% Contents
%
%% Import some EBSD data

cs = symmetry('m-3m'); % crystal symmetry
ss   = symmetry('triclinic');        % specimen symmetry

% file names
fname = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];


% load data
ebsd = loadEBSD(fname,cs,ss,... 
                'interface','generic','Bunge','ignorePhase',[0 2],...
                 'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3'},...
                 'Columns', [2 3 4 5 6 7]);

plot(ebsd)

%% Extract a subset of orientations
%

% get the spatial coordinates
x = get(ebsd,'x');
y = get(ebsd,'y');

% restrict to a certain region
ebsd = delete(ebsd, x > 100 | y < 100);
plot(ebsd)
