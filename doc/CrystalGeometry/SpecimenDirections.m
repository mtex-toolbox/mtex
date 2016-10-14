%% Specimen Directions
% How to represent directions with respect to the sample or specimen
% reference system.
%
%% Open in Editor
%
%% Contents
%
%%
% Specimen directions are three dimensional vectors in the Euclidean space
% represented by coordinates with respect to an external specimen
% coordinate system X, Y, Z. In MTEX, specimen directions are represented
% by variables of the class <vector3d_index.html *vector3d*>.
%
%% Cartesian Coordinates
%
% The standard way to define specimen directions is by its coordinates. 

v = vector3d(1,2,3)

%%
% This gives a single vector with coordinates (1,1,0) with respect to the
% X, Y, Z coordinate system. Lets visualize this vector

plot(v)
annotate([vector3d.X,vector3d.Y,vector3d.Z],'label',{'X','Y','Z'},'backgroundcolor','w')

%%
% Note that the alignment of the X, Y, Z axes is only a plotting
% convention, which can be easily changed without changing the coordinates,
% e.g., by setting

plotx2north
plot(v,'grid')
annotate([vector3d.X,vector3d.Y,vector3d.Z],'label',{'X','Y','Z'},'backgroundcolor','w')

%%
% One can easily access the coordinates of any vector by

v.x

%%
% or change it by

v.x = 0


%% Polar Coordinates
%
% A second way to define specimen directions is by polar coordinates, i.e.
% by its polar angle and its azimuth angle. This is done by the option
% *polar*.

polar_angle = 60*degree;
azimuth_angle = 45*degree;
v = vector3d('polar',polar_angle,azimuth_angle)

plotx2east
plot(v,'grid')
annotate([vector3d.X,vector3d.Y,vector3d.Z],'label',{'X','Y','Z'},'backgroundcolor','w')

%%
% Analogously as for the Cartesian coordinates we can access and change
% polar coordinates directly by

v.rho ./ degree   % the azimuth angle in degree
v.theta ./ degree % the polar angle in degree


%% Calculating with Specimen Directions
%
% In MTEX, one can calculate with specimen directions as with ordinary
% numbers, i.e. we can use the predefined vectors  <xvector.html xvector>,
% <yvector.html yvector>, and <zvector.html zvector> and set

v = xvector + 2*yvector

%%
% Moreover, all basic vector operations as <vector3d.plus.html "+">,
% <vector3d.minus.html "-">, <vector3d.times.html "*">, <vector3d.dot.html
% inner product>, <vector3d.cross.html,cross product> are implemented in
% MTEX.

u = dot(v,xvector) * yvector + 2 * cross(v,zvector)

%%
% Beside the standard linear algebra operations there are also the
% following functions available in MTEX.
%
%  [[vector3d.angle.html,angle(v1,v2)]] % angle between two specimen  directions
%  [[vector3d.dot.html,dot(v1,v2)]]   % inner product
%  [[vector3d.cross.html,cross(v1,v2)]] % cross product
%  [[vector3d.norm.html,norm(v)]]      % length of the specimen directions
%  [[vector3d.sum.html,sum(v)]]       % sum over all specimen directions in v
%  [[vector3d.mean.html,mean(v)]]      % mean over all specimen directions in v  
%  [[vector3d.polar.html,polar(v)]]     % conversion to spherical coordinates
%
% A simple example to apply the norm function is to normalize specimen
% directions

v ./ norm(v)


%% Lists of vectors
%
% As any other MTEX variable you can combine several vectors to a list of
% vectors and all bevor mentioned operators operations will work
% elementwise on a list of vectors. See < WorkinWithLists.html Working with
% lists> on how to manipulate lists in Matlab. 

%%
% Large lists of vectors can be imported from a text file by the command

fname = fullfile(mtexDataPath,'vector3d','vectors.txt');
v = loadVector3d(fname,'ColumnNames',{'polar angle','azimuth angle'})

%%
% and exported by the command 

export(v,fname,'polar')

%%
% In order to visualize large lists of specimen directions scatter plots

scatter(v,'upper')

%%
% or contour plots may be helpful

contourf(v,'upper')

%% Indexing lists of vectors
%
% A list of vectors can be indexed directly by specifying the ids of the
% vectors one is interested in, e.g.

v([1:5])

%%
% gives the first 5 vectors from the list, or by logical indexing. The
% following command plots all vectors with an polar angle smaller then 60
% degree

scatter(v(v.theta<60*degree),'grid','on')

