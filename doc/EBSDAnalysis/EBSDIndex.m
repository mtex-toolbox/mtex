%% Indexing EBSD Data
%
%%
% A single EBSD measurement has several addresses. It has a position in a
% list, an |id| inherited from its parent map, and a position on the
% specimen. On a gridded map it also has a row and column. A hexagonal grid
% offers cube coordinates as a fifth address. They simplify neighbour-based
% algorithms.
%
% These addresses answer different questions and stop agreeing as soon as
% measurements are selected or rearranged. This page keeps them apart.
% See <EBSDSelect.html Selecting EBSD Data> for phase, property, and region
% selections. <EBSDGrid.html Square and Hex Grids> gives the complete
% gridding model.

plottingConvention.default('y↑→x');
mtexdata twins

%% List position
%
% The summary above identifies the imported map as an @EBSDsquare. It is
% already stored as a matrix. Restricting it to a small rectangle returns a
% plain @EBSD list. An arbitrary selection is not generally rectangular.

poly = [44 0 4 2];
ebsd = ebsd(inpolygon(ebsd,poly))

%%
% The summary reports 98 measurements. Each coloured square below is one
% entry in that list. Writing the list position into every square reveals
% the order in which the entries are stored.

plot(ebsd,ebsd.orientations,'ipfDirection',zvector,'micronbar','off',...
  'edgecolor','k','backend','patch')
text(ebsd,1:length(ebsd))

%%
% A single numeric subscript selects by list position. The red outline marks
% entries 16 to 18.

hold on
plot(ebsd(16:18),'edgeColor','red','facecolor','none','linewidth',4,'backend','patch')
legend off
hold off

%%
% This crop came from a gridded map and inherited its linear order. MATLAB
% advances through every row of one matrix column before moving to the next
% column. Here that means visiting all y positions at one x position before
% moving to the next x position. A list imported without gridding instead
% follows the order in which its measurements were loaded.

%% Measurement id
%
% Cropping changed every measurement's position in the list. Entry 16 of
% the crop was not entry 16 of the full map. Its identifier in that parent
% map is stored in |ebsd.id|.

plot(ebsd,ebsd.orientations,'ipfDirection',zvector,'micronbar','off',...
  'edgecolor','k','backend','patch')
text(ebsd,ebsd.id)

%%
% The option |'id'| selects by those identifiers. It therefore highlights
% the same three measurements as the list-position selection above.

hold on
plot(ebsd('id',ebsd.id(16:18)),'edgeColor','red','facecolor','none',...
  'linewidth',4,'backend','patch')
legend off
hold off

%%
% Keep an |id| when a result from one selection must be matched to another
% selection from the same parent map. Selection preserves it. Gridding is a
% different operation. It may assign identifiers for the new raster and
% stores the input identifiers in |oldId|. An |id| is therefore not
% necessarily a line number in the imported file. See <EBSDGrid.html Square
% and Hex Grids>.

%% Position on the specimen
%
% The option |'xy'| returns the measurement closest to a specimen position.
% Its output shows both the selected |id| and the actual coordinates.

ebsd('xy',44.5,1)

%%
% The expression |ebsd(x,y)| does *not* perform that lookup on a plain list;
% it is an error. On a gridded map the same expression means the pixel in
% row |x| and column |y|. Requiring |'xy'| prevents one line from changing
% meaning when a map changes between list and matrix storage.

%% Square-grid subscripts
%
% Although the crop is a list, its measurements lie on a regular grid.
% <EBSD.gridify.html |gridify|> restores the matrix shape. The output of
% |size| confirms that this crop has 7 rows and 14 columns.

ebsd = ebsd.gridify;
size(ebsd)

%%
% The labels now show |(row,column)| rather than a single linear index.

plot(ebsd,ebsd.orientations,'ipfDirection',zvector,'micronbar','off',...
  'edgeColor','black','backend','patch')

[i,j] = ndgrid(1:size(ebsd,1),1:size(ebsd,2));
str = arrayfun(@(a,b) ['(' int2str(a) ',' int2str(b) ')'],i,j,...
  'UniformOutput',false);
text(ebsd,str)

%%
% Two subscripts select by row and column. Ranges select a whole row or a
% rectangular block; the red outline marks columns 2 to 4 of row 2.

hold on
plot(ebsd(2,2:4),'edgeColor','red','facecolor','none','linewidth',4,'backend','patch')
legend off
hold off

%%
% <EBSD.gridify.html |gridify|> is allowed to reorder a plain list so that
% dimension 1 follows increasing specimen y and dimension 2 increasing x.
% This crop is a special case: it already inherited that order from the
% full gridded map, so its sequence does not change. For a general list, use
% the second output of |gridify| or |oldId|. They relate input order to
% raster order. <EBSDGrid.html Square and Hex Grids> works through that
% translation.

%% Hexagonal grids
%
% The same distinction between linear index, |id|, specimen position, and
% matrix subscripts applies to a hexagonal measurement grid. The summary
% below identifies this map as an @EBSDhex. It is stored as a matrix from
% the start.

plottingConvention.default('y↓→x');
mtexdata titanium

%%
% Row and column indexing works as in the square case. We retain a small
% block so that its subscripts remain legible.

ebsd = ebsd(10:16,68:79);

plot(ebsd,ebsd.orientations,'ipfDirection',zvector,'edgeColor','k',...
  'micronbar','off','unitcell')
axis off

[i,j] = ndgrid(1:size(ebsd,1),1:size(ebsd,2));
str = arrayfun(@(a,b) ['(' int2str(a) ',' int2str(b) ')'],i,j,...
  'UniformOutput',false);
text(ebsd,str)

%%
% The labels show that rows are horizontal lines of cells. Because alternate
% rows are offset, a matrix column follows a zigzag rather than a straight
% line on the specimen.

%% Cube coordinates
%
% Offset rows make a neighbour step depend on whether the row is even or
% odd. Cube coordinates replace row and column by three redundant indices,
% making the six neighbour steps identical everywhere on the grid. They are
% cell addresses for algorithms, not specimen coordinates.
%
% <EBSDhex.hex2cube.html |hex2cube|> and
% <EBSDhex.cube2hex.html |cube2hex|> convert between the two systems.
% <https://www.redblobgames.com/grids/hexagons/ Hexagonal Grids> explains
% the geometric construction and further algorithms.

plot(ebsd,ebsd.orientations,'ipfDirection',zvector,'edgeColor','k',...
  'micronbar','off','unitcell')
axis off

[i,j] = ndgrid(1:size(ebsd,1),1:size(ebsd,2));
[x,y,z] = ebsd.hex2cube(i,j);
str = arrayfun(@(a,b,c) ['(' int2str(a) ',' int2str(b) ',' int2str(c) ')'],...
  x,y,z,'UniformOutput',false);
text(ebsd,str)

%%
% Every displayed triple satisfies |x + y + z = 0|. A step to any of the
% six neighbours adds one to one coordinate and subtracts one from another,
% leaving the third unchanged.

%% Further reading
%
% <https://www.mathworks.com/help/matlab/math/array-indexing.html Array
% Indexing> in the MATLAB documentation explains linear and row-column
% indexing, including the column-major order used above.
%
% I. Her, <https://doi.org/10.1109/83.413166 _Geometric transformations on the
% hexagonal grid_>, IEEE Transactions on Image Processing 4(9), 1213--1222
% (1995). The paper develops the symmetrical frame behind cube coordinates.
%
% After grain reconstruction, <SelectingGrains.html Selecting Grains>
% separates grain list positions, grain |id| values, and |ebsd.grainId|.
