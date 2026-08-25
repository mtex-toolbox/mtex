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
% The most common description of a rotation is as three consecutive
% rotations about fixed axes - first about the z axis, then about the x
% axis, then about z again. The three angles are the *Euler angles*.
%
% Three angles alone do not define a rotation. Which axes they turn about,
% and in which order, is a convention, and several are in use. Sorted by
% popularity in the texture analysis community they are
%
% * Bunge (phi1,Phi,phi2)       - ZXZ
% * Matthies (alpha,beta,gamma) - ZYZ
% * Roe (Psi,Theta,Phi)
% * Kocks (Psi,Theta,phi)
% * Canova (omega,Theta,phi)
%
% MTEX uses the Bunge convention by default.

rot = rotation.byEuler(30*degree,50*degree,10*degree)

%%
% Angles are radians throughout MTEX, which is why each of them is written
% as a multiple of |degree|. The first and the third angle are interchanged
% with respect to the usual notation, for the reason given in
% <MTEXvsBungeConvention.html MTEX vs. Bunge Convention>.
%
% A different convention is named as an additional argument. The following
% rotation is a different one, although the three numbers are the same.

rot = rotation.byEuler(30*degree,50*degree,10*degree,'Roe')

%%
% What convention the angles are *displayed* in is a separate question, set
% by <setMTEXpref.html |setMTEXpref|> and stored permanently in
% |mtex_settings.m|. The same rotation reads

setMTEXpref('EulerAngleConvention','Roe')
rot

%%

setMTEXpref('EulerAngleConvention','Bunge')
rot

%%
% Same rotation, different numbers. When Euler angles are quoted without
% their convention, they are ambiguous - this is the single most common
% source of orientations that are wrong by a fixed transformation.

%% Axis and Angle
%
% Every rotation turns the sphere about one axis, so an axis and an angle
% describe it completely.

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
% The Rodrigues Frank vector packs axis and angle into a single vector: the
% rotational axis, scaled by $\tan \omega/2$.

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
% Conversely a matrix defines a rotation.

rot = rotation.byMatrix(M)

%% Defined by What it Does
%
% Often the rotation is not known in any parametrisation, only by what it
% has to achieve. Given two pairs of directions there is exactly one
% rotation taking |u1| to |v1| and |u2| to |v2|.

u1 = vector3d.X; v1 = vector3d.Y;
u2 = vector3d.Z; v2 = vector3d.Z;

rot = rotation.map(u1,v1,u2,v2)

%%
% This asks the impossible unless the angle between |u1| and |u2| equals the
% angle between |v1| and |v2|, and MTEX raises an error if it does not.
% Given only one pair, the rotation with the smallest angle taking the first
% direction to the second is returned.

rot = rotation.map(vector3d.Z,vector3d.Y)

%%
% With more directions than a rotation can satisfy exactly - measurements,
% say - <rotation.fit.html |rotation.fit|> returns the rotation for which
% |rot * left| is closest to |right|.

% five random directions
left = vector3d.rand(5);

% rotate them and perturb them a little
right = rot * left + 0.1 * vector3d.rand(1,5);

rotation.fit(left,right)

%%
% The recovered rotation is the one used above, up to the perturbation.

%% Random Rotations
%
% <rotation.rand.html |rotation.rand|> draws rotations uniformly, which is
% the quickest way to try something out on data that has no structure.

rot = rotation.rand(100)

%%
% Rotations following a given distribution rather than a uniform one are the
% subject of <RandomSampling.html Random Sampling>.

%% Quaternions
%
% Finally a rotation is defined by the four quaternion coordinates it is
% stored in.

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
