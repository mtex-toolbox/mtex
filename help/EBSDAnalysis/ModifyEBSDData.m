%% Modify EBSD Data
%
% Support for EBSD data in MTEX is still at an early stage.

%% Import some EBSD data

% load the data
ebsd = loadEBSD([mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'],...
  'interface','generic', 'Bunge', ...
  'layout', [5 6 7], 'Phase', 2, 'xy', [3 4], ...
  'ColumnNames', { 'Index' 'MAD' 'BC' 'BS' 'Bands' 'Error' 'RI' } , ...
  'ColumnIndex', [1 8 9 10 11 12 13]);

plot(ebsd)

%% Extract a subset of orientations
% set ebsd only to phase 1 and 2
ebsd = ebsd(2:3);

%%
% get the spatial coordinates

x = get(ebsd,'x');
y = get(ebsd,'y');

%%
% restrict to a certain region
ebsd = ebsd(:, x > 50 & x < 150 & y > 100);
plot(ebsd,'IHS')

%%
% get Kikutuchi Band Contrast
BC = get(ebsd,'BC');
%%
% delete data
ebsd = delete(ebsd, BC < 60);
plot(ebsd,'BC','colormap',hsv,'white')

%% Subset of certain Orientations

q = mean(ebsd);
ebsd = subGrid(ebsd,q(1),25*degree);

plotebsd(ebsd,'g');

%%
q = mean(ebsd);
ebsd = subGrid(ebsd,q(1),12.5*degree);

hold on
plotebsd(ebsd,'r');

%% 
% specify it in xy-plot

plot(ebsd,'IHS','white')

%% Rotation arround orientation 

q = mean(ebsd);
ebsd = rotate(ebsd,q(1)');
plot(ebsd,'IHS','white')

