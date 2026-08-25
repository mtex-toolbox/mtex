%% Crystal Symmetries
%
%%
% A crystal symmetry is the set of operations - rotations, reflections, the
% inversion - that leave the lattice looking exactly as it did. Such a set
% is a group: applying two of its operations one after another gives a third
% one from the same set.
%
% This is why an orientation is never a single rotation. Every symmetry
% operation of the crystal produces an equally valid description of the same
% physical situation, and everything from the fundamental region to the
% misorientation angle follows from that.
%
% Which operations are counted decides how many groups there are: 230 space
% groups, 32 point groups, or 11 Laue groups.

%% The 11 Groups of Proper Rotations
%
% Exactly 11 groups consist of proper rotations only - 1, 2, 222, 3, 23, 4,
% 422, 6, 622, 32, 432. They are the *enantiomorphic* groups, and they are
% the symmetries a crystal can be physically turned by. Each is defined by
% its international notation

cs = crystalSymmetry('432')

%%
% or by its Schoenflies notation.

cs = crystalSymmetry('O')

plot(cs)

%%
% The plot marks every symmetry axis with a polygon whose number of corners
% is the order of the axis - a square for a fourfold axis, a triangle for a
% threefold one, a lens for a twofold one. Group 432 has three fourfold axes
% along a, b and c, four threefold axes along the body diagonals of the cube
% and six twofold axes, which together with the identity make 24 operations.

%% Laue Groups
%
% Adding the inversion to a group of proper rotations gives its *Laue
% group*.

csLaue = union(cs,rotation.inversion)

plot(csLaue)

%%
% The same is reached directly.

cs.Laue

%%
% Since every Laue group comes from one of the 11 enantiomorphic groups,
% there are 11 of them: -1, 2/m, mmm, -3, -3m, -4/m, 4/mmm, 6/m, 6/mmm, m-3,
% m-3m. A Laue group has exactly twice as many elements as the group it came
% from - each rotation appears once with and once without the inversion.

cs = crystalSymmetry('222');
rotation(cs)

%%

rotation(cs.Laue)

%%
% Four operations became eight, and the second four are the first four
% carrying the |Inv.| flag. Laue groups matter for diffraction, where
% Friedel's law makes a reflection and its opposite indistinguishable, see
% <VectorsAxes.html Axes and Antipodal Symmetry>.

%% Point Groups
%
% Between the two extremes sit groups that contain improper operations but
% not the inversion itself, such as mm2.

cs = crystalSymmetry('mm2');
rotation(cs)

%%

plot(cs)

%%
% Its four operations are those of 222, but two of them are improper - the
% two twofold axes have become mirror planes, drawn as the great circles
% they cut on the sphere. A hollow symbol likewise marks an axis whose
% operation is improper, and the small circle at the centre of a Laue
% group's plot is the inversion. Replacing half the rotations
% of an enantiomorphic group by their improper versions this way produces
% the remaining 10 groups: m, mm2, 3m, -4, 4m2, -42m, -6, 6mm, -6m2, -43m.
% Together, 11 enantiomorphic + 11 Laue + 10 mixed = 32 point groups.

%% Proper Group and Proper Subgroup
%
% For a mixed group there are two different ways to arrive at proper
% rotations, and they give different answers.

cs = crystalSymmetry('-4m2')

mtexFigure('layout',[1 3]);
plot(cs)
mtexTitle(char(cs,'LaTex'))
nextAxis
plot(cs.properGroup)
mtexTitle(char(cs.properGroup,'LaTex'))
nextAxis
plot(cs.Laue)
mtexTitle(char(cs.Laue,'LaTex'))

%%
% |cs.properGroup| turns every improper operation into the proper one with
% the same axis, which for -4m2 gives 422 - eight operations, four of which
% were not symmetries of -4m2 at all. It is the group the point group is
% derived *from*, not a part of it.
%
% The operations of |cs| that really are proper form |cs.properSubGroup|,

plot(cs.properSubGroup)
mtexTitle(char(cs.properSubGroup,'LaTex'))

%%
% which is 222, half of -4m2's eight operations. Use |properGroup| to ask
% which enantiomorphic group a point group belongs to, and |properSubGroup|
% to ask which of its operations a crystal can be turned by.

%% Alignment of the Symmetry Operations
%
% A point group fixes which operations exist, not how they sit with respect
% to the crystal axes. The three plots below are the same group with three
% different alignments, and the a-axis points south in all of them.

mtexFigure('layout',[1 3]);
cs = crystalSymmetry('2mm');
plot(cs)
mtexTitle(char(cs,'LaTex'))
annotate(cs.aAxis,'labeled')

nextAxis
cs = crystalSymmetry('m2m');
plot(cs)
mtexTitle(char(cs,'LaTex'))
annotate(cs.aAxis,'labeled')

nextAxis
cs = crystalSymmetry('mm2');
plot(cs)
mtexTitle(char(cs,'LaTex'))
annotate(cs.aAxis,'labeled')

%%
% The twofold axis lies along a in the first plot, along b in the second and
% along c in the third. The same freedom exists for 112, 121, 211, 11m, 1m1,
% m11, 321, 312, 3m1, 31m and others, and getting it wrong rotates every
% orientation in a data set. Which alignment a data set uses is discussed in
% <SymmetryAlignment.html Crystal Axes Alignment>.

%% Space Groups
%
% Counting translations as symmetry operations as well gives the 230 space
% groups of the international tables. MTEX does not support space groups: a
% space group name passed to |crystalSymmetry| is reduced to the
% corresponding point group.

cs = crystalSymmetry('Td');
plot(cs)

%% Computing with Symmetries
%
% <symmetry.union.html |union|> is the smallest group containing two given
% ones and <symmetry.disjoint.html |disjoint|> the largest group contained
% in both.

union(crystalSymmetry('23'),crystalSymmetry('4'))

%%
% The 12 operations of 23 together with the fourfold axis of 4 generate all
% 24 operations of 432.

disjoint(crystalSymmetry('432'),crystalSymmetry('622'))

%%
% Cubic and hexagonal symmetry share only the three twofold axes of 222.

%% Import from CIF and PHL Files
%
% Real minerals are not entered by hand but read from a crystallographic
% information file.

cs = crystalSymmetry.load('quartz')

%%
% A Bruker |.phl| file usually holds several phases, so the result is a list
% of crystal symmetries.

% import a list of crystal symmetries
cs_list = crystalSymmetry.load('crystal.phl');

% access the first symmetry in list
cs_list{1}

%% Next
%
% What symmetry does to a crystal direction - the equivalent directions, and
% the patch of the sphere that holds one representative of each - is
% <CrystalOperations.html Operations> and
% <FundamentalSector.html Fundamental Sector>. A rotation together with a
% crystal symmetry is an <OrientationDefinition.html orientation>.

%#ok<*NASGU>
%#ok<*NOPTS>
