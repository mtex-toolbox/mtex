%% Improper Rotations
%
%%
% A rotation preserves handedness: a right handed set of axes stays right
% handed. An *improper rotation* does not - it turns the object into its
% mirror image. Inversions and reflections are of this kind, and crystal
% symmetry needs them, since most point groups contain a mirror plane or an
% inversion centre.
%
% MTEX stores improper transformations in the same <rotation.rotation.html
% |@rotation|> class and records their handedness with an inversion flag.

plottingConvention.default('y↑→x');

%% The Inversion
%
% The inversion sends every direction to its opposite. It is written as the
% negative identity.

I = - rotation.id

%%
% Directions come back negated, which is what the minus sign is for.

I * vector3d.X

%%
% Writing it this way keeps the two ways of bracketing the same, which is
% the reason for the convention.

- (rotation.id * vector3d.X)

%% Reflections
%
% A reflection at a plane is a rotation by $180^\circ$ about the normal of
% that plane, followed by the inversion. Spelled out for the plane with
% normal $(111)$,

mir = - rotation.byAxisAngle(vector3d(1,1,1),180*degree)

%%
% and as a shortcut,

mir = reflection(vector3d(1,1,1))

%%
% A direction in the mirror plane is left where it is,

mir * vector3d(1,-1,0)

%%
% while the normal of the plane is sent to its opposite.

mir * vector3d(1,1,1)

%% Telling the Two Apart
%
% <rotation.isImproper.html |isImproper|> answers whether handedness is
% preserved.

mir.isImproper

%%
% This matters when a symmetry group is used as a set of operations: only
% the proper elements are motions a crystal can actually be turned by, and
% the improper ones exist as symmetries of the lattice, not as rotations of
% the specimen. Which elements a group has is discussed in
% <CrystalSymmetries.html Crystal Symmetries>, and the proper subgroup is
% reached by |cs.properGroup|.

%% Next
%
% <RotationOperations.html Operations> covers composition, inversion and
% action on vectors for both proper and improper transformations. Axis-angle
% and other proper-rotation parametrisations need separate interpretation
% when the inversion flag is set.

%#ok<*NASGU>
%#ok<*NOPTS>
