%% Modify EBSD Data
%
% Support for EBSD data in MTEX is still at an early stage.

%% Import some EBSD data

cs = symmetry('-3m',[1.2 1.2 3.5]); % crystal symmetry
ss   = symmetry('triclinic');        % specimen symmetry

% file names
fnames = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];

% load data
ebsd = loadEBSD(fnames,cs,ss,'header',1,'layout',[5,6,7],'xy',[3 4])

plot(ebsd)

%% Extract a subset of orientations
%

% get the spatial coordinates
x = get(ebsd,'x');
y = get(ebsd,'y');

% restrict to a certain region
ebsd = delete(ebsd, x > 100 | y < 100);
plot(ebsd)
