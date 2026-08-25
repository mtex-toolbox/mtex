%% Interpolating EBSD Data
%
%%
% <EBSDDenoising.html Denoising> and <EBSDFilling.html Filling Missing
% Data> both leave the measurement grid exactly as it was. This page is
% about the other case: reading the map at positions that are not grid
% points at all, and resampling it onto a different grid.

plottingConvention.default('y↑→x');
mtexdata twins;

[grains, ebsd] = calcGrains(ebsd);

plot(ebsd,ebsd.orientations)

%% Reading the map at a point
%
% <EBSD.interp.html |interp|> evaluates the map at arbitrary coordinates.
% It makes no assumption about a grid - a plain @EBSD, a phase subset and a
% rotated or sheared map all work - although this map is an @EBSDsquare
% anyway, since that is how it was imported, see
% <EBSDGrid.html Square and Hex Grids>.

x = 30.5; y = 5.5;
e1 = interp(ebsd,x,y)

%%
% The rule is local and simple: the query takes the data of the measurement
% it is nearest to, provided it falls inside that measurement's pixel.
% A query further away than the pixel reaches - outside the map, or in a
% hole in it - comes back as notIndexed rather than as an extrapolation.
%
% Picking out the nearest measurement is what the |'xy'| selector does,

e2 = ebsd('xy',x,y)

%%
% and inside the map the two therefore report the same orientation.

angle(e1.orientations,e2.orientations)./degree

%%
% What differs is the result. |'xy'| hands back one of the original
% measurements, with its own position and id; |interp| builds a new EBSD
% variable that sits at the positions asked for, and it takes a whole list
% of them - which is what makes resampling possible.
%
%% Resampling onto a different grid
%
% A new grid is described by its unit cell, and <EBSD.gridify.html
% |gridify|> builds the grid from the cell to cell translations of that
% cell, calling |interp| for the values. Here is a cell of twice the size,
% turned by 45 degrees.

% unit cell of twice the size, rotated by 45 degree
uC = rotate(2*ebsd.unitCell,45*degree);

% define the EBSD data set on this new grid
ebsdNewGrid = gridify(ebsd,'unitCell',uC)

% plot the regridded EBSD data set
plot(ebsdNewGrid('indexed'),ebsdNewGrid('indexed').orientations)

xlim(ebsd.extent(1:2)), ylim(ebsd.extent(3:4))

%%
% The data has not been rotated, only the grid: every orientation and every
% grain is where it was, drawn with coarser, tilted pixels. Since a tilted
% grid cannot fill a rectangular matrix, the corners of |ebsdNewGrid| stick
% out beyond the map and hold no data - fewer than half of its 108 by 109
% cells are indexed - which is why the plot above is restricted to the
% indexed ones.
%
%% From a hexagonal to a square grid
%
% The same mechanism changes the grid type. Starting from data measured on
% a hexagonal grid,

plottingConvention.default('y↓→x');
mtexdata ferrite silent
plot(ebsd(1:50,1:100),ebsd(1:50,1:100).orientations)

%%
% a square cell of half the measurement spacing is small enough to resolve
% it, and |gridify| does the rest.

% define a square unit cell
squnitCell = ebsd.dPos / 4 * vector3d([-1 -1 1 1],[-1 1 1 -1],0).';

% use the square unit cell for gridify

ebsdS = ebsd.gridify('unitCell',squnitCell);

plot(ebsdS(1:150,1:350),ebsdS(1:150,1:350).orientations)

%%
% The result is an @EBSDsquare of 808 by 809 cells covering the area the
% 270 by 234 hexagonal cells did, about ten times as many. No orientation
% was invented on the way - each new cell repeats the hexagonal measurement
% it falls inside, which is why the boundaries of the resampled map are
% stepped rather than smooth.
%
