%% The Index of EBSD data
%
%%
% There are three different ways to point at a single measurement: where it
% sits in the list, the |id| it was given when the file was read, and where
% it sits on the grid. They are not the same number, and they stop agreeing
% as soon as anything is selected away. This page keeps them apart.

plottingConvention.default('y↑→x');
mtexdata twins

%%
% The imported map is an @EBSDsquare, that is it is already stored as a
% matrix - see <EBSDGrid.html Square and Hex Grids>. Restricting it to a
% very small rectangle gives back a plain list of pixels, since a selection
% is in general not a rectangle.

poly = [44 0 4 2];
ebsd = ebsd(inpolygon(ebsd,poly))

plot(ebsd,ebsd.orientations,'micronbar','off','edgecolor','k','backend','patch')

%%
% Each square in that picture is one entry of the list, and the list has 98
% of them. Writing the position in the list into each square shows the
% order they are kept in.

text(ebsd,1:length(ebsd))

%%
% Those positions are what a plain index selects.

hold on
plot(ebsd(16:18),'edgeColor','red','facecolor','none','linewidth',4,'backend','patch')
legend off
hold off

%%
% Whether lines or columns run first is inherited from the order of the
% data the subset was taken from. Here that is the gridded map, whose
% linear index runs down a matrix column, that is along y - which is why
% the numbers above count downwards rather than across. Had the map been
% imported as a plain list, they would follow the order of the lines in the
% file instead.
%
%% The original id
%
% Cutting the map down renumbered everything: pixel 16 of this list was not
% pixel 16 of the map it came from. What each pixel was called in the full
% data set is kept in |ebsd.id|.

plot(ebsd,ebsd.orientations,'micronbar','off','edgecolor','k','backend','patch')
text(ebsd,ebsd.id)

%%
% Selecting by that number rather than by list position is done with the
% option |'id'|, and picks the same three pixels as above.

hold on
plot(ebsd('id',ebsd.id(16:18)),'edgeColor','red','facecolor','none','linewidth',4,'backend','patch')
legend off
hold off

%%
% This is the number to hold on to when a result computed on one selection
% has to be matched against another, since it survives every restriction.
%
%% The position on the specimen
%
% A pixel can also be addressed by where it sits in the map, with the
% option |'xy'|.

ebsd('xy',44.5,1)

%%
% Note that |ebsd(x,y)| does *not* do this - it is an error. On a gridded
% map the very same expression is the pixel in row x and column y, see
% below, so one and the same line would mean two different pixels depending
% on whether the map happens to be stored as a matrix or as a list. |'xy'|
% means the same in both cases.
%
%% Square grids
%
% The subset is a list, but its pixels do sit on a grid, so
% <EBSD.gridify.html |gridify|> can put it back into matrix form - here a
% matrix of 7 rows and 14 columns.

ebsd = ebsd.gridify;

plot(ebsd,ebsd.orientations,'micronbar','off','edgeColor','black','backend','patch')

[i,j] = ndgrid(1:size(ebsd,1),1:size(ebsd,2));
str = arrayfun(@(a,b) ['(' int2str(a) ',' int2str(b) ')'],i,j,'UniformOutput',false);
text(ebsd,str)

%%
% Now a pixel can be picked by its row and column, and a whole row or block
% by a range.

hold on
plot(ebsd(2,2:4),'edgeColor','red','facecolor','none','linewidth',4,'backend','patch')
legend off
hold off

%%
% <EBSD.gridify.html |gridify|> changes the order of the measurements: they
% come out sorted with rows running first and columns second, which is how
% MATLAB indexes a matrix. That is unavoidable, and it is the reason an
% imported map is put on its grid straight away - see
% <EBSDGrid.html Square and Hex Grids>. Compare the numbers below with the
% first picture on this page.

plot(ebsd,ebsd.orientations,'micronbar','off','edgeColor','black','backend','patch')
text(ebsd,1:length(ebsd))

%% Hexagonal grids
%
% All of this holds for a hexagonal measurement grid as well. Such a map is
% imported as an @EBSDhex and is in matrix form from the start.

plottingConvention.default('y↓→x');
mtexdata titanium

%%
% Row and column indexing works exactly as in the square case.

ebsd = ebsd(10:16,68:79);

%%
% The rows are the horizontal lines of cells, and the columns run down the
% zigzag, so a column is not a straight line on the specimen.

plot(ebsd,ebsd.orientations,'edgeColor','k','micronbar','off','unitcell')
axis off

[i,j] = ndgrid(1:size(ebsd,1),1:size(ebsd,2));
str = arrayfun(@(a,b) ['(' int2str(a) ',' int2str(b) ')'],i,j,'UniformOutput',false);
text(ebsd,str)

%% Cube coordinates
%
% That zigzag makes "one cell to the left" mean different things in even
% and in odd rows, which is awkward for anything that walks over
% neighbours. Cube coordinates avoid it by describing a hexagonal grid with
% three indices instead of two, at the price of a redundant one.
% <EBSDhex.hex2cube.html |hex2cube|> and <EBSDhex.cube2hex.html |cube2hex|>
% convert between the two, and the reasoning behind them is laid out
% <https://www.redblobgames.com/grids/hexagons/ here>.

plot(ebsd,ebsd.orientations,'edgeColor','k','micronbar','off','unitcell')
axis off

[i,j] = ndgrid(1:size(ebsd,1),1:size(ebsd,2));
[x,y,z] = ebsd.hex2cube(i,j);
str = arrayfun(@(a,b,c) ['(' int2str(a) ',' int2str(b) ',' int2str(c) ')'],x,y,z,'UniformOutput',false);
text(ebsd,str)

%%
% The three numbers of each cell add up to zero, which is what makes them
% redundant, and a step to any of the six neighbours changes exactly two of
% them by one.
%
