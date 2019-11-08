change the file

toolbox/matlab/specgraph/+matlab/+graphics/+chart/+interaction/+dataannotatable/PatchHelper

got get the tooltip working properly replace 

%if size(tri.Points, 1)==numVerts
---->
try

and

%ws = warning('off', 'MATLAB:delaunayTriangulation:ConsConsSplitWarnId');
---->
ws = warning('off');
