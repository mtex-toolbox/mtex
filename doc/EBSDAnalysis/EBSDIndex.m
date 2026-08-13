%% The Index of EBSD data
%
%%
% In previous chapters we have discussed how to select EBSD data by
% properties. In this chapter we discus the ordering of EBSD pixels  within
% MTEX. Lets start by importing some sample data

mtexdata twins

%%
% The imported map is an @EBSDsquare, i.e. it is already stored as a matrix
% - see <EBSDGrid.html Square and Hex Grids>. Restricting it to a very small
% rectangular subset gives back a plain list of pixels, since the selection
% is in general not a rectangle

poly = [44 0 4 2];
ebsd = ebsd(inpolygon(ebsd,poly))

plot(ebsd,ebsd.orientations,'micronbar','off','edgecolor','k','backend','patch')

%%
% In the above plot each square corresponds to one entry in the variable
% |ebsd| which as an index from 1 to 98. Let us visualize this index

text(ebsd,1:length(ebsd))

%%
% We may easily select specific pixels by specifying their indices

hold on
plot(ebsd(16:18),'edgeColor','red','facecolor','none','linewidth',4,'backend','patch')
legend off
hold off

%%
% Whether lines or columns run first is inherited from the order of the
% data the subset was taken from. Here that is the gridded map, whose linear
% index runs down a matrix column, i.e. along y - which is why the numbers
% above count downwards rather than across. Had the map been imported as a
% plain list, they would follow the order of the lines in the file instead.
%
% Since we have restricted our large EBSD map to the small subset, the
% indices of the restricted data do not coincide with the indices of the
% imported data anymore. However, the original indices are still stored in
% |ebsd.id|. Lets visualize those

plot(ebsd,ebsd.orientations,'micronbar','off','edgecolor','k','backend','patch')
text(ebsd,ebsd.id)

%%
% In order to select EBSD data according to their original |id| use the
% option |'id'|, i.e., the three pixels highlighted above are

hold on
plot(ebsd('id',ebsd.id(16:18)),'edgeColor','red','facecolor','none','linewidth',4,'backend','patch')
legend off
hold off

%%
% A pixel may also be addressed by where it sits in the map, using the
% option |'xy'|

ebsd('xy',44.5,1)

%%
% Note that |ebsd(x,y)| does NOT do this - it is an error. On a gridded map
% the very same expression is the pixel in row x and column y, see below, so
% one and the same line would mean two different pixels depending on whether
% the map happens to be stored as a matrix or as a list. |'xy'| means the
% same in both cases.

%% Square Grids
%
% Our subset is a list, but the pixels in it do sit on a grid, so we may put
% it back into matrix form with <EBSD.gridify.html |gridify|>.

ebsd = ebsd.gridify;

plot(ebsd,ebsd.orientations,'micronbar','off','edgeColor','black','backend','patch')

[i,j] = ndgrid(1:size(ebsd,1),1:size(ebsd,2));
str = arrayfun(@(a,b) ['(' int2str(a) ',' int2str(b) ')'],i,j,'UniformOutput',false);
text(ebsd,str)

%%
% This allows to select EBSD data simply by their coordinates within the
% grid, e.g., by

hold on
plot(ebsd(2,2:4),'edgeColor','red','facecolor','none','linewidth',4,'backend','patch')
legend off
hold off

%%
% Note that the <EBSD.gridify.html |gridify|> command changes the order of
% measurements. They are now sorted such that rows run first and columns
% second, as this is the default convention how Matlab indexes matrices.
% This is unavoidable and the reason why an imported map is put on its grid
% right away - see <EBSDGrid.html Square and Hex Grids>.

plot(ebsd,ebsd.orientations,'micronbar','off','edgeColor','black','backend','patch')
text(ebsd,1:length(ebsd))


%% Hexagonal Grid
%
% Everything above applies to EBSD data measured on a hexagonal grid as
% well. Such data is imported as an @EBSDhex, i.e. it already is in matrix
% form

mtexdata titanium silent

ebsd

%%
% and can be indexed similarly as in the square case.

ebsd = ebsd(10:16,68:79);

%%
% Lets visualize the matrix coordinates for the hexagonal grid

plot(ebsd,ebsd.orientations,'edgeColor','k','micronbar','off','unitcell')
axis off

[i,j] = ndgrid(1:size(ebsd,1),1:size(ebsd,2));
str = arrayfun(@(a,b) ['(' int2str(a) ',' int2str(b) ')'],i,j,'UniformOutput',false);
text(ebsd,str)

%% Cube Coordinates
% In hexagonal grids it is sometimes advantageous to use three digit cube
% coordinates to index the cell. This can be done using the commands
% <EBSDhex.hex2cube.html |hex2cube|> and <EBSDhex.cube2hex.html
% |cube2hex|>. Much more details on indexing hex grids can be found at
% <https://www.redblobgames.com/grids/hexagons/ here>.

plot(ebsd,ebsd.orientations,'edgeColor','k','micronbar','off','unitcell')
axis off

[i,j] = ndgrid(1:size(ebsd,1),1:size(ebsd,2));
[x,y,z] = ebsd.hex2cube(i,j);
str = arrayfun(@(a,b,c) ['(' int2str(a) ',' int2str(b) ',' int2str(c) ')'],x,y,z,'UniformOutput',false);
text(ebsd,str)
