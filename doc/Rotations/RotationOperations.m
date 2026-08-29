%% Calculating with Rotations
%
%%
% This page assumes the directions introduced in
% <VectorDefinition.html Defining Three-Dimensional Vectors> and the active
% rotations introduced in <RotationDefinition.html Defining Rotations>.
%
% A reference frame is the coordinate system in which data are expressed.
% The rotations below move objects within one reference frame. They do not
% perform a frame change, which re-expresses the same physical object in a
% different reference frame without moving it.
%
% The examples use proper rotations. Reflections and inversions are covered
% in <RotationImproper.html Improper Rotations>.

plottingConvention.default('y↑→x');

%% Rotating a Direction
%
% The product |rot * v| actively turns the direction |v| by |rot|.

rot = rotation.byEuler(90*degree,90*degree,0*degree,'Bunge');

%%

v = rot * vector3d.X

%%
% The grey arrows are the specimen axes. The black arrow is X before the
% rotation, and the red arrow is its image.

arrow3d(1.2*[vector3d.X,vector3d.Y,vector3d.Z],...
  'faceColor',[.75 .75 .75])
hold on
arrow3d(1.05*vector3d.X,'faceColor','black')
arrow3d(1.05*v,'faceColor','red')
hold off
axis off

%%
% The red arrow coincides with Y, so this rotation sends X to Y.
% <rotation.mldivide.html |\\|> applies the inverse rotation and returns the
% direction to X.

rot \ v

%% Composing Rotations
%
% Multiplication composes rotations. The rotation on the right acts first,
% just as it does in matrix multiplication.

rot1 = rotation.byEuler(90*degree,0,0,'Bunge');
rot2 = rotation.byEuler(0,60*degree,0,'Bunge');

rot = rot2 * rot1;

%%
% The order matters. <quaternion.eq.html |==|> tests rotation equality
% within an angular tolerance, rather than comparing printed Euler angles.
% Reversing these two rotations does not give the same result.

rot2 * rot1 == rot1 * rot2

%%
% Their angular separation is 82.8192 degrees.

angle(rot2*rot1,rot1*rot2) ./ degree

%%
% The black arrow below is one starting direction. The red arrow results
% from |rot1| followed by |rot2|, while the blue arrow shows the reverse
% order.

startDirection = normalize(vector3d(1,1,1));
forwardDirection = rot2 * (rot1 * startDirection);
reverseDirection = rot1 * (rot2 * startDirection);

figure;
arrow3d(1.2*[vector3d.X,vector3d.Y,vector3d.Z],...
  'faceColor',[.75 .75 .75])
hold on
arrow3d(1.05*startDirection,'faceColor','black')
arrow3d(1.05*forwardDirection,'faceColor','red')
arrow3d(1.05*reverseDirection,'faceColor','blue')
hold off
axis off

%%
% The separated red and blue arrows make the noncommutativity visible.
% Parentheses are useful whenever the intended order might otherwise be
% misread.

%% Axis and Angle
%
% <quaternion.angle.html |angle|> and <quaternion.axis.html |axis|> read the
% axis--angle description from the composed rotation, however it was built.

rot.angle ./ degree

%%

rot.axis

%%
% The composite is a 104.4775 degree turn about the displayed axis. This is
% not the sum of the two input angles because rotations about different axes
% do not add like vectors.

%% The Inverse Rotation
%
% <quaternion.inv.html |inv|> reverses a rotation. For a nonzero turn below
% 180 degrees, the inverse has the opposite axis and the same canonical,
% nonnegative angle.

invRot = inv(rot);

[rot.axis,invRot.axis]

%%

[rot.angle,invRot.angle] ./ degree

%%
% A rotation multiplied by its inverse is the identity. This is why
% |rot \ v| is the same operation as |inv(rot) * v|.

rot * invRot

%% The Angle Between Two Rotations
%
% The relative rotation below acts after |rot1| and carries its result to
% the result of |rot|. Its principal angle is the angular distance between
% the two rotations.

relativeRot = rot * inv(rot1);

[relativeRot.angle,angle(rot,rot1)] ./ degree

%%
% Both entries are 60 degrees. The second is the direct
% <quaternion.angle.html |angle(rot,rot1)|> call, so there is usually no need
% to construct the relative rotation explicitly.
%
% This angular distance is used throughout MTEX to compare a fit with a
% measurement and to quantify orientation variation. For orientations it
% additionally minimizes over symmetry-equivalent descriptions, as
% explained in <OrientationSymmetry.html Orientation Symmetry>.

%% Lists of Rotations
%
% MTEX objects are vectorized. If both operands are non-scalar, |.*| pairs
% corresponding entries while |*| forms every combination. A scalar operand
% is applied to the whole list with either operator.

rotations = rotation.byAxisAngle(vector3d.Z,[0 30 60]*degree);
directions = [vector3d.X,vector3d.Y,vector3d.Z];

size(rotations .* directions)

%%
% The elementwise result has size 1-by-3: one output for each pair.

size(rotations * directions)

%%
% The outer result has size 3-by-3: every rotation was applied to every
% direction. The same distinction applies when two rotation lists are
% composed.

%% Reading Other Parametrisations
%
% A rotation can be inspected in any representation, regardless of how it
% was constructed.
%
% || <quaternion.Euler.html Euler(rot)> || the three Euler angles ||
% || <quaternion.Rodrigues.html Rodrigues(rot)> || the Rodrigues--Frank vector ||
% || <quaternion.matrix.html matrix(rot)> || the rotation matrix ||
% || <quaternion.homochoric.html homochoric(rot)> || the homochoric vector ||
% || <quaternion.cubochoric.html cubochoric(rot)> || the cubochoric vector ||
% || <quaternion.axis.html axis(rot)>, <quaternion.angle.html angle(rot)> || axis and angle ||
%
% Euler angles depend on a convention. Naming Matthies here makes the
% result independent of the user's display preference.

[alpha,beta,gamma] = Euler(rot,'Matthies');

[alpha,beta,gamma] ./ degree

%%
% The displayed 270, 60, 180 degree triplet is the Matthies description of
% the same composite rotation. See
% <RotationRepresentations.html Rotation Representations> before comparing
% coordinates produced by different programs.

%% The Maths Behind the Angular Distance
%
% For rotations $r_1$ and $r_2$, MTEX uses the principal angle of a relative
% rotation:
%
% $$ d(r_1,r_2) = \mathop{\rm angle}(r_2 r_1^{-1})
%                 = \mathop{\rm angle}(r_1^{-1}r_2). $$
%
% The two relative rotations generally have different axes, but they have
% the same angle. The distance is unchanged if the same rotation is
% composed onto both inputs from the left or from the right. This invariance
% is why the 60 degree result above does not depend on the starting
% orientation |rot1|.

%% References
%
% * A. Morawiec,
% <https://doi.org/10.1007/978-3-662-09156-2 Orientations and Rotations:
% Computations in Crystallographic Textures>, Springer, 2004, develops
% composition and the geometry of rotation space for texture analysis.
% * D. Rowenhorst et al.,
% <https://doi.org/10.1088/0965-0393/23/8/083501 Consistent
% representations of and conversions between 3D rotations>, Modelling and
% Simulation in Materials Science and Engineering 23 (2015) 083501,
% documents the convention choices behind common parametrisations.

%% Next
%
% Sets of rotations are drawn in <RotationPlotting.html Plotting>. A
% rotation that maps crystal coordinates into specimen coordinates and
% carries crystal symmetry is an
% <OrientationDefinition.html orientation>.

%#ok<*NOPTS>
%#ok<*VUNUS>
%#ok<*MINV>
%#ok<*ELARLOG>
