%% Gridded EBSD Data
%
%%
% In this section we discuss specific operations that are available for
% EBSD data which are measured on a square or hexagonal grid. 
%
% By default MTEX ignores any gridding in the data. The reason for this is
% that when restricting to some subset, e.g. to a certain phase, the data
% will not form a regular grid anyway. For that reason, almost all
% functions in MTEX are implemented to work for arbitrarily aligned data.
%
% On the other hand, there are certain functions that are only available or
% much faster for gridded data. Those functions include <EBSDPlotting.html
% plotting>, <EBSDGradient.html gradient computation> and
% <EBSDDenoising.html denoising>. The key command to make MTEX aware of
% EBSD data on a hexagonal or square grid is <EBSD.gridify.html gridify>.
%
% In order to explain the corresponding concept in more detail lets import
% some sample data.

plotx2east
mtexdata twins

plot(ebsd('Magnesium'),ebsd('Magnesium').orientations)

%%
% As we can see already from the phase plot above the data have been
% measured at an rectangular grid. A quick look at the unit cell verifies
% this

ebsd.unitCell

%%
% If we apply the command <EBSD.gridify.html gridify> to the data set

ebsd = ebsd.gridify

%%
% we data get aligned in a 137 x 167 matrix. In particular we may now apply
% standard matrix indexing to our EBSD data, e.g., to access the EBSD data
% at position 50,100 we can simply do

ebsd(50,100)

%% 
% It is important to understand that the property of beeing shaped as a
% matrix is lost as soon as we <EBSDSelect.html select> a subset of data

ebsdMg = ebsd('Magnesium')

%%
% However, we may always force it into matrix form by reapplying the
% command <EBSD.gridify.html gridify>

ebsdMg = ebsd('Magnesium').gridify

%%
% The difference between both matrix shapes EBSD variables *ebsd* and
% *ebsdMg* is that not indexed pixels in *ebsd* are stored as the seperate
% phase *notIndexed* while in *ebsdMg* all pixels have phase Magnesium but
% the Euler angles of the not indexed pixels are set to nan. This allows to
% select and plot subregions of the EBSD in a very intuitive way by

plot(ebsdMg(50:100,5:100),ebsdMg(50:100,5:100).orientations)

%% The Gradient
%

gradX = ebsdMg.gradientX;

plot(ebsdMg,norm(gradX))
caxis([0,4*degree])

%% Hexagonal Grids
%
% Next lets import some data on a hexagonal grid

mtexdata copper

[grains, ebsd.grainId] = calcGrains(ebsd)
ebsd = ebsd.gridify

plot(ebsd,ebsd.orientations)


%%
% Indexing works here similarly as for square grids

plot(ebsd(1:10,:),ebsd(1:10,:).orientations,'micronbar','off')

%%
%

plot(ebsd(:,1:10),ebsd(:,1:10).orientations,'micronbar','off')

%% Switching from Hexagonal to Square Grid
%
% Sometimes it is required to resample EBSD data on a hex grid on a square
% grid. This can be accomplished by passing to the command
% <EBSD.gridify.html gridify> a square unit cell by the option |unitCell|.

% define a square unit cell
unitCell = [-2.5 -2.5; -2.5 2.5; 2.5 2.5; 2.5 -2.5];

% use the square unit cell for gridify
ebsdS = ebsd.gridify('unitCell',unitCell)

% visualize the result
plot(ebsdS, ebsdS.orientations)

%%
% In the above example we have chosen the square unit cell to have
% approximately the same size as the hexgonal unit cell. This leads to
% quite some distortions as squares can not reproduces all the shapes of
% the hexagones. We can reduce this issue by chosing the quare unit cell
% significantly smaller then the hexagonal unit cell.

% a smaller unit cell
unitCell = [-1 -1; -1 1; 1 1; 1 -1];

% use the small square unit cell for gridify
ebsdS = ebsd.gridify('unitCell',unitCell)

plot(ebsdS,ebsdS.orientations)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%%
% It is important to understand that the command <EBSD.gridify.html
% gridify> does not increase the number of data points. As a consquence, we
% end up with many white spots in the map which corresponds to orientations
% that have been set to NaN. In order to fill these white spots, we may
% either use the command <EBSD.fill.html fill> which performs nearest
% neighbour interpolation or the command <EBSD.smooth smooth> which allows
% for more suffisticated interpolation methods.

%%

% nearest neigbour interpolation
ebsdS1 = fill(ebsdS,grains)

plot(ebsdS1('indexed'),ebsdS1('indexed').orientations)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%%

% interpolation using a TV regularisation term
F = halfQuadraticFilter;
F.alpha = 0.5;
ebsdS2 = smooth(ebsdS,F,'fill',grains)

plot(ebsdS2('indexed'),ebsdS2('indexed').orientations)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%% Gridify on Rotated Maps
% A similar situation occurs if <EBSD.gridify.html gridify> is applied to
% rotated data.

ebsd = rotate(ebsd,20*degree)

ebsdG = ebsd.gridify

plot(ebsdG,ebsdG.orientations)

%%
% Again we may observe white spots within the map which we can easily fill
% with the <EBSD.fill.html fill> command.

ebsdGF = fill(ebsdG)

plot(ebsdGF,ebsdGF.orientations)

