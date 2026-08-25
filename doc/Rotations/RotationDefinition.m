%% Defining Rotations
%
%%
% A rotation is built from whichever description is at hand - three Euler
% angles, an axis and an angle, a matrix, a pair of directions - and MTEX
% converts. Whatever the input, the result is a
% <rotation.rotation.html |@rotation|>, a list of rotations stored
% internally as <quaternion.quaternion.html quaternions>.
%
% || <rotation.byEuler.html |rotation.byEuler|> || <rotation.byAxisAngle.html |rotation.byAxisAngle|> || <rotation.byMatrix.html |rotation.byMatrix|> ||
% || <rotation.byRodrigues.html |rotation.byRodrigues|> || <rotation.byHomochoric.html |rotation.byHomochoric|> || <rotation.rotation.html |rotation(quat)|> ||
% || <rotation.id.html |rotation.id|> || <rotation.map.html |rotation.map|> || <rotation.fit.html |rotation.fit|> ||
% || <rotation.rand.html |rotation.rand|> || <SO3Fun.discreteSample.html |odf.discreteSample|> || <rotation.nan.html |rotation.nan|> ||
% || <rotation.load.html |rotation.load|> || <rotation.inversion.html |rotation.inversion|> || <reflection.html |reflection|> ||
%
% How the descriptions relate to one another, and which of them distorts
% distances in which way, is the subject of
% <RotationRepresentations.html Representations>.

%% Euler Angles
%
% Euler angles describe a rotation by three successive angular steps. The
% axes, their order, and whether the description is read actively or as a
% coordinate transformation are all part of the convention; the three
% numbers alone are insufficient.
%
% Several conventions used in texture analysis are
%
% * Bunge (phi1,Phi,phi2)       - ZXZ
% * Matthies (alpha,beta,gamma) - ZYZ
% * Roe (Psi,Theta,Phi)
% * Kocks (Psi,Theta,phi)
% * Canova (omega,Theta,phi)
%
% A new MTEX installation uses Bunge as its preference. Name the convention
% explicitly in reusable code so that a user's preference cannot change the
% meaning of the input.

rot = rotation.byEuler(30*degree,50*degree,10*degree,'Bunge')

%%
% Angles are radians throughout MTEX, which is why each is written as a
% multiple of |degree|. MTEX reads and reports Bunge Euler angles with the
% conventional $(\varphi_1,\Phi,\varphi_2)$ names. The separate question of
% which way an orientation maps coordinates is explained in
% <MTEXvsBungeConvention.html MTEX vs. Bunge Convention>.
%
% A different convention is named as an additional argument. The following
% rotation is a different one, although the three numbers are the same.

rot = rotation.byEuler(30*degree,50*degree,10*degree,'Roe')

%%
% The convention used to display an existing rotation can be requested
% directly. The same rotation reads

Euler(rot,'Roe')

%%

Euler(rot,'Bunge')

%%
% Same rotation, different numbers. For interactive work,
% <setMTEXpref.html |setMTEXpref|> can change the session's default Euler
% convention; that preference affects both unqualified construction and
% display, so library code and reproducible examples should pass the
% convention explicitly. Euler angles quoted without a convention are
% ambiguous.

%% Axis and Angle
%
% Every non-identity proper rotation in three dimensions turns the sphere
% about an axis. MTEX represents it with an angle between $0$ and
% $180^\circ$. The identity has no unique axis, and at $180^\circ$ the two
% signs of the axis describe the same rotation.

rot = rotation.byAxisAngle(vector3d.X,30*degree)

%%
% Both are read back off any rotation, however it was defined.

rot.axis

%%

rot.angle ./ degree

%%
% Drawn, that is all a rotation is: an axis, and everything else swung about
% it. The blue arrow is the axis, the grey arrow a direction before the
% rotation and the red arrow the same direction afterwards.

v = normalize(vector3d(0.2,0.3,1));

arrow3d(1.5*rot.axis,'faceColor','blue')
hold on
arrow3d(1.2*v,'faceColor',[.45 .45 .45])
arrow3d(1.2*(rot*v),'faceColor','red')
hold off
axis off

%% Rodrigues Frank Vector
%
% The Rodrigues--Frank vector packs axis and angle into a single vector: the
% rotation axis scaled by $\tan(\omega/2)$.

R = rot.Rodrigues

%%
% The angle is recovered from its length,

2 * atan(norm(R)) ./ degree

%%
% and the rotation from the vector.

rotation.byRodrigues(R)

%% Rotation Matrix
%
% A rotation is equally a $3 \times 3$ matrix.

M = rot.matrix

%%
% Its columns are where the specimen axes X, Y and Z end up after the
% rotation. Rotating X gives the first column of |M| back.

rot * vector3d.X

%%
% Conversely, an orthogonal $3 \times 3$ matrix defines a proper rotation
% when its determinant is $+1$. <rotation.byMatrix.html |byMatrix|> also
% accepts determinant $-1$ and records the result as an improper rotation;
% an arbitrary non-orthogonal matrix is not a rotation matrix.

rot = rotation.byMatrix(M)

%% Defined by What it Does
%
% Often the rotation is not known in any parametrisation, only by what it
% has to achieve. Given two non-collinear pairs of directions there is
% exactly one rotation taking |u1| to |v1| and |u2| to |v2|.

u1 = vector3d.X; v1 = vector3d.Y;
u2 = vector3d.Z; v2 = vector3d.Z;

rot = rotation.map(u1,v1,u2,v2)

%%
% This asks the impossible unless the angle between |u1| and |u2| equals the
% angle between |v1| and |v2|, and MTEX raises an error if it does not.
% Given only one pair, the rotation with the smallest angle taking the first
% direction to the second is returned. For opposite directions that angle is
% $180^\circ$ but its axis is not unique, so an additional direction is
% needed if the particular half turn matters.

rot = rotation.map(vector3d.Z,vector3d.Y)

%%
% With more directions than a rotation can satisfy exactly - measurements,
% say - <rotation.fit.html |rotation.fit|> returns the rotation for which
% |rot * left| is closest to |right|.

% five random directions
left = vector3d.rand(5);

% rotate them and perturb them a little
right = rot * left + 0.1 * vector3d.rand(1,5);

rotFit = rotation.fit(left,right)

%%
% Its angular error relative to the rotation used to make the data is

angle(rot,rotFit) ./ degree

%%
% small but nonzero. Its exact value changes with the random perturbation.

%% Random Rotations
%
% <rotation.rand.html |rotation.rand|> draws rotations uniformly, which is
% the quickest way to try something out on data that has no structure.

rot = rotation.rand(100);

length(rot)

%%
% Rotations following a given distribution rather than a uniform one are the
% subject of <RandomSampling.html Random Sampling>.

%% Quaternions
%
% Finally, a proper rotation is defined by the four coordinates of a *unit*
% quaternion. The two unit quaternions |q| and |-q| encode the same rotation.

q = quaternion(1,0,0,0)

rot = rotation(q)

%%
% This one is the identity, the rotation by an angle of zero, which is also
% written |rotation.id|.

%% Next
%
% <RotationOperations.html Operations> composes, inverts and applies
% rotations. Rotations that turn a crystal into a mirror image of itself are
% <RotationImproper.html Improper Rotations>, and a rotation that carries a
% crystal symmetry is an <OrientationDefinition.html orientation>.

%#ok<*NASGU>
%#ok<*NOPTS>
