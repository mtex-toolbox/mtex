%% Crystal Symmetries
%
%%
% A crystal point group is the set of symmetry operations that leave the
% crystal structure indistinguishable while keeping one point fixed. Its
% operations form a group: applying any two in succession gives another
% operation from the same set.
%
% The lattice metric may permit more operations than the arrangement of
% atoms does. The symmetry declared for a phase must therefore describe the
% phase, not merely the shape of its unit cell.
%
% In MTEX, a symmetry is the point group under which crystal data are
% invariant. It is attached to a *crystal frame*, but is not itself that
% frame. The crystal frame is the Cartesian reference frame glued to the
% lattice basis. This distinction matters when the same abstract symmetry
% type is used with different axis alignments.
%
% Symmetry also makes one physical orientation equivalent to several
% rotations. This equivalence controls fundamental regions, direction
% families, and misorientation angles throughout MTEX.
%
% Crystallography distinguishes 230 space-group types, 32 crystallographic
% point-group types, and 11 Laue classes. This page starts with point groups
% and then shows what MTEX retains from a space group.

%% The 11 Proper-Rotation Groups
%
% A <RotationImproper.html proper rotation> preserves handedness.
%
% The 11 crystallographic point-group types containing only proper rotations
% are 1, 2, 222, 3, 32, 4, 422, 6, 622, 23, and 432. They are also called
% the enantiomorphic point groups.
%
% <crystalSymmetry.crystalSymmetry.html |crystalSymmetry|> accepts either a
% Hermann--Mauguin symbol

cs = crystalSymmetry('432');

%%
% or its Schoenflies equivalent. The comparison confirms that both symbols
% construct the same point-group type.

csSchoenflies = crystalSymmetry('O');
cs.id == csSchoenflies.id

%%
% A symmetry-element plot makes the operations visible.

plot(cs)

%%
% The number of corners in a solid symbol gives the order of its proper
% rotation axis. The plot of 432 shows three fourfold axes along the crystal
% axes, four threefold axes along cube body diagonals, and six twofold axes.
% The rotations about these axes, together with the identity, give 24
% operations.

%% Laue Groups
%
% Adding <rotation.inversion.html |rotation.inversion|> to a proper-rotation
% group gives its Laue group. <symmetry.union.html |union|> performs that
% construction here.

csLaue = union(cs,rotation.inversion);

plot(csLaue)

%%
% The hollow circle at the centre is the inversion. The result is also
% available from the <symmetry.Laue.html |Laue|> property. Its summary shows
% that 432 has become $m\bar{3}m$ with 48 operations.

cs.Laue

%%
% Every Laue group is obtained this way from one of the 11 proper-rotation
% groups. Its order is twice that of the proper group because every rotation
% occurs once without inversion and once with inversion.
%
% The operation tables make the doubling explicit for 222.

cs = crystalSymmetry('222');
rotation(cs)

%%

rotation(cs.Laue)

%%
% The first table contains four proper operations. The second contains those
% four followed by four operations carrying the |Inv.| flag. Laue symmetry
% is the apparent symmetry of diffraction intensities when Friedel's law
% applies. Resonant scattering can break that equivalence. See
% <VectorsAxes.html Axes and Antipodal Symmetry> for the corresponding
% treatment of opposite directions.

%% Mixed Point Groups
%
% The remaining point groups contain improper operations but do not contain
% inversion itself. The group mm2 is an example.

cs = crystalSymmetry('mm2');
rotation(cs)

%%

plot(cs)

%%
% The table contains two proper and two improper operations. In the plot,
% great circles mark the two mirror planes and the solid lens marks the
% twofold axis. A hollow polygon would mark an improper rotation axis.
%
% The 10 mixed point-group types are m, mm2, 3m, -4, 4mm, -42m, -6, 6mm,
% -6m2, and -43m. Together with the 11 proper-rotation groups and 11 Laue
% groups, they make the 32 crystallographic point-group types.

%% Proper Group and Proper Subgroup
%
% A mixed group has two useful associated groups, and their names are easy
% to confuse. Consider -4m2.

cs = crystalSymmetry('-4m2');

%%
% <symmetry.properGroup.html |properGroup|> replaces every improper
% operation by the proper rotation with the same stored axis and angle. The
% result is 422 with eight operations.

properGroup = cs.properGroup

%%
% <symmetry.properSubGroup.html |properSubGroup|> instead retains only the
% operations of the original group that are proper. The result is 222 with
% four operations.

properSubGroup = cs.properSubGroup

%%
% The four plots compare the original point group with both proper groups
% and its Laue group.

mtexFigure('layout',[2 2]);
plot(cs)
text(gca,0.03,0.97,'-4m2','Units','normalized','VerticalAlignment','top')

nextAxis
plot(properGroup)
text(gca,0.03,0.97,'422','Units','normalized','VerticalAlignment','top')

nextAxis
plot(properSubGroup)
text(gca,0.03,0.97,'222','Units','normalized','VerticalAlignment','top')

nextAxis
plot(cs.Laue)
text(gca,0.03,0.97,'4/mmm','Units','normalized','VerticalAlignment','top')

%%
% The upper-left plot contains the actual operations of -4m2. The upper-right
% plot is its eight-operation proper group, 422. That group is not a subgroup
% of -4m2. The lower-left plot is its four-operation proper subgroup, 222.
% The lower-right plot is the 16-operation Laue group, 4/mmm.

%% Alignment of the Symmetry Operations
%
% A point-group type specifies which operations exist, but their alignment
% belongs to the crystal frame. The following plots show the same abstract
% group with its twofold axis aligned with a different crystal axis. The
% a-axis points east in every panel.

mtexFigure('layout',[1 3]);
cs = crystalSymmetry('2mm');
plot(cs)
text(gca,0.03,0.97,'2mm','Units','normalized','VerticalAlignment','top')
annotate(cs.aAxis,'labeled')

nextAxis
cs = crystalSymmetry('m2m');
plot(cs)
text(gca,0.03,0.97,'m2m','Units','normalized','VerticalAlignment','top')
annotate(cs.aAxis,'labeled')

nextAxis
cs = crystalSymmetry('mm2');
plot(cs)
text(gca,0.03,0.97,'mm2','Units','normalized','VerticalAlignment','top')
annotate(cs.aAxis,'labeled')

%%
% The twofold axis lies along a in the first panel, b in the second, and c in
% the third. Similar alternatives occur for 112, 121, 211, 11m, 1m1, m11,
% 321, 312, 3m1, and 31m. Choosing the wrong alignment changes how every
% Miller index and orientation is interpreted. See
% <CrystalReferenceSystem.html Reference System> for the role of the crystal
% frame and <SymmetryAlignment.html Crystal Axes Alignment> for changing
% between conventions.

%% Space Groups
%
% A space group also includes translations and operations with translational
% parts, such as screw rotations and glide reflections. MTEX accepts a
% Hermann--Mauguin space-group symbol. A number is passed through the
% |'SpaceId'| option. In either case, |crystalSymmetry| stores only the
% corresponding point group.

cs = crystalSymmetry('Fm-3m')

%%

plot(cs)

%%
% The summary identifies $m\bar{3}m$ with 48 operations. The plot likewise
% contains only point-group symmetry elements. It cannot show the face
% centring or any translational part of $Fm\bar{3}m$.

%% Computing with Symmetries
%
% <symmetry.union.html |union|> combines compatible symmetry operations,
% while <symmetry.disjoint.html |disjoint|> retains the operations common to
% two symmetries.

combined = union(crystalSymmetry('23'),crystalSymmetry('4'))

%%
% The operations of 23 together with the fourfold axis of 4 generate the 24
% operations of 432.

common = disjoint(crystalSymmetry('432'),crystalSymmetry('622'))

%%
% Cubic 432 and hexagonal 622 have the identity and three twofold rotations
% in common. Those four operations form 222.

%% Import from CIF and PHL Files
%
% <crystalSymmetry.load.html |crystalSymmetry.load|> reads the point group,
% lattice parameters, and phase name from a crystallographic information
% file. With no extension, MTEX searches its CIF data path.

csQuartz = crystalSymmetry.load('quartz')

%%
% A Bruker |.phl| file may contain several phases, so the result is a cell
% array of crystal symmetries. The first entry in the bundled example is
% magnetite.

csList = crystalSymmetry.load('crystal.phl');
csList{1}

%% References
%
% * M. I. Aroyo (ed.),
% <https://doi.org/10.1107/97809553602060000114 International Tables for
% Crystallography, Volume A: Space-group symmetry>, sixth edition, IUCr,
% 2016, is the definitive tabulation of the 230 space groups and 32
% crystallographic point groups.
% * Th. Hahn, H. Klapper, U. Müller, and M. I. Aroyo,
% <https://doi.org/10.1107/97809553602060000930 Point groups and crystal
% classes>, International Tables for Crystallography A, ch. 3.2, 2016,
% defines the point-group classification and notation used here.
% * The International Union of Crystallography,
% <https://dictionary.iucr.org/Friedel%27s_law Friedel's law>, explains the
% diffraction condition and its exception for resonant scattering.
% * The International Union of Crystallography,
% <https://www.iucr.org/resources/cif/dictionaries/browse/cif_core Core CIF
% dictionary>, defines the space-group and Laue-class data read from CIF
% files.
% * A. Morawiec,
% <https://doi.org/10.1007/978-3-662-09156-2 Orientations and Rotations:
% Computations in Crystallographic Textures>, Springer, 2004, develops the
% rotation-group treatment used in texture analysis.

%% Next
%
% <CrystalDirections.html Miller Indices> introduces directions and planes
% in the crystal frame. <CrystalOperations.html Operations> then applies the
% symmetries defined here to those directions, and
% <FundamentalSector.html Fundamental Sector> selects one representative
% from each equivalent family. A rotation together with crystal and specimen
% symmetry becomes an <OrientationDefinition.html orientation>.

%#ok<*NASGU>
%#ok<*NOPTS>
%#ok<*EQEFF>
