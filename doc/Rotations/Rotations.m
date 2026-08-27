%% Rotations
%
%%
% A rotation is the answer to "how do I turn this?". It takes every
% direction and moves it to another one, without stretching anything and
% without turning the object into its mirror image.
%
% Rotations are worth a chapter of their own because they behave less
% simply than they look. Applying one after another is not commutative -
% turn a book about its spine and then about its long edge, then do it the
% other way round, and the book ends up somewhere else. There is also no
% way to average two rotations by averaging their numbers, whichever
% numbers you pick. Almost every subtlety later in MTEX, from Euler angle
% conventions to the fundamental region, is this chapter's material wearing
% a crystallographic hat.
%
% Below, one rotation is applied to a cloud of directions. The open circles
% are where the directions started and the filled ones are where they
% ended up.

% turn by 60 degrees about the z axis
rot = rotation.byAxisAngle(vector3d.Z,60*degree);

v = equispacedS2Grid('points',80,'upper');

plot(v,'upper','grid','MarkerFaceColor','none','MarkerEdgeColor','k')
hold on
plot(rot*v,'upper','MarkerFaceColor','r','MarkerSize',5)
hold off

%%
% Every point has moved along a circle of constant latitude about the
% rotation axis, and the axis itself - the centre of the plot - has not
% moved at all. Every rotation has such an axis, which is what makes the
% axis-and-angle description possible.
%
%% One rotation, many descriptions
%
% The same rotation can be written as three Euler angles, as an axis and an
% angle, as a 3x3 matrix, as a unit quaternion, or as a Rodrigues vector.
% These are genuinely the same object, but they are not equally convenient,
% and the differences are not merely a matter of taste.
%
% Euler angles are the ones most often quoted and the ones most often
% misread, because a set of three angles means nothing until you also say
% which axes they turn about and in which order - and the conventions in
% use disagree. Matrices compose by multiplication but take nine numbers to
% store three degrees of freedom. Quaternions compose cheaply and
% interpolate well, at the price of describing each rotation twice, since
% a quaternion and its negative are the same rotation. MTEX computes with
% quaternions and will happily print whichever description you ask for.
%
%% Rotations that are not proper
%
% Reflections and inversions also preserve lengths and angles, but they
% swap left-handed for right-handed. They are not rotations, though they
% belong in the same family, and crystal symmetry needs them: most point
% groups contain mirror planes or an inversion centre.
% <RotationImproper.html Improper Rotations> is where they are handled, and
% the reason a symmetry element is not always something you can physically
% turn a crystal by.
%
%% Where to start
%
% <RotationDefinition.html Definition> and
% <RotationRepresentations.html Representations> come first, in that order:
% how to build a rotation, and how the descriptions above relate.
%
% <RotationOperations.html Operations> covers composing, inverting, and
% applying rotations to directions, together with the angle between two
% rotations - which is how "close" is measured throughout MTEX.
%
% <RotationPlotting.html Plotting> and <RotationFibre.html Fibres> deal with
% sets of rotations. A fibre is the set of all rotations taking one fixed
% direction onto another; it is a curve in rotation space and it turns up
% constantly in texture, since many real textures are described exactly that
% way.
%
% Two pages are for readers who need rotations that vary:
% <RotationTangentSpace.html Tangent Spaces> gives the language for small
% changes in rotation, and <RotationSpinTensor.html Spin Tensor> connects
% that to the rate of rotation in a deforming material.
%
% <OrientationImport.html Import> and <OrientationExport.html Export> handle
% files.
%
%% Next
%
% A rotation together with a crystal symmetry is an *orientation*, and that
% is <CrystalOrientations.html Orientations>. The relative rotation between
% two crystals is a *misorientation*,
% <Misorientations.html Misorientations>. Functions defined on the set of
% all rotations - which is what an ODF is - are
% <SO3Functions.html Orientation Functions>.
%
