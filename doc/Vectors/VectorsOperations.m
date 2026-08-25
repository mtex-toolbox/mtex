%% Vector Operations
%
%%
% Directions are added, scaled and multiplied like ordinary numbers, and
% every operation works on a whole list of directions at once. That is the
% reason a loop over vectors is almost never needed in MTEX.

plottingConvention.default('y↑→x');

%% Building New Directions
%
% Sums and multiples of the specimen axes |vector3d.X|, |vector3d.Y| and
% |vector3d.Z| are directions again.

v = vector3d.X + 2*vector3d.Y

%%
% <vector3d.plus.html |+|>, <vector3d.minus.html |-|>,
% <vector3d.times.html |*|>, the inner product <vector3d.dot.html |dot|> and
% the cross product <vector3d.cross.html |cross|> all behave as in linear
% algebra.

u = dot(v,vector3d.Y) * vector3d.Y + 2 * cross(v,vector3d.Z)

%% Angles
%
% The <vector3d.angle.html |angle|> between two directions is the central
% measurement in texture analysis - how far a lattice plane is tilted out of
% the sheet plane, how far two grains are misoriented.

angle(vector3d.X,vector3d.Y) ./ degree

%%
% The result is in radians, hence the division by |degree|, and it lies
% between $0$ and $180^\circ$. If the two directions are axes rather than
% directions the answer is never obtuse, which is the subject of
% <VectorsAxes.html Axes and Antipodal Symmetry>.
%
%% Length
%
% <vector3d.norm.html |norm|> is the length of a direction and
% <vector3d.normalize.html |normalize|> divides it out.

norm(u)

%%

u = normalize(u)

%%
% Normalising changes nothing about where the direction points, so it
% changes nothing about a spherical plot either. It matters when the numbers
% themselves are used, for instance because |dot| of two unit vectors is the
% cosine of the angle between them.

dot(normalize(v),vector3d.Y)

%% The Available Operations
%
% || <vector3d.angle.html angle(v1,v2)> || angle between two directions ||
% || <vector3d.dot.html dot(v1,v2)> || inner product ||
% || <vector3d.cross.html cross(v1,v2)> || cross product ||
% || <vector3d.norm.html norm(v)> || length ||
% || <vector3d.normalize.html normalize(v)> || length scaled to one ||
% || <vector3d.orthProj.html orthProj(v,N)> || component orthogonal to |N| ||
% || <vector3d.perp.html perp(v)> || a direction orthogonal to all of |v| ||
% || <vector3d.sum.html sum(v)> || sum over the list ||
% || <vector3d.mean.html mean(v)> || mean direction of the list ||
% || <vector3d.polar.html polar(v)> || the two spherical angles ||
% || <vector3d.rotate.html rotate(v,rot)> || turn by a rotation ||
%
%% Lists of Directions
%
% Square brackets join directions into one list, and the entries are read
% back by their index.

w = [v,u];
w(1)

%%
% Arithmetic on a list is done entry by entry. Adding a single direction to
% a list of five adds it to each of them, so an operation that looks like it
% needs a loop usually does not.

w = w + v

%%
% Lists are indexed as numeric arrays are, by position or by a logical
% condition. Here a file of a thousand directions is loaded and only those
% with a polar angle below $60^\circ$ are kept, see
% <ListsAndIndexing.html Lists and Indexing>.

fname = fullfile(mtexDataPath,'vector3d','vectors.txt');
v = vector3d.load(fname,'ColumnNames',{'polar angle','azimuth angle'})

%%

scatter(v(v.theta < 60*degree),'grid','on')

%%
% The outer ring of the projection is empty now. It held the 236 directions
% that lie more than $60^\circ$ away from the Z axis.
%
%% Averaging a List
%
% <vector3d.mean.html |mean|> averages the coordinates entry by entry, so it
% points into the middle of the list.

mean(v)

%%
% Its length says how tightly the list is clustered: unit directions all
% pointing the same way average to length one, a list spread over the sphere
% to something much shorter - here 0.72. Directions pointing opposite ways
% cancel outright. For axes, where |v| and |-v| mean the same thing, that
% cancellation is wrong and the mean has to be taken with the |'antipodal'|
% flag, see <VectorsAxes.html Axes and Antipodal Symmetry>.
%
%% Next
%
% Turning a direction into another one is the job of a
% <Rotations.html rotation>, and
% <VectorsDensityEstimation.html Density Estimation> replaces a long list of
% directions by a smooth function on the sphere.
