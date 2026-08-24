%% Misorientations
%
%%
% An orientation says how one crystal sits in the specimen. A
% *misorientation* says how two crystals sit relative to each other - it is
% the rotation that carries the lattice of the first onto the lattice of
% the second. The specimen has dropped out of the question entirely: turn
% the sample on the stage and every orientation changes, but no
% misorientation does.
%
% That independence is why misorientations carry so much of the physics.
% Whether two grains meet across a twin boundary, whether a lath of
% martensite grew from a particular parent grain, how much a grain has bent
% internally - none of these depend on how the sample happened to be
% mounted, so all of them are naturally expressed as misorientations.
%
% The picture below is a magnesium map whose grain borders are coloured by
% the misorientation angle across them. Two populations stand out at once:
% a scatter of small angles, and a set of borders sharing one particular
% large angle.

plottingConvention.default('y↑→x');
mtexdata twins silent

grains = calcGrains(ebsd('indexed'),'threshold',5*degree);
grains = smoothBoundary(grains,5);

plot(ebsd('indexed'),ebsd('indexed').orientations,'micronbar','off')
hold on
plot(grains.boundary,grains.boundary.misorientation.angle./degree,'linewidth',3)
mtexColorbar('title','misorientation angle in degree')
hold off

%%
% The sharp population near 86 degrees is not a coincidence: it is the
% signature of a twin, one specific misorientation repeated at many
% independent borders. Finding such populations is most of what this
% chapter is for.
%
%% Two words that are easy to confuse
%
% A crystal has symmetry, so a misorientation is never a single rotation.
% For a cubic crystal there are 24 ways of labelling the lattice axes of
% the first crystal and 24 of the second, which gives up to 576 rotations
% that all describe the same physical relationship. They are called
% symmetrically equivalent.
%
% *Misorientation* means any one of them. *Disorientation* means the
% particular one with the smallest rotation angle, chosen so that a single
% number can be quoted. When a boundary is described as "a 60 degree
% boundary", that 60 degrees is a disorientation angle.
%
% This is also why a misorientation angle can never be compared across
% phases without care: the set of equivalent rotations depends on the
% symmetry of both crystals involved.
%
% One further ambiguity is easy to miss. A misorientation has a direction -
% from the first crystal to the second - and reversing it gives the inverse
% rotation. Between two grains of the same phase there is nothing that makes
% either of them first, so the physically meaningful object is the rotation
% and its inverse taken together. This is called grain exchange symmetry, and
% it has to be included when misorientations are counted into a distribution,
% or the same boundary is recorded as two different relationships.
%
%% Where to start
%
% <MisorientationTheory.html Theory> is the page to read first. It builds
% the misorientation from two orientations, shows what symmetry does to it,
% and introduces the fundamental region - the piece of rotation space in
% which each physical relationship appears exactly once.
%
% Once misorientations exist as data, the question becomes how they are
% distributed. The misorientation distribution function, or MDF, plays the
% same role for misorientations that the ODF plays for orientations, and
% <MisorientationDistributionFunction.html the MDF page> covers it. Its two
% projections are often more readable than the full function, and each has
% a page: <AngleDistributionFunction.html the angle distribution> answers
% "how far apart are neighbouring crystals", and
% <AxisDistributionFunction.html the axis distribution> answers "about
% which crystal direction do they turn". Comparing either against the
% distribution expected from randomly oriented crystals is the standard way
% to show that a population is real.
%
%% Next
%
% Misorientations between neighbouring grains are the subject of
% <GrainBoundaries.html Grain Boundaries>, which is where the CSL and
% twinning analyses live. Misorientations between a parent phase and its
% products drive <PhaseTransitions.html Phase Transitions>. The orientations
% these are all built from are described in
% <CrystalOrientations.html Orientations>.
%
