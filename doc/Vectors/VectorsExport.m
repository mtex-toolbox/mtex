%% Exporting Vectors
%
%%
% <vector3d.export.html |export|> writes a |vector3d| array as a
% whitespace-separated text table. Each vector occupies one row, and the
% first row names the columns. <vector3d.load.html |vector3d.load|> can read
% the table back, so the format is useful for another program or a later
% MTEX session.
%
% This page assumes that Cartesian components, polar angle, and azimuth are
% familiar. See <VectorDefinition.html Defining Three-Dimensional Vectors>
% for their definitions.

plottingConvention.default('y↑→x');

% five unit directions with distinct polar angles and azimuths
v = vector3d.byPolar((10:20:90)*degree,(-80:40:80)*degree);
v = v(:);

% The examples deliberately reuse the same temporary filename. Each call to
% |export| replaces the file instead of appending rows.
fname = [tempname,'.txt'];

%% Cartesian Coordinates
%
% By default, |export| writes the stored $x$, $y$, and $z$ components.
% Cartesian export retains vector-length information.

export(v,fname);

type(fname)

%%
% The heading identifies the three coordinate columns. The next five rows
% are the five vectors in array order.

%% Spherical Angles
%
% The option |'polar'| writes polar angle and azimuth instead. Angles are in
% degrees by default; add |'radians'| to write radians.
%
% This representation contains directions only. It does not include vector
% length, so use Cartesian coordinates when magnitudes matter.

export(v,fname,'polar');

type(fname)

%%
% The two headings remain |polar angle| and |azimuth angle| for either
% angular unit. Record the unit with the file because the table does not.

%% Additional Columns
%
% Values that belong to the vectors, such as an intensity, weight, or
% density, can travel in the same table. Pass them in a struct with one
% value per vector. Each field becomes a column with the field name as its
% heading.

S.weight = (1:5).'/15;

export(v,fname,S);

type(fname)

%%
% The |weight| column is fourth, and its row order remains aligned with the
% Cartesian coordinates.

%% Reading the File Back
%
% Supply every column name to recover both the vectors and their associated
% values. |vector3d.load| returns columns that are not coordinates in its
% second output.

[vNew,SNew] = vector3d.load(fname,...
  'ColumnNames',{'x','y','z','weight'});

maxAngleError = max(angle(v,vNew)) ./ degree

maxWeightError = max(abs(S.weight-SNew.weight))

%%
% The maximum angular error is $3.3461 \times 10^{-5}$ degrees, and the
% maximum weight error is $3.3333 \times 10^{-7}$. Both come
% from the six significant digits written by the default |%g| numeric
% format rather than from the in-memory values.

% remove the temporary file
delete(fname);

%% What the Table Does Not Record
%
% A reference frame is the coordinate system in which data are expressed.
% It has an identity, a basis, and a default convention for drawing it. The
% text table records none of these, and it does not say whether opposite
% directions represent the same physical axis. Keep that information with
% the exported file before exchanging or archiving it.
%
% For a higher-precision text representation, extract the coordinate arrays
% and use a writer with an explicit numeric format.

%% Further Reading
%
% * N. I. Fisher, T. Lewis, and B. J. J. Embleton,
% <https://doi.org/10.1017/CBO9780511623059 Statistical Analysis of
% Spherical Data>, Cambridge University Press, 1987. Chapter 2 defines
% spherical coordinate systems and distinguishes directed from undirected
% data.
% * D. Goldberg, <https://doi.org/10.1145/103162.103163 What Every Computer
% Scientist Should Know About Floating-Point Arithmetic>, _ACM Computing
% Surveys_ 23(1), 1991, explains rounding and conversion between binary
% floating-point values and decimal text.
% * <https://standards.ieee.org/ieee/754/6210/ IEEE 754-2019, Standard for
% Floating-Point Arithmetic> specifies binary and decimal floating-point
% formats and their interchange.
% * M. D. Wilkinson et al., <https://doi.org/10.1038/sdata.2016.18 The FAIR
% Guiding Principles for scientific data management and stewardship>,
% _Scientific Data_ 3, 160018, 2016, explains why reusable data need
% machine-readable context as well as numeric values.

%% Next
%
% <VectorsImport.html Import> develops column mappings and associated data
% in more detail. Continue through this chapter with
% <VectorsOperations.html Vector Operations>. To save a whole figure rather
% than its underlying data, read <PlottingExport.html Exporting Figures>.
