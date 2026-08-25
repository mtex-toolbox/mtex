%% Defining Three Dimensional Vectors
%
%%
% A three-dimensional vector is represented by a variable of type
% <vector3d.vector3d.html |@vector3d|>. It stores the Cartesian components
% $x$, $y$, $z$, including their length. When the object represents only a
% direction, positive multiples are equivalent and a spherical plot uses
% the normalized components.

plottingConvention.default('y↑→x');

%% Cartesian Coordinates
%
% The direct way to define a direction is by its coordinates with respect
% to the specimen axes X, Y and Z.

v = vector3d(1,2,3)

%%
% The output is a table with one row per vector, here a single one. Drawing
% it puts a point on the sphere, seen from above.

plot(v,'grid','upper')

%%
% The point sits in the upper right quadrant, because $x$ and $y$ are both
% positive, and away from the rim, because $z$ is positive as well. Where it
% lands does not depend on how long the vector is - only on which way it
% points. The length is available as the <vector3d.norm.html |norm|>,

norm(v)

%%
% and <vector3d.normalize.html |normalize|> scales it to one without moving
% the point.

norm(normalize(v))

%%
% Single coordinates are read and written as properties.

v.x

%%

v.x = 0

%%
% The assignment changed |v| to $(0,2,3)$. Direct property assignment does
% not preserve either its length or its direction.

%% Polar Coordinates
%
% A direction is equally well described by two angles: the *polar angle*
% $\theta$, measured away from the Z axis, and the *azimuth angle* $\rho$,
% measured in the XY plane away from the X axis. This is what
% <vector3d.byPolar.html |vector3d.byPolar|> takes; it returns a unit vector.

v = vector3d.byPolar(60*degree,45*degree)

%%
% Angles are radians throughout MTEX, so an angle in degree is written as a
% multiple of |degree|. Both angles are also properties, and they read back
% in radians.

plot(v,'grid','upper')

%%

v.rho ./ degree   % the azimuth angle in degree

%%

v.theta ./ degree % the polar angle in degree

%% The Specimen Axes
%
% The three specimen axes themselves are |vector3d.X|, |vector3d.Y| and
% |vector3d.Z|. They are the readable way to write down a direction that is
% tied to the specimen rather than to a measurement.

v = vector3d.X + 2 * vector3d.Y

%%
% Their names are a convention of the experiment: for rolled material X is
% usually the rolling direction, Y the transverse direction and Z the normal
% direction of the sheet.

%% Many Directions at Once
%
% One |vector3d| variable holds an entire list of directions, and this is
% how directional data is handled in MTEX - not as a loop over single
% vectors. Passing arrays of coordinates gives one vector per entry.

v = vector3d((1:5),0,1)

%%
% The list has a shape, just as a numeric array does, and it is indexed the
% same way.

size(v)

%%

v(2)

%%
% Coordinates that already sit in a matrix are read row by row by
% |vector3d.byXYZ|, one vector per row.

xyz = [1 0 0; 0 1 0; 1 1 1];
v = vector3d.byXYZ(xyz)

%%
% Prefer |byXYZ| over passing the matrix to the constructor. The constructor
% accepts both readings - a $3 \times N$ matrix by columns and an $N \times
% 3$ matrix by rows - so for a $3 \times 3$ matrix it has to guess, and it
% warns and reads by columns. |byXYZ| never guesses.
%
% Random directions are useful to try something out, and come from
% <vector3d.rand.html |vector3d.rand|>.

v = vector3d.rand(100);

plot(v,'upper','grid','MarkerSize',4)

%% Plotting Conventions
%
% Which way X points on the page is a property of the drawing, not of the
% data. Passing a different <plottingConvention.html |plottingConvention|>
% redraws the same vector seen from somewhere else.

v = vector3d(1,2,3);

plot(v,'how2plot',plottingConvention('z←↑y'),'grid')

%%
% Nothing about |v| changed - only the camera did. To align every plot of a
% session the same way, set |plottingConvention.default|, as the first line
% of this page does. The alignment of the axes is treated in
% <AxesAlignment.html Axes Alignment>.
%
%% Next
%
% <VectorsOperations.html Operations> is the arithmetic: angles, dot and
% cross products, means over a list. <VectorsAxes.html Axes> explains when a
% direction is really an axis, i.e. when |v| and |-v| are the same thing,
% as for lattice-plane normals and conventional diffraction poles.
