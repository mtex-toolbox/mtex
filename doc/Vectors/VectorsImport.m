%% Importing Vectors
%
%%
% Directional data usually arrives as a text file with one direction per
% line - a table of coordinates, or of the two spherical angles.
% <vector3d.load.html |vector3d.load|> reads such a file once it is told
% what the columns hold.

plottingConvention.default('y↑→x');

%% Reading a File
%
% The example file below has two columns, the polar angle and the azimuth
% angle, both in degree, under a line of headings.

fname = fullfile(mtexDataPath,'vector3d','vectors.txt');

v = vector3d.load(fname,'ColumnNames',{'polar angle','azimuth angle'})

%%
% The column names are what makes the file readable, and they are what
% decides how the numbers are interpreted. The recognised names are
%
% || |x|, |y|, |z| || Cartesian coordinates ||
% || |polar angle|, |azimuth angle| || the two spherical angles ||
% || |latitude|, |longitude| || geographic coordinates ||
%
% Angles are read as degree unless the option |'radians'| says otherwise.
% Columns in a different order, or extra columns that are not wanted, are
% handled by naming their positions.

v = vector3d.load(fname,'ColumnNames',{'polar angle','azimuth angle'},...
  'columns',[1 2]);

%% Looking at the Result
%
% A thousand directions are too many to read off a table, so the first thing
% to do with them is a plot. A scatter plot shows the individual directions,

scatter(v,'upper')

%%
% and a contour plot shows where they accumulate.

contourf(v,'upper')

%%
% The two views answer different questions: the scatter plot says where a
% measurement exists, the contour plot says where the data is dense. Turning
% the list into a proper function on the sphere is the subject of
% <VectorsDensityEstimation.html Density Estimation>.
%
%% Next
%
% Writing directions back to a file is <VectorsExport.html Export>. Crystal
% directions read from a file carry a crystal symmetry as well and are
% imported as <CrystalDirections.html Miller indices>.
