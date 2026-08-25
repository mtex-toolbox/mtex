%% Improper Rotations
%
%%
% A proper rotation preserves lengths, angles, and handedness. An
% *improper rotation* also preserves lengths and angles, but changes a
% right-handed object into its mirror image. The name is historical:
% improper does not mean invalid, and such a transformation cannot be made
% by physically turning a rigid object.
%
% This page assumes the active action |rot * v| and the matrix
% representation introduced in <RotationDefinition.html Defining
% Rotations>.
%
% Proper and improper transformations together form the orthogonal group
% O(3). Its proper part is the rotation group SO(3). MTEX stores both in the
% <rotation.rotation.html |rotation|> class and records which part an
% object belongs to with an inversion flag.

plottingConvention.default('y↑→x');

%% The Inversion
%
% The inversion sends every direction to its opposite. The named
% constructor is <rotation.inversion.html |rotation.inversion|>.

I = rotation.inversion;

I * vector3d.X

%%
% The result is $(-1,0,0)$. Unary minus on a |rotation| toggles its
% inversion flag, so the inversion can also be written as the negative
% identity.

I == -rotation.id

%%
% Do not confuse unary minus with <quaternion.inv.html |inv|>.
% |inv(turn)| undoes a turn, whereas |-turn| combines the same proper part
% with the inversion. The first result below is proper and the second is
% improper.

turn = rotation.byAxisAngle(vector3d.Z,30*degree);

isImproper([inv(turn),-turn])

%% Reflection in a Plane
%
% A reflection leaves every direction in its mirror plane fixed and
% reverses the component normal to the plane. In MTEX,
% <reflection.html |reflection|> takes the plane normal as its argument.

planeNormal = vector3d(1,1,1);
mir = reflection(planeNormal);

%%
% The same transformation is a half turn about the plane normal followed
% by the inversion.

mir == -rotation.byAxisAngle(planeNormal,180*degree)

%%
% The direction $(1,-1,0)$ is perpendicular to the normal and therefore
% lies in the mirror plane. It is unchanged.

mir * vector3d(1,-1,0)

%%
% The plane normal is perpendicular to the mirror and changes sign.

mir * planeNormal

%%
% The grey patch below is the mirror plane. The black direction and its red
% image have equal components within the plane and opposite components
% along the blue normal.

n = normalize(planeNormal);
v = normalize(vector3d(1,-0.2,0.5));
mirroredV = mir * v;

axis([-1.3 1.3 -1.3 1.3 -1.3 1.3])
plot(plane3d(n,0),'FaceColor',[0.75 0.75 0.75],'EdgeColor','none')
hold on
arrow3d(v,'FaceColor','black')
arrow3d(mirroredV,'FaceColor','red')
arrow3d(n,'FaceColor','blue')
hold off
axis equal off

%% Parity under Composition
%
% <rotation.isImproper.html |isImproper|> reports whether a transformation
% reverses handedness. A single reflection is improper, whereas composing
% two reflections restores handedness.

mirrorX = reflection(vector3d.X);
mirrorY = reflection(vector3d.Y);

isImproper([mirrorX,mirrorX*mirrorY])

%%
% The two-reflection product is the proper half turn about Z. Their angular
% difference is zero degrees.

angle(mirrorX*mirrorY,...
  rotation.byAxisAngle(vector3d.Z,180*degree)) ./ degree

%% Improper Operations in Crystal Symmetry
%
% Crystal point groups may contain both kinds of operation. For the mixed
% point group $\bar{4}m2$, the displayed values are the total number of
% operations, the number of proper operations, and the number of improper
% operations.

cs = crystalSymmetry('-4m2');
ops = rotation(cs);
improperFlags = isImproper(ops);

[length(ops),sum(~improperFlags(:)),sum(improperFlags(:))]

%%
% Only the proper operations are physical turns that superpose the crystal
% on itself. <symmetry.properSubGroup.html |properSubGroup|> retains those
% four operations. Do not confuse it with
% <symmetry.properGroup.html |properGroup|>, which returns the associated
% enantiomorphic group and has eight operations in this example.

[length(rotation(cs.properSubGroup)),...
  length(rotation(cs.properGroup))]

%% The Matrix Test
%
% The matrix of every length-preserving linear transformation is
% orthogonal. Its determinant is $+1$ for a proper rotation and $-1$ for an
% improper transformation.

proper = rotation.id;
improper = rotation.inversion;

[det(matrix(proper)),det(matrix(improper))]

%%
% MTEX stores an improper transformation as a proper quaternion together
% with the inversion flag. Axis-angle and Euler values therefore describe
% only that stored proper part. Use |isImproper| or <rotation.matrix.html
% |matrix|> when the handedness of the full transformation matters.

%% References
%
% * The International Union of Crystallography,
% <https://dictionary.iucr.org/Symmetry_operation Symmetry operation>,
% classifies inversion, reflections, and rotoinversions as operations that
% relate enantiomorphous objects.
% * G. Rigault,
% <https://www.iucr.org/education/pamphlets/10/full-text Metric tensor and
% symmetry operations in crystallography>, IUCr Teaching Pamphlet 10,
% derives the determinant classification and the crystallographic point
% groups.
% * Z. Dauter and M. Jaskolski,
% <https://doi.org/10.1107/S0021889810026956 How to read (and understand)
% Volume A of International Tables for Crystallography: an introduction for
% nonspecialists>, Journal of Applied Crystallography 43 (2010) 1150--1171,
% connects proper rotations and rotoinversions to Hermann--Mauguin notation.
% * A. Morawiec,
% <https://doi.org/10.1007/978-3-662-09156-2 Orientations and Rotations:
% Computations in Crystallographic Textures>, Springer, 2004, develops the
% rotation and symmetry framework used in texture analysis.

%% Next
%
% <RotationOperations.html Operations> covers composition, inversion, and
% action on directions. <CrystalSymmetries.html Crystal Symmetries>
% develops proper, Laue, and mixed point groups and explains the difference
% between |properSubGroup| and |properGroup|.

%#ok<*NASGU>
%#ok<*NOPTS>
%#ok<*EQEFF>
