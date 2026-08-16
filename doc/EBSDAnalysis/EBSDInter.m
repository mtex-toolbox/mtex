%% Interpolating EBSD Data
%
%%
% In the section <EBSDDenoising.html Denoising> and <EBSDFilling.html
% Filling Missing Data> we have discussed how to work with noisy EBSD data
% the contained non indexed pixels. Hereby, we made the assumption that the
% grid before and after the operations is the same. 
%
% In this section we explain how to interpolate an EBSD map at positions
% that do not belong to the grid. Lets us consider a simple example

plottingConvention.default('y↑→x');
mtexdata twins;

[grains, ebsd] = calcGrains(ebsd);

% this command here is important :)
ebsd = ebsd.project2FundamentalRegion(grains);

plot(ebsd,ebsd.orientations)

%%
% The command <EBSD.interp.html |interp|> interpolates the orientation at
% arbitrary coordinates |x| and |y|. It does not require the data to be on
% a grid - a plain @EBSD, a phase subset and a rotated or sheared map work
% just as well - but our map is an @EBSDsquare anyway, since that is how it
% was imported, see <EBSDGrid.html Square and Hex Grids>.

x = 30.5; y = 5.5;
e1 = interp(ebsd,x,y)

%%
% By default the command <EBSD.interp.html |interp|> performs inverse
% distance interpolation. This is different to

e2 = ebsd('xy',x,y)

%%
% which returns the nearest neighbor EBSD measurement. Lets have a look at
% the difference

angle(e1.orientations,e2.orientations)./degree

%% Change of the measurement grid
% The command <EBSD.interp.html |interp|> can be used to evaluate the EBSD
% map on a different grid, which might have higher or lower resolution or
% might even be rotated. Lets demonstrate this 

% unit cell of twice the size, rotated by 45 degree
uC = rotate(2*ebsd.unitCell,45*degree);

% define the EBSD data set on this new grid
ebsdNewGrid = gridify(ebsd,'unitCell',uC)

% plot the regridded EBSD data set
plot(ebsdNewGrid('indexed'),ebsdNewGrid('indexed').orientations)

xlim(ebsd.extent(1:2)), ylim(ebsd.extent(3:4))

%%
% Note, that we have not rotated the EBSD data but only the grid. All
% orientations as well as the position of all grains remains unchanged.
%
% The new grid is generated from the cell to cell translations of the given
% unit cell, i.e. it is rotated by 45 degree as well. Since such a rotated
% grid can not fill a rectangular matrix, the corners of |ebsdNewGrid| stick
% out of the map and contain no data - this is why we have restricted the
% plot above to the indexed measurements.
%
%%
% Another example is the change from a square to an hexagonal grid or vice
% versa. In this case the command <EBSD.interp.html |interp|> is
% implicitly called by the command <EBSD.gridify.html |gridify|>. In order
% to demonstrate this functionality we start by EBSD data on a hex grid

mtexdata ferrite silent
plot(ebsd(1:50,1:100),ebsd(1:50,1:100).orientations)

%%
% and resample the data on a square grid. To do so we first define a
% smaller square unit cell corresponding to the hexagonal unit cell

% define a square unit cell
squnitCell = ebsd.dPos / 4 * vector3d([-1 -1 1 1],[-1 1 1 -1],0).';

% use the square unit cell for gridify

ebsdS = ebsd.gridify('unitCell',squnitCell);

plot(ebsdS(1:150,1:350),ebsdS(1:150,1:350).orientations)
