%% Glossary
%
% This page gives short definitions of terms used throughout the MTEX
% documentation. Each link leads to the page that develops the idea and
% shows how to use it. Terms that are easily confused appear together
% rather than in strict alphabetical order.

%% Commands and stored data
%
% *Command option* and *flag* - controls appended to a command call. An
% option has a name and value, whereas a flag is switched on by its presence.
% See <GeneralConceptsOptions.html Options> for the full calling convention.
%
% *Property* and *scan option* - per-element data in |ebsd.prop| and
% whole-scan data in |ebsd.opt|, respectively. Only a property is indexed
% and subset in lockstep with the map. See <Properties.html Properties> for
% the definition, examples, and the rule for deciding where a value belongs.
%
% *Header* - scan-level information captured from a file's own preamble.
% It includes acquisition settings and vendor bookkeeping, but excludes
% phase and symmetry information already stored in |CSList|. It remains in
% the vendor's native shape, so field names are not normalised across file
% formats. See <EBSDImport.html EBSD Import>.
%
% *|headerOnly|* - an import option for inspecting a large file without
% reading its per-point data. It returns an |EBSD| object with empty
% positions, orientations, and phase ids, but populated |CSList|,
% |phaseMap|, and |opt.header|.

%% Directions, symmetry, and reference frames
%
% *Antipodal* - the flag marking a quantity as an axis rather than a
% direction, so it and its opposite are the same thing. It changes angles,
% means, and densities, and nothing warns you if it is missing. See
% <VectorsAxes.html Axes>.
%
% *Miller indices* - the notation for planes and directions in a lattice.
% Round brackets |(hkl)| name a plane, and square brackets |[uvw]| name a
% direction. Braces |{hkl}| and angle brackets |&lt;uvw&gt;| name the corresponding
% symmetric families. Planes and directions are not interchangeable: in
% quartz, the plane |(100)| and direction |[100]| are 30 degrees apart. See
% <CrystalDirections.html Miller Indices>.
%
% *Point group* - the symmetry operations that leave one point of a lattice
% fixed. There are 32 point groups.
%
% *Space group* - a point group extended by translations. There are 230
% space groups.
%
% *Laue group* - a point group with an inversion centre added. There are 11
% Laue groups, and a diffraction experiment can determine this symmetry.
% See <CrystalSymmetries.html Crystal Symmetries> for all three groups.
%
% *Reference frame* - the frame in which data is expressed. It has an
% identity, a basis, and a default plotting convention. A reference frame
% is distinct from both the symmetry attached to it and the way it is drawn.
%
% *Crystal frame* - the Cartesian reference frame fixed to a phase's lattice
% basis. An alignment such as |X&#124;&#124;a*, Z&#124;&#124;c| belongs to this
% frame, not to its point group.
%
% *Specimen frame* - the frame in which the sample is expressed. Measurement,
% rolling, and geological frames are named specimen frames. Reading a
% quantity in the crystal frame when it was written in the specimen frame,
% or conversely, causes nearly every confusing result. See
% <CrystalReferenceSystem.html Reference System>.
%
% *Symmetry* - the point group under which data is invariant. It is attached
% to a reference frame but is not the frame itself. Two datasets may share a
% symmetry while using differently aligned frames, or share a frame while
% carrying different symmetries.
%
% *Plotting convention* - the layout of a reference frame on screen, such as
% which axis points east and which points out of the screen. The frame
% supplies a default, and a plot may override it. It is not merely a camera
% setting because import may also use its rotation as a frame relation. See
% <AxesAlignment.html Axes Alignment>.
%
% *Frame change* - re-expressing the same physical object in another
% reference frame with |transformReferenceFrame|. The object stays fixed.
% Rotating instead moves the physical object. See
% <CrystalReferenceSystem.html Reference System>.
%
% *Frame-free* - the state of a |vector3d|, |S2Fun|, or |tensor| whose frame
% is empty. Its frame is resolved against the session default when drawn.
% An object that points to the default frame is framed, not frame-free.
%
% *Fundamental sector* - the part of the sphere containing exactly one
% representative of every set of symmetrically equivalent directions. An
% inverse pole figure is drawn on it. See
% <FundamentalSector.html Fundamental Sector>.
%
% *Fundamental region* - the corresponding set of representatives for
% orientations. See <OrientationFundamentalRegion.html Fundamental Region>.

%% Orientations and parent reconstruction
%
% *Orientation* - the rotation that maps the crystal frame to the specimen
% frame. It describes how one crystal is placed in the sample. See
% <CrystalOrientations.html Orientations>.
%
% *Misorientation* - the rotation relating two crystals, independent of the
% specimen frame.
%
% *Disorientation* - the representative of a misorientation with the
% smallest rotation angle. It supplies the number in a phrase such as a
% 60 degree boundary. Symmetry lets many rotations describe the same
% relationship; disorientation selects one. See
% <MisorientationTheory.html Theory>.
%
% *Grain exchange symmetry* - the additional ambiguity for two grains of the
% same phase. Their relationship has no natural direction, so a rotation and
% its inverse describe the same boundary.
%
% *Orientation relationship (OR)* - the crystallographic mapping between a
% parent phase and a child phase.
%
% *Variant* - one crystallographically equivalent child orientation
% predicted from one parent orientation by a known OR. It is the finest
% classification of a reconstructed child grain relative to its parent.
%
% *Packet* - a grouping of variants that share a habit plane. In the usual
% martensite classification, this is the parent {111} plane to which the
% child lattice aligns.
%
% *Bain group* - a grouping of variants by Bain correspondence. It records
% the parent {001} cube-axis plane to which the child lattice aligns. Packet
% and Bain group are independent classifications of the same variants, not
% two levels of one hierarchy. See <PhaseTransitions.html Phase Transitions>.
%
% *Transform* - the first parent-reconstruction step. Each child grain is
% assigned a candidate parent orientation through the OR and changed to the
% parent phase.
%
% *Merge* - the second parent-reconstruction step. Neighbouring transformed
% grains with compatible parent orientations are combined into one grain
% footprint.
%
% *Grain graph* - a reconstruction graph with one node per grain and edges
% for shared grain boundaries. It reasons directly about grain-to-grain
% compatibility.
%
% *Variant graph* - a reconstruction graph with one node for every
% grain-and-candidate-variant pair. Its edges describe compatible candidates
% in neighbouring grains, so it chooses variants before merging. See
% <GrainGraphBasedReconstruction.html Grain Graph Based Reconstruction>.
%
% *Fibre* - all orientations that place one fixed crystal direction along
% one fixed specimen direction. It is a curve in orientation space and a
% common shape for real textures. See <OrientationFibre.html Fibres>.

%% Distributions
%
% *Texture* - a material's departure from a random orientation distribution.
%
% *ODF* - orientation distribution function, the density of material over
% orientations. A single orientation has no volume fraction; a region of
% orientations does. See <ODFAnalysis.html ODF>.
%
% *MRD* - multiples of a random distribution, the unit used for an ODF. A
% value of one everywhere means no texture. A value of 20 means that the
% material near that orientation is twenty times as frequent as randomness
% would predict.
%
% *Pole figure* - the density of one selected crystal direction over specimen
% directions.
%
% *Inverse pole figure* - the reverse density: one selected specimen
% direction over crystal directions. Both figures are projections of an ODF,
% and both lose information. See
% <OrientationPoleFigure.html Pole Figures>.
%
% *Ghost effect* - the ODF error caused by pole figures being insensitive to
% the odd part of the harmonic expansion. It is a genuine gap in what
% diffraction can determine, not a numerical artefact. See
% <PoleFigure2ODFAmbiguity.html The Ghost Effect>.
%
% *Halfwidth* - the angular distance over which each discrete measurement is
% spread during density estimation.
%
% *Bandwidth* - the highest harmonic degree kept in a series representation.
% Halfwidth and bandwidth express the same trade-off between detail and noise
% from opposite sides. See <DensityEstimation.html Density Estimation>.

%% Maps, grains, and boundaries
%
% *notIndexed* - the phase assigned when a measured diffraction pattern
% cannot be indexed. It is a recorded measurement, not missing data. Like
% any phase, a connected notIndexed area can form a grain. A patch narrower
% than the |alpha| closing threshold is absorbed into a neighbouring grain.
% See <EBSDFilling.html Filling Missing Data>.
%
% *Grain* - a phase-homogeneous, spatially connected region of EBSD points
% produced by segmentation. A phase change between neighbours is always a
% boundary. Orientation-based methods commonly require neighbouring
% orientations to agree within a threshold. There is no canonical grain
% definition, so that threshold is a convention. See <Grains.html Grains>.
%
% *Grain boundary* - one segment between neighbouring EBSD points that
% belong to different grains. These atomic segments are stored in walk order.
%
% *Phase boundary* - a grain boundary whose two neighbouring grains have
% different phases. It is a query on grain boundaries, not a separate type.
%
% *Enclosure* - the relationship in which one grain lies entirely inside
% another. From outside, the containing grain has a hole; from inside, the
% contained grain is an inclusion. These are the same fact, and the hole is
% never empty because even a notIndexed patch is a grain.
%
% *Chain* - a maximal run of grain-boundary segments laid end to end. It runs
% from one junction to the next without passing through one. Every segment
% belongs to one chain, and the same two grains lie on its sides throughout.
%
% *Junction* - a vertex where the number of meeting boundary segments is not
% two. It includes outer-map endpoints and points where four segments cross.
%
% *Triple point* - a junction where exactly three segments meet and separate
% three distinct grains. It is a strict subset of junctions; three segments
% meeting at the scanned-area edge do not make a triple point. See
% <TriplePoints.html Triple Points>.
%
% *Closed chain* - a chain that ends where it began. A junction-free enclosed
% grain usually has one, but a chain may also leave a junction and return to
% that same junction. Closed therefore does not mean junction-free.
%
% *Gap* - a run of absent measurements within one scan line, often created by
% selecting one phase before rebuilding the grid. Grid assignment recovers
% its lattice positions; a gap is not a notIndexed measurement.
%
% *Hole in a scan grid* - a connected notIndexed area inside the region that
% was actually scanned. This is distinct from a gap and from a dummy cell.
%
% *Dummy cell* - a synthetic filler cell beyond the scanned edge that bounds
% the spatial decomposition. It has no id, never represents a measurement,
% and never becomes a grain.
%
% *Local deformation model* - the position correction used for gaps, holes,
% and dummy cells on a nonrigid scan grid. MTEX fits an ideal affine grid and
% interpolates measured local deviations into positions without measurements.
% See <EBSDGrid.html Scan Grids>.
%
% *KAM* - kernel average misorientation, the average orientation difference
% between a measurement and its neighbours. See <EBSDKAM.html KAM>.
%
% *GROD* - grain reference orientation deviation, the difference between a
% measurement and its grain's mean orientation. See
% <EBSDGROD.html Mis2Mean / GROD>.

%% Material response
%
% *Slip system* - a lattice plane together with a direction in that plane,
% along which a crystal shears plastically.
%
% *Schmid factor* - the geometric factor relating applied stress to the shear
% stress resolved onto a slip system. It lies between zero and 0.5. See
% <Plasticity.html Plasticity>.
%
% *Taylor model* - the assumption that every grain undergoes the same strain.
% It is the plastic counterpart of the Voigt bound.
%
% *Sachs model* - the assumption that every grain feels the same stress. It
% is the plastic counterpart of the Reuss bound. Taylor and Sachs bound real
% behaviour from above and below. See <Tensors.html Tensors>.
%
% *GND* - geometrically necessary dislocations, the dislocation content
% required by a gradient of orientation within a grain. See <GND.html GND>.

%% References
%
% * H.-J. Bunge,
% <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis in Materials
% Science: Mathematical Methods>, Butterworths, 1982, develops orientation
% distributions, crystallographic symmetry, and the standard texture terms.
%
% * F. Bachmann, R. Hielscher, and H. Schaeben,
% <https://doi.org/10.1016/j.ultramic.2011.08.002 Grain Detection from 2d
% and 3d EBSD Data - Specification of the MTEX Algorithm>,
% _Ultramicroscopy_ 111 (2011), 1720--1733, derives the spatial cells,
% connectivity, grains, and boundaries used by MTEX.
%
% * J. F. Nye,
% <https://doi.org/10.1016/0001-6160(53)90054-6 Some Geometrical Relations in
% Dislocated Crystals>, _Acta Metallurgica_ 1 (1953), 153--162, relates
% lattice curvature to the geometrically necessary dislocation tensor.

%% Next
%
% <NotationAndConventions.html Notation and Conventions> collects the choices
% behind these terms, including angle units, Euler conventions, frame
% direction, and the action of a rotation.
