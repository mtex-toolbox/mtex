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

mtexdata twins;

[grains, ebsd.grainId] = calcGrains(ebsd('indexed'));

% this command here is important :)
ebsd = ebsd.project2FundamentalRegion(grains);

plot(ebsd('indexed'),ebsd('indexed').orientations)

%%
% Now we can use the command <EBSD.interp.html |interp|> to interpolate the
% orientation at arbitrary coordinates |x| and |y|.

x = 30.5; y = 5.5;
e1 = interp(ebsd,x,y)

%%
% By default the command <EBSD.interp.html |interp|> performs inverse
% distance interpolation. This is different to 

e2 = ebsd('xy',x,y)

%%
% which returns the nearest neighbour EBSD measurement. Lets have a look at
% the difference

angle(e1.orientations,e2.orientations)./degree

%% Change of the measurement grid
% The command <EBSD.interp.html |interp|> can be used to evaluate the EBSD
% map on a different grid, which might have higher or lower resolution or
% might even be rotated. Lets demonstrate this 

% define a rotated coarse grid
omega = 5*degree;
[xmin, xmax, ymin, ymax] = ebsd.extend;
x = linspace(xmin-cos(omega)*ymax,xmax,100);
y = linspace(ymin-sin(omega)*xmax,ymax,50);
[x,y] = meshgrid(x,y);

xy = [cos(omega) -sin(omega); sin(omega) cos(omega) ] * [x(:),y(:)].';

% define the EBSD data set on this new grid
ebsdNewGrid = interp(ebsd,xy(1,:),xy(2,:))

% plot the regridded EBSD data set
plot(ebsdNewGrid('indexed'),ebsdNewGrid('indexed').orientations)

%%
% Note, that we have not rotated the EBSD data but only the grid. All
% orientations as well as the position of all grains remains unchanged.
%
% Another example is the change from a square to an hexagonal grid or vice
% versa. In this case the command <EBSD.interp.html |interp|> is
% implicitely called by the command <EBSD.gridify.html |gridify|>. In order
% to demonstrate this functionality we start by EBSD data on a hex grid

mtexdata ferrite silent

plot(ebsd,ebsd.orientations)

%%
% and resample the data on a square grid. To do so we first define a
% smaller square unit cell corresponding to the hexagonal unit cell

% define a square unit cell
hexUnitCell = abs(round(ebsd.unitCell,4));
minUnit = min(hexUnitCell(hexUnitCell>0));
squnitCell = minUnit * [-1 -1;-1 1; 1 1; 1 -1];

% use the square unit cell for gridify
ebsd = ebsd.gridify('unitCell',squnitCell);

plot(ebsd,ebsd.orientations)
