%% Vector Operations
%
%%
% In MTEX, one can calculate with three dimensional directions as with
% ordinary numbers, i.e. we can use the predefined vectors  <xvector.html
% vector3d.X>, <yvector.html vector3d.Y>, and <zvector.html vector3d.Z> and
% set

v = vector3d.X + 2*vector3d.Y

%%
% Moreover, all basic vector operations as <vector3d.plus.html "+">,
% <vector3d.minus.html "-">, <vector3d.times.html "*">, <vector3d.dot.html
% inner product>, <vector3d.cross.html cross product> are implemented in
% MTEX.

u = dot(v,vector3d.Y) * vector3d.Y + 2 * cross(v,vector3d.Z)

%%
% Besides the standard linear algebra operations, there are also the
% following functions available in MTEX.
%
% || <vector3d.angle.html angle(v1,v2)>  || angle between two specimen directions ||
% || <vector3d.dot.html dot(v1,v2)>      || inner product ||
% || <vector3d.cross.html cross(v1,v2)>  || cross product ||
% || <vector3d.norm.html norm(v)>        || length of the specimen directions ||
% || <vector3d.normalize.html normalize(v)> || normalize length to 1 ||
% || <vector3d.sum.html sum(v)>          || sum over all specimen directions in v ||
% || <vector3d.mean.html mean(v)>        || mean over all specimen directions in v  ||
% || <vector3d.polar.html polar(v)>      || conversion to spherical coordinates || 
%
% A simple example for applying the norm function is to normalize a set of
% specimen directions

u = u ./ norm(u)

%% Lists of vectors
%
% As any other MTEX variable you can combine several vectors to a list of
% vectors and all bevor mentioned operators operations will work
% elementwise on a list of vectors. See <ListsAndIndexing.html Working with
% lists> on how to manipulate lists in Matlab.
%
% Using the brackets |v = [v1,v2]| two lists of vectors can be joined to a
% single list. Now each single vector is accesable via |v(1)| and |v(2)|.

w = [v,u];
w(1)
w(2)

%%
% When calculating with concatenated specimen directions all operations are
% performed componentwise for each specimen direction.

w = w + v;

%%
% A list of vectors can be indexed directly by specifying the ids of the
% vectors one is interested in, e.g.

% import many vectors from a file
fname = fullfile(mtexDataPath,'vector3d','vectors.txt');
v = vector3d.load(fname,'ColumnNames',{'polar angle','azimuth angle'})

% extract vectors 1 to 5
v(1:5)

%%
% gives the first 5 vectors from the list, or by logical indexing. The
% following command plots all vectors with an polar angle smaller then 60
% degree

scatter(v(v.theta<60*degree),'grid','on')
