%% The Index of EBSD data
%
%%
% In previous chapters we have discussed how to select EBSD data by
% properties. In this chapter we are intested in the order the EBSD are
% stored within MTEX. Lets start by importing some sample data

mtexdata twins

%%
% and restricting it to very small rectangular subset

poly = [44 0 4 2];
ebsd = ebsd(inpolygon(ebsd,poly));

plot(ebsd,ebsd.orientations,'micronbar','off','edgecolor','k')

%%
% In the above plot each square corresponds to one entry in the variable
% |ebsd|. Lets visualize the order

text(ebsd,1:length(ebsd))

%%
% We may easily select specific measurement pixels by specifying their
% indeces

hold on
plot(ebsd(16:18),'edgeColor','red','facecolor','none','linewidth',4)
legend off
hold off

%%
% Whether lines or columns run first is not related to MTEX but inherits
% from the ordering of the imported EBSD data. Since, we have restricted
% our large EBSD map to the small subset the indece of restricted data does
% not coincide with the indece of the imported data anymore. However, the
% original indeces are still stored in |ebsd.id|. Lets visualize them

plot(ebsd,ebsd.orientations,'micronbar','off','edgecolor','k')
text(ebsd,ebsd.id)

%%
% In order to select EBSD data according to their original id use the
% option |'id'|, i.e.,

hold on
plot(ebsd('id',316:318),'edgeColor','red','facecolor','none','linewidth',4)
legend off
hold off


%% Square Grids
% 
% In the cases of gridded data it is often useful to convert them into a
% matrix form.

ebsd = ebsd.gridify;

plot(ebsd,ebsd.orientations,'micronbar','off')

[i,j] = ndgrid(1:size(ebsd,1),1:size(ebsd,2));
str = arrayfun(@(a,b) ['(' int2str(a) ',' int2str(b) ')'],i,j,'UniformOutput',false);
text(ebsd,str)

%%
% This allows to select EBSD data simply by their coordinates within the
% grid, e.g., by

hold on
plot(ebsd(2,2:4),'edgeColor','red','facecolor','none','linewidth',4)
legend off
hold off

%%
% Note that the <EBSD.gridify.html |gridify|> command changes the order of
% measurements. They are now sort such that rows runs first and columns
% second, as this is the default convention how Matlab indexes matrices.

plot(ebsd,ebsd.orientations,'micronbar','off')
text(ebsd,1:length(ebsd))


%% Hexagonal Grid
% 
% The command <EBSD.gridify.html |gridify|> may also be applied to EBSD
% data measured on a hexagonal grid.

mtexdata titanium silent

ebsd = ebsd.gridify


%%
% This rearranges the measurements in a matrix form which can be indexed
% similarly as in the square case. 

ebsd = ebsd(10:16,68:79);

%%
% Lets visualize the matrix coordinates for the hexagonal grid

plot(ebsd,ebsd.orientations,'edgeColor','k','micronbar','off')
axis off

[i,j] = ndgrid(1:size(ebsd,1),1:size(ebsd,2));
str = arrayfun(@(a,b) ['(' int2str(a) ',' int2str(b) ')'],i,j,'UniformOutput',false);
text(ebsd,str)

%% Cube Coordinates
% In hexognal grids it is sometimes advantageous to use three digit cube
% coordinates to index the cell. This can be done using the commands
% <EBSDhex.hex2cube.html |hex2cube|> and <EBSDhex.cube2hex.html
% |cube2hex|>. Much more details on indexing hex grids can be found at
% <https://www.redblobgames.com/grids/hexagons/ here>.

plot(ebsd,ebsd.orientations,'edgeColor','k','micronbar','off')
axis off

[i,j] = ndgrid(1:size(ebsd,1),1:size(ebsd,2));
[x,y,z] = ebsd.hex2cube(i,j);
str = arrayfun(@(a,b,c) ['(' int2str(a) ',' int2str(b) ',' int2str(c) ')'],x,y,z,'UniformOutput',false);
text(ebsd,str)



