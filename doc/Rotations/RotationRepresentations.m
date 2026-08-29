%% Rotation Representations
%
%%
% The same rotation can be described by different coordinates. The best
% choice depends on whether the coordinates will be plotted, sampled, or
% used to build a grid.
%
% This page assumes the axis--angle and quaternion descriptions introduced
% in <RotationDefinition.html Defining Rotations>.
% MTEX stores the proper part of every <rotation.rotation.html |rotation|>
% as a unit <quaternion.quaternion.html quaternion>.
% The coordinates below are computed from that quaternion on demand.
%
% Rodrigues and homochoric coordinates are *scaled-axis* representations.
% Their direction is the rotation axis $\vec n$.
% Their length is a function $f(\omega)$ of the principal rotation angle
% $0 \leq \omega \leq \pi$:
%
% $$ \vec v = f(\omega)\,\vec n. $$
%
% Cubochoric coordinates take one further step and map the homochoric ball
% onto a cube. They therefore do not, in general, point along the rotation
% axis.

rot = rotation.rand(100000);

%% Rodrigues--Frank Coordinates
%
% The Rodrigues--Frank vector scales the axis by
% $f(\omega)=\tan(\omega/2)$. MTEX computes it with
% <quaternion.Rodrigues.html |Rodrigues|>.
%
% The following output puts the angle in degrees in the first column and
% the length of its Rodrigues vector in the second.

sampleAngle = [0 60 120 170 179] * degree;
sampleRot = rotation.byAxisAngle(vector3d.Z,sampleAngle);
vRodrigues = sampleRot.Rodrigues;
rodriguesLength = norm(vRodrigues);

[sampleAngle(:)./degree,rodriguesLength(:)]

%%
% The length grows rapidly near a half turn.
% At exactly $180^\circ$ it is infinite, so the full rotation space is
% unbounded in Rodrigues coordinates.
% Rotations about one fixed axis nevertheless form a straight line, and
% symmetry boundaries become planes.
% These properties make Rodrigues coordinates useful for visualizing
% <OrientationFundamentalRegion.html fundamental regions>.
%
% <rotation.byRodrigues.html |rotation.byRodrigues|> performs the inverse
% conversion. The displayed angular error confirms the round trip.

rotFromRodrigues = rotation.byRodrigues(vRodrigues);
max(angle(sampleRot,rotFromRodrigues))./degree

%% Homochoric Coordinates
%
% Rodrigues coordinates simplify geometry but distort volume. Homochoric
% coordinates instead scale the rotation axis by
%
% $$ f(\omega) = \left(\frac{3}{4}\left(\omega-\sin\omega\right)\right)^{1/3}. $$
%
% <quaternion.homochoric.html |homochoric|> maps all rotations into a ball.
% Its radius is $R=(3\pi/4)^{1/3}$, reached by the half turns.

vHomochoric = rot.homochoric;
R = (0.75*pi)^(1/3);

halfTurn = rotation.byAxisAngle(vector3d.Z,pi);
[norm(halfTurn.homochoric),R]

%% A volume check
%
% <rotation.rand.html |rotation.rand|> samples the uniform, or Haar,
% distribution on the rotation group. Equal-volume homochoric coordinates
% turn that sample into a uniform distribution in the ball.
%
% A uniform ball does not have a uniform distribution of radii. A shell at
% radius $r$ has more volume than a shell of the same thickness near the
% centre, so the radial density is $3r^2/R^3$.

figure;
histogram(norm(vHomochoric),50,'Normalization','pdf')
hold on
r = linspace(0,R,100);
plot(r,3*r.^2/R^3,'LineWidth',2)
hold off
legend('sampled radii','uniform-ball density','Location','northwest')
xlabel('homochoric radius')
ylabel('probability density')

%% Reading the volume check
%
% The sampled bars follow the increasing theoretical curve.
% This agreement is the visible consequence of preserving Haar volume.
% It does not mean that homochoric coordinates preserve angles, shapes, or
% distances between arbitrary rotations.

%% Cubochoric Coordinates
%
% Cubochoric coordinates compose the homochoric map with an equal-volume
% map from the ball to a cube.
% The cube has edge length $\pi^{2/3}$ and the same volume, $\pi^2$, as the
% homochoric ball.
%
% MTEX computes these coordinates with
% <quaternion.cubochoric.html |cubochoric|>.
% The next figure maps the same half turns first to the homochoric boundary
% and then to the cubochoric boundary.

halfTurnAxis = equispacedS2Grid('points',2000);
boundaryRot = rotation.byAxisAngle(halfTurnAxis,pi);
homochoricBoundary = boundaryRot.homochoric;
cubochoricBoundary = boundaryRot.cubochoric;

figure;
tiledlayout(1,2)

nexttile
scatter3(homochoricBoundary.x,homochoricBoundary.y,...
  homochoricBoundary.z,4,'filled')
axis equal
xlabel('h_1'); ylabel('h_2'); zlabel('h_3')
title('homochoric boundary')

nexttile
scatter3(cubochoricBoundary.x,cubochoricBoundary.y,...
  cubochoricBoundary.z,4,'filled')
axis equal
xlabel('c_1'); ylabel('c_2'); zlabel('c_3')
title('cubochoric boundary')

%% Reading the coordinate domains
%
% The spherical boundary on the left becomes the six faces of the cube on
% the right. Opposite axes describe the same $180^\circ$ rotation, so
% opposite boundary locations are identified.
% Neither domain is an ordinary solid with independent points everywhere on
% its boundary.
%
% The cube is convenient for Cartesian grids. This is why
% <homochoricSO3Grid.homochoricSO3Grid.html |homochoricSO3Grid|> constructs
% its internal grid in cubochoric coordinates despite the class name.

%% Inverting Cubochoric Coordinates
%
% There is no |rotation.byCubochoric| constructor. First map the cube back
% to the homochoric ball with <cubo2homo.html |cubo2homo|>, then use
% <rotation.byHomochoric.html |rotation.byHomochoric|>.

vCubochoric = rot.cubochoric;
xyz = cubo2homo(...
  [vCubochoric.x(:),vCubochoric.y(:),vCubochoric.z(:)]);
rotFromCubochoric = rotation.byHomochoric(xyz);

max(angle(rot,rotFromCubochoric))./degree

%%
% The displayed maximum is the angular round-trip error in degrees. Its
% small nonzero value comes from floating-point evaluation of the two
% nonlinear maps.

%% Choosing a Representation
%
% || *representation* || *coordinate domain* || *preserves volume* || *useful feature* ||
% || <quaternion.Rodrigues.html Rodrigues--Frank> || unbounded $\mathbb R^3$ || no || straight fixed-axis lines and planar symmetry boundaries ||
% || <quaternion.homochoric.html homochoric> || ball of radius $(3\pi/4)^{1/3}$ || yes || radial coordinates for density and integration ||
% || <quaternion.cubochoric.html cubochoric> || cube of edge $\pi^{2/3}$ || yes || uniform Cartesian grids ||
%
% Equal volume refers to the invariant volume measure on the rotation
% group. It is not a claim about Euclidean distance. Use
% <quaternion.angle.html |angle|>, rather than coordinate-vector distance,
% when the physical angular separation between two rotations is required.
%
% Do not average any of these vectors to obtain a mean rotation. The mean
% must respect rotation geometry; use <quaternion.mean.html |mean|> on the
% rotations themselves.

%% The Maths Behind Equal Volume
%
% For Haar-uniform rotations, the radial part of the volume element is
% proportional to $\sin^2(\omega/2)\,\mathrm d\omega$. The homochoric
% definition gives
%
% $$ r^3=\frac34(\omega-\sin\omega), $$
%
% and differentiation gives
%
% $$ 3r^2\,\mathrm dr=\frac32\sin^2(\omega/2)\,\mathrm d\omega. $$
%
% Thus equal intervals of Euclidean volume $r^2\,\mathrm dr$ correspond to
% equal intervals of rotation-group volume, up to one constant factor. At
% $\omega=\pi$ the ball volume is $4\pi R^3/3=\pi^2$, which also equals the
% volume of the cubochoric cube.

%% References
%
% * A. Morawiec,
% <https://doi.org/10.1007/978-3-662-09156-2 Orientations and Rotations:
% Computations in Crystallographic Textures>, Springer, 2004, develops the
% parametrisations and geometry of rotation space.
% * D. Rowenhorst et al.,
% <https://doi.org/10.1088/0965-0393/23/8/083501 Consistent
% representations of and conversions between 3D rotations>, Modelling and
% Simulation in Materials Science and Engineering 23 (2015) 083501,
% compares conventions and conversion formulas.
% * D. Rosca, A. Morawiec and M. De Graef,
% <https://doi.org/10.1088/0965-0393/22/7/075013 A new method of
% constructing a grid in the space of 3D rotations and its applications to
% texture analysis>, Modelling and Simulation in Materials Science and
% Engineering 22 (2014) 075013, introduces cubochoric coordinates.
% * P. G. Callahan et al.,
% <https://doi.org/10.1107/S1600576717001157 Three-dimensional texture
% visualization approaches: theoretical analysis and examples>, Journal of
% Applied Crystallography 50 (2017) 430--440, compares rotation-space
% domains for crystallographic point groups.
% * S. I. Wright and M. De Graef,
% <https://doi.org/10.1107/S1574870722004554 Electron backscatter
% diffraction>, International Tables for Crystallography C, ch. 1.6, 2022,
% reviews rotation representations and their use in EBSD.

%% Next
%
% <RotationImproper.html Improper Rotations> explains why reflections and
% inversions need an additional handedness flag. Then
% <RotationOperations.html Operations> covers composition, inversion, and
% rotation distance. <RotationPlotting.html Plotting Rotations> uses the
% coordinate domains introduced here, while
% <OrientationFundamentalRegion.html Orientation Fundamental Regions> adds
% crystal and specimen symmetry.

%#ok<*NOPTS>
