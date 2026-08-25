%% Calculating with Rotations
%
%%
% A rotation is applied to a direction, composed with another rotation, or
% inverted, and each of these is a single operator that works on whole
% lists at once.

plottingConvention.default('y↑→x');

%% Rotating a Direction
%
% The product |rot * v| turns the direction |v| by the rotation |rot|.

rot = rotation.byEuler(90*degree,90*degree,0*degree,'Bunge')

%%

v = rot * vector3d.X

%%
% The grey arrows are the specimen axes, the black arrow the direction we
% started from and the red arrow where the rotation sent it.

arrow3d(1.2*[vector3d.X,vector3d.Y,vector3d.Z],'faceColor',[.75 .75 .75])
hold on
arrow3d(1.05*vector3d.X,'faceColor','black')
arrow3d(1.05*v,'faceColor','red')
hold off
axis off

%%
% X has landed on Y. Undoing a rotation is the backslash operator
% <rotation.mldivide.html |\\|>, which takes the direction back where it
% came from.

rot \ v

%% Composing Rotations
%
% Rotations are composed by multiplication, and the one applied first stands
% on the right - as with matrices.

rot1 = rotation.byEuler(90*degree,0,0,'Bunge');
rot2 = rotation.byEuler(0,60*degree,0,'Bunge');

rot = rot2 * rot1

%%
% The order is not a detail. Swapping the two gives a different rotation,

rot2 * rot1 == rot1 * rot2

%%
% and the two results are this far apart.

angle(rot2*rot1, rot1*rot2) ./ degree

%% Axis and Angle
%
% <quaternion.angle.html |angle|> and <quaternion.axis.html |axis|> read the
% axis-angle description off any rotation, however it was built.

rot.angle / degree

%%

rot.axis

%% The Angle Between Two Rotations
%
% Given two rotations, |angle| measures how far apart they are - the angle
% of the rotation that turns one into the other. The composed rotation
% |rot| is |rot1| followed by |rot2|, so it sits exactly the angle of |rot2|
% away from |rot1|.

angle(rot,rot1) / degree

%%
% This number is the distance used throughout MTEX: how well a fit
% reproduces a measurement, how much orientation varies within a grain, how
% far a misorientation is from an ideal one. For orientations it additionally
% respects crystal symmetry, see
% <MisorientationTheory.html Misorientations>.
%
%% The Inverse Rotation
%
% <quaternion.inv.html |inv|> reverses a rotation. One may describe this as
% keeping the axis and changing the sign of the angle. MTEX instead reports
% the canonical nonnegative angle, so |axis(inv(rot))| normally has the
% opposite sign while |angle(inv(rot))| equals |angle(rot)|. The identity
% and half turns retain the axis ambiguities described on the definition
% page.

inv(rot)

%%
% A rotation multiplied by its inverse is the identity, which is what makes
% |rot \ v| above the same as |inv(rot) * v|.

rot * inv(rot)

%% Reading off Other Parametrisations
%
% Any parametrisation is available as a property or a command, whichever
% description the rotation was defined by.
%
% || <quaternion.Euler.html Euler(rot)> || the three Euler angles ||
% || <quaternion.Rodrigues.html Rodrigues(rot)> || the Rodrigues Frank vector ||
% || <quaternion.matrix.html matrix(rot)> || the rotation matrix ||
% || <quaternion.homochoric.html homochoric(rot)> || the homochoric vector ||
% || <quaternion.axis.html axis(rot)>, <quaternion.angle.html angle(rot)> || axis and angle ||
%
% Euler angles come in whichever convention is requested, and the answer
% differs between conventions. Here the Matthies convention is explicit,
% independent of the user's display preference.

[alpha,beta,gamma] = Euler(rot,'Matthies');

[alpha,beta,gamma] ./ degree

%% Next
%
% Sets of rotations rather than single ones are drawn in
% <RotationPlotting.html Plotting>, and a rotation carrying a crystal
% symmetry is an <OrientationDefinition.html orientation>, where composing
% in the right order becomes a question with a physical answer.

%#ok<*NOPTS>
