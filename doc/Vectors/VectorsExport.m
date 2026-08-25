%% Exporting Vectors
%
%%
% <vector3d.export.html |export|> writes a list of directions to a text
% file, one direction per line, with a line of column headings on top. The
% file it produces is one that <vector3d.load.html |vector3d.load|> reads
% back, so this is the way to hand directions to another program or to a
% later session.

plottingConvention.default('y↑→x');

v = vector3d.byPolar((10:20:90)*degree,(-80:40:80)*degree);
v = v(:);

fname = [tempname,'.txt'];

%% Cartesian Coordinates
%
% By default the three coordinates are written.

export(v,fname)

type(fname)

%% Spherical Angles
%
% The option |'polar'| writes the polar and the azimuth angle instead, in
% degree, or in radians with the additional option |'radians'|.

export(v,fname,'polar')

type(fname)

%% Additional Columns
%
% Values that belong to the directions - a measured intensity, a weight, a
% density - are written alongside them by passing a struct. Each field
% becomes one further column, named after the field.

S.weight = (1:5).'/15;

export(v,fname,S)

type(fname)

%% Reading the File Back
%
% <vector3d.load.html |vector3d.load|> takes the coordinate columns by name
% and ignores the rest.

vNew = vector3d.load(fname,'ColumnNames',{'x','y','z'});

max(angle(v(:),vNew(:))) ./ degree

%%
% The directions come back to within a few $10^{-5}$ degree. What limits the
% roundtrip is the six significant digits written by the default numeric
% format, not the in-memory vectors.

delete(fname)

%% Next
%
% Reading directions from a file is <VectorsImport.html Import>. A whole
% figure, rather than the data behind it, is saved as described in
% <PlottingExport.html Exporting Figures>.
