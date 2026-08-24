%% Glossary
%
%%
% Short definitions of the terms used throughout this documentation, with
% links to where each is developed properly. Terms that are easy to
% confuse with one another are defined next to each other rather than
% strictly alphabetically.
%
%% Directions and crystals
%
% *Antipodal* - the flag marking a quantity as an axis rather than a
% direction, so that it and its opposite are the same thing. It changes
% angles, means and densities, and nothing warns you if it is missing. See
% <VectorsAxes.html Axes>.
%
% *Miller indices* - the notation for planes and directions in a lattice.
% Round brackets |(hkl)| name a plane, square brackets |[uvw]| a direction;
% braces |{hkl}| and angle brackets |<uvw>| name the whole symmetric family.
% The two are not interchangeable: in quartz the plane (100) and the
% direction [100] are 30 degrees apart. See
% <CrystalDirections.html Miller Indices>.
%
% *Point group* - the symmetry operations that leave one point of the
% lattice fixed. There are 32. *Space group* - the same allowing
% translations as well, of which there are 230. *Laue group* - a point
% group with an inversion centre added, of which there are 11, and what a
% diffraction experiment can actually determine. See
% <CrystalSymmetries.html Crystal Symmetries>.
%
% *Crystal frame* - the Cartesian axes glued to the lattice. *Specimen
% frame* - the axes the sample is described in. Nearly every confusing
% result comes from a quantity being read in one when it was written in the
% other. See <CrystalReferenceSystem.html Reference System>.
%
% *Fundamental sector* - the patch of the sphere holding exactly one of
% each symmetrically equivalent direction; what an inverse pole figure is
% drawn on. *Fundamental region* - the same idea for orientations. See
% <FundamentalSector.html Fundamental Sector> and
% <OrientationFundamentalRegion.html Fundamental Region>.
%
%% Orientations
%
% *Orientation* - the rotation relating the specimen frame to the crystal
% frame; how one crystal is placed in the sample. See
% <CrystalOrientations.html Orientations>.
%
% *Misorientation* - the rotation relating two crystals to each other,
% independent of the specimen. *Disorientation* - the one representative of
% a misorientation with the smallest rotation angle, which is the number
% quoted when a boundary is called "a 60 degree boundary". Symmetry makes
% many rotations describe the same relationship; disorientation picks one.
% See <MisorientationTheory.html Theory>.
%
% *Grain exchange symmetry* - the further ambiguity that a misorientation
% between two grains of the same phase has no natural direction, so a
% rotation and its inverse describe the same boundary.
%
% *Variant* - one of the several child orientations a single parent
% orientation can produce under an orientation relationship. *Packet* -
% variants grouped by shared habit plane. *Bain group* - variants grouped
% by which parent cube axis the child aligns to. Packet and Bain group are
% independent classifications of the same variants, not two levels of one
% hierarchy. See <PhaseTransitions.html Phase Transitions>.
%
% *Fibre* - the set of all orientations that put one fixed crystal
% direction along one fixed specimen direction. A curve in orientation
% space, and the shape many real textures take. See
% <OrientationFibre.html Fibres>.
%
%% Distributions
%
% *Texture* - the departure of a material's orientations from randomness.
%
% *ODF* - orientation distribution function, the density of material over
% orientations. Being a density, it gives no volume fraction to a single
% orientation, only to a region of them. See <ODFAnalysis.html ODF>.
%
% *MRD* - multiples of a random distribution, the unit an ODF is reported
% in. A value of 1 everywhere is no texture; a value of 20 means twenty
% times as much material near that orientation as chance would give.
%
% *Pole figure* - the density of one chosen crystal direction over all
% specimen directions. *Inverse pole figure* - the reverse, the density of
% one chosen specimen direction over crystal directions. Both are
% projections of an ODF and both lose information. See
% <OrientationPoleFigure.html Pole Figures>.
%
% *Ghost effect* - the ODF error that follows from pole figures being
% blind to the odd part of the harmonic expansion. Not a numerical
% artefact but a genuine gap in what diffraction can know. See
% <PoleFigure2ODFAmbiguity.html The Ghost Effect>.
%
% *Halfwidth* - how far each measurement is spread when a density is
% estimated from discrete data. *Bandwidth* - the highest harmonic degree
% kept in a series representation. The two are the same trade-off between
% detail and noise, seen from opposite sides. See
% <DensityEstimation.html Density Estimation>.
%
%% Maps, grains and boundaries
%
% *notIndexed* - the phase given to a measurement whose pattern could not
% be indexed. A recorded value, not missing data, and a connected patch of
% it can form a grain of its own.
%
% *Grain* - a connected, phase-homogeneous region of measurements whose
% orientations agree to within a threshold. There is no canonical
% definition; the threshold is a convention. See <Grains.html Grains>.
%
% *Grain boundary* - the segment between two neighbouring measurements
% that fell in different grains. *Phase boundary* - not a separate kind of
% object, just a grain boundary whose two grains differ in phase.
%
% *Hole* and *inclusion* - one grain lying entirely within another, seen
% from outside and from inside. The same fact, not two.
%
% *Chain* - a run of boundary segments laid end to end between two
% junctions. *Junction* - a vertex where the number of meeting segments is
% anything other than two. *Triple point* - a junction where exactly three
% segments meet and they separate three distinct grains, so it is a strict
% subset of the junctions. See <TriplePoints.html Triple Points>.
%
% *KAM* - kernel average misorientation, the average orientation
% difference between a measurement and its neighbours. *GROD* - grain
% reference orientation deviation, the difference between a measurement and
% its own grain's mean. See <EBSDKAM.html KAM> and
% <EBSDGROD.html Mis2Mean / GROD>.
%
%% Material response
%
% *Slip system* - a lattice plane together with a direction in it, along
% which a crystal shears plastically. *Schmid factor* - the geometric
% factor relating applied stress to the shear stress resolved onto a slip
% system, between 0 and 0.5. See <Plasticity.html Plasticity>.
%
% *Taylor* and *Sachs* models - the assumptions that every grain undergoes
% the same strain, and that every grain feels the same stress. They bound
% the real behaviour from above and below, and are the plastic counterparts
% of the Voigt and Reuss bounds in <Tensors.html Tensors>.
%
% *GND* - geometrically necessary dislocations, the dislocation content
% implied by a gradient of orientation within a grain. See
% <GND.html GND>.
%
%% Next
%
% The conventions behind these terms - Euler angles, frames, units and the
% direction a rotation acts in - are collected in
% <NotationAndConventions.html Notation and Conventions>.
%
