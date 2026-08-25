%% Vector Operations
%
%%
% Three-dimensional vectors can be added, scaled, compared, and combined.
% Every operation works on a whole list at once, so a loop over vectors is
% usually unnecessary in MTEX.
%
% This page assumes the construction methods from
% <VectorDefinition.html Defining Three Dimensional Vectors>. A reference
% frame is the coordinate system in which the vectors are expressed. The
% plotting convention below only lays that frame out on screen; it does not
% change the vectors.

plottingConvention.default('y↑→x');

%% Building New Vectors
%
% Sums and multiples of the specimen axes |vector3d.X|, |vector3d.Y|, and
% |vector3d.Z| are |vector3d| objects again.

v = vector3d.X + 2*vector3d.Y

%%
% <vector3d.plus.html |+|> and <vector3d.minus.html |-|> add or subtract
% Cartesian components. <vector3d.mtimes.html |*|> scales a vector by a
% scalar. The inner product <vector3d.dot.html |dot|> and cross product
% <vector3d.cross.html |cross|> have their usual linear-algebra meanings.
% The order of the cross product matters.

u = dot(v,vector3d.Y) * vector3d.Y + 2 * cross(v,vector3d.Z)

%%
% The first term is $2\vec Y$, while the second is
% $4\vec X-2\vec Y$. Their Y components cancel, leaving
% $\vec u=4\vec X$. The arrows show the original vector in the XY plane and
% the result along positive X.

newMtexFigure('newFigure');
arrow3d(v,'label','v');
hold on
arrow3d(u,'label','u');
hold off
axis off;

%% Angles
%
% The <vector3d.angle.html |angle|> between two directions is a central
% measurement in texture analysis. One example is the tilt of a
% lattice-plane normal away from the sheet normal. The angle between
% complete crystal orientations is a different operation, introduced in
% <MisorientationTheory.html Misorientations>.

angle(vector3d.X,vector3d.Y) ./ degree

%%
% MTEX returns angles in radians, hence the division by |degree|. The angle
% between directed vectors lies between $0$ and $180^\circ$. If the data
% represent axes instead, the answer is never obtuse; see
% <VectorsAxes.html Axes and Antipodal Symmetry>.

%% Length and Normalization
%
% <vector3d.norm.html |norm|> returns the length of each vector.
% <vector3d.normalize.html |normalize|> divides each vector by its length.

norm(u)

%%

u = normalize(u)

%%
% Normalization does not change where a vector points, so it does not move
% its position in a spherical plot. It matters in calculations: the |dot|
% of two unit vectors is the cosine of their angle.

dot(normalize(v),vector3d.Y)

%%
% A zero vector has no direction. Consequently, |normalize(vector3d(0,0,0))|
% has undefined, NaN components.

%% Lists of Vectors
%
% Square brackets join vectors into one list, and an index selects an entry.
% The general rules are covered in
% <ListsAndIndexing.html Lists and Indexing>.

w = [v,u];
w(1)

%%
% Arithmetic on a list is entry by entry. Adding the single vector |v| to
% the two-entry list |w| adds it to both entries.

w = w + v

%%
% When both inputs are lists of the same size, binary operations pair their
% entries by position. Use <vector3d.angle_outer.html |angle_outer|> or
% <vector3d.dot_outer.html |dot_outer|> to compare every entry of one list
% with every entry of another.

%% Selecting from a List
%
% The following file contains directions stored as polar and azimuth
% angles. Its displayed summary confirms that the resulting |vector3d|
% list has 1,000 entries.

fname = fullfile(mtexDataPath,'vector3d','vectors.txt');
v = vector3d.load(fname,'ColumnNames',{'polar angle','azimuth angle'})

%%
% A logical condition retains only directions with a polar angle below
% $60^\circ$.

selected = v.theta < 60*degree;
scatter(v(selected),'grid');

%%
% The empty outer ring shows that every plotted direction lies within
% $60^\circ$ of the Z axis. Count the omitted entries directly.

numOmitted = sum(~selected)

%%
% Thus, 236 of the 1,000 directions lie at least $60^\circ$ away from the Z
% axis.

%% Averaging a List
%
% <vector3d.mean.html |mean|> averages the Cartesian components. The result
% is a mean vector, which generally is not a unit vector.

m = mean(v)

%%
% Normalizing it gives the mean direction.

meanDirection = normalize(m)

%%
% Because every input vector has unit length, the length of |m| is the mean
% resultant length.

meanResultantLength = norm(m)

%%
% Here it is about 0.719. Identical unit directions give one; dispersed or
% mutually cancelling directions give a shorter result. Normalize unequal
% input vectors first when this directional statistic is intended.
%
% Opposite directed observations cancel. For axes, where |v| and |-v| mean
% the same thing, use |mean(v,'antipodal')| instead; see
% <VectorsAxes.html Axes and Antipodal Symmetry>.

%% Operations at a Glance
%
% These methods operate elementwise unless their description says otherwise.
%
% || <vector3d.angle.html |angle(v1,v2)|> || pointwise angle between vectors ||
% || <vector3d.angle_outer.html |angle_outer(v1,v2)|> || all pairwise angles ||
% || <vector3d.dot.html |dot(v1,v2)|> || pointwise inner product ||
% || <vector3d.dot_outer.html |dot_outer(v1,v2)|> || all pairwise inner products ||
% || <vector3d.cross.html |cross(v1,v2)|> || pointwise cross product ||
% || <vector3d.mtimes.html |a*v|> || multiplication by a scalar ||
% || <vector3d.times.html |a.*v|> || componentwise scaling or coordinate product ||
% || <vector3d.norm.html |norm(v)|> || length of every vector ||
% || <vector3d.normalize.html |normalize(v)|> || length scaled to one ||
% || <vector3d.orth.html |orth(v)|> || an arbitrary orthogonal unit vector ||
% || <vector3d.orthProj.html |orthProj(v,N)|> || component orthogonal to |N| ||
% || <vector3d.perp.html |perp(v)|> || best-fit direction orthogonal to a list ||
% || <vector3d.sum.html |sum(v)|> || componentwise sum over a list ||
% || <vector3d.mean.html |mean(v)|> || mean vector, or mean axis for antipodal data ||
% || <vector3d.polar.html |polar(v)|> || polar angle, azimuth, and length ||
% || <vector3d.rotate.html |rotate(v,rot)|> || turn by a rotation ||

%% Further Reading
%
% * N. I. Fisher, T. Lewis, and B. J. J. Embleton,
% <https://doi.org/10.1017/CBO9780511623059.004 Descriptive and ancillary
% methods, and sampling problems>, in _Statistical Analysis of Spherical
% Data_, Cambridge University Press, 1987, treats mean directions, resultant
% lengths, and the difference between vectorial and axial data.

%% Next
%
% <VectorsDensityEstimation.html Density Estimation> replaces a long list of
% directions by a smooth function on the sphere. Read
% <VectorsAxes.html Axes and Antipodal Symmetry> before analysing data whose
% two signs are physically equivalent. Turning a direction into another one
% is the job of a <Rotations.html rotation>.
