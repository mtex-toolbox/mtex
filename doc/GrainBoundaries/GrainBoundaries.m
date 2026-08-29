%% Grain Boundaries
%
%% From grains to a boundary network
%
% A *grain* is a phase-homogeneous, spatially connected region of EBSD
% pixels produced by segmentation.
% Begin this chapter after <GrainReconstruction.html Grain Reconstruction>
% has divided a map into those regions.
%
% The interface between two grains often matters as much as either grain.
% Its character influences how a material fractures and corrodes.
% It also affects how readily an atom or dislocation crosses the interface.
%
% MTEX represents a grain boundary as short segments. Each segment lies
% between neighbouring measurements that were assigned to different grains.
% One <grainBoundary.grainBoundary.html |grainBoundary|> object holds the
% whole segment list, and its methods act across that list.
% The segments have properties; they are not decoration drawn over the grains.

close all;

% load and crop the example map in its specimen plotting frame
plottingConvention.default('y↑→x');
mtexdata forsterite silent
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% reconstruct and smooth the grains
grains = calcGrains(ebsd('indexed'),'angle',10*degree);
grains = smoothBoundary(grains,5);

% display the boundary list
gB = grains.boundary

% draw the grains, boundary network, and strict triple points
plot(grains,'noBoundary','micronbar','off')
hold on
plot(gB,'lineWidth',1.5)
plot(grains.triplePoints,'color','r','MarkerSize',4)
hold off

%% Reading the boundary object and figure
% The displayed summary groups the segments by the phases on their two
% sides. Each row reports a segment count and the total trace length.
% |notIndexed| normally denotes pixels whose patterns could not be indexed.
% In this indexed-only example, a |notIndexed| side in that table marks the
% outer scan rim, where no neighbouring grain exists beyond the map.
%
% The coloured regions in the figure are grains, and the black lines are
% their boundary network. The red markers are *triple points*.
% A *junction* is a vertex where the number of meeting segments is not two.
% A triple point is a junction where exactly three segments meet and separate
% three distinct real grains.
% They are not merely places where two plotted lines cross.
%
% At equilibrium, the angles at a triple point reflect interfacial force
% balance.
% That balance depends on the relative energies and their anisotropy.
% A junction therefore carries information that no single segment does.
% A two-dimensional section also depends on how the specimen was cut.
% Its angles are not a direct energy measurement without equilibrium and
% section-geometry assumptions.
%
%% Five macroscopic parameters
%
% Describing a grain boundary completely at a macroscopic scale takes five
% independent parameters.
% Three specify the misorientation between the two crystal lattices.
% Two specify the direction of the interface-plane normal.
% Boundaries with the same misorientation but different planes are different
% interfaces and can behave differently.
%
% A polished two-dimensional section supplies four of these five parameters.
% The crystal orientations give the misorientation, while the boundary
% *trace* gives the line where the interface plane meets the section.
% The inclination of that plane remains unknown, because a trace is
% consistent with any plane that contains it.
%
% <EBSD3Analysis.html 3D EBSD> can resolve the plane of an individual
% interface.
% From two-dimensional data, <BoundaryNormalDistribution.html Boundary Normal
% Distribution> estimates a population of plane orientations from many traces.
% It does not recover the missing inclination of every individual segment.
%
%% Boundary categories are queries, not new classes
%
% A *phase boundary* is not a separate type of object in MTEX.
% It is a grain boundary whose two neighbouring grains differ in phase.
% Selecting phase boundaries is a query on the same |grainBoundary| list.
%
% A phase change always separates neighbouring pixels into different grains.
% For one phase, the usual one-threshold reconstruction separates neighbours
% whose misorientation exceeds the segmentation angle.
% Their segments appear in |grains.boundary|.
% A two-threshold reconstruction can also preserve lower-angle walls within
% grains in |grains.innerBoundary|.
%
% A *low-angle boundary* is defined by its misorientation angle. A *subgrain
% boundary* lies inside a grain. The two populations usually overlap, but
% they are not synonyms. Subgrain boundaries are real features, commonly
% dislocation walls, and an analysis of grain outlines alone cannot see them.
%
%% Recommended reading order
%
% Follow the order in the chapter contents.
% Begin with <BoundarySelect.html Select>.
% It filters the boundary list by phase, grain, or property.
% <BoundaryPlots.html Plot> then colours those selected segments by scalar,
% directional, or full-misorientation data.
%
% <BoundaryProperties.html Properties> introduces two-sided IDs, length,
% direction, and the network connections of each segment.
% Read it before <BoundaryMisorientations.html Misorientations>.
% That page develops the relationship across a segment and the reference
% frame of its misorientation axis.
%
% <SubGrainBoundaries.html Subgrain Boundaries> comes next because it explains
% the two thresholds used by <TiltAndTwistBoundaries.html Twist and Tilt>.
% The latter compares the misorientation axis with the boundary trace, the
% classic physical distinction between tilt, twist, and mixed character.
% <CSLBoundaries.html CSL> then introduces coincidence site lattice
% relationships. At such a relationship, the lattices share some sites.
% Coincidence is a geometric classification.
% It does not by itself guarantee a low-energy boundary.
% Some boundaries with low $\Sigma$ values and suitable planes are nevertheless
% especially low in energy.
%
% The geometry route begins with <BoundaryCurvature.html Curvature>, which
% shows why a pixel staircase cannot be interpreted as a smooth interface.
% <GrainSmoothing.html Smoothing> explains the measurement decision.
% <GrainSmoothingAdvanced.html Smoothing Algorithms> compares the filters.
% Raw staircases corrupt length, direction, and curvature.
% Smoothing is therefore not cosmetic, but it moves the boundary.
% The method and smoothing scale are analysis decisions.
%
% <TwinningBoundaries.html Twinning> returns to crystallographic character
% and infers a repeated twin relationship from a real microstructure.
% Twins are a special boundary population that dominates many materials.
%
% <TriplePoints.html Triple Points> and
% <QuadruplePoints.html Quadruple Points> treat the network junctions.
% Exact four-way contacts are generally unstable in a physical
% two-dimensional network. On a square measurement grid they also arise as
% a digital-connectivity ambiguity during segmentation.
% An apparent four-way contact may therefore represent two physical triple
% points that the section or segmentation has placed at the same location.
%
% <BoundaryIntersections.html Intersections> treats the network as geometry
% crossed by a test line.
% Finish with <BoundaryNormalDistribution.html Distribution>, which estimates
% boundary-plane populations.
% That page also assumes the kernel-density ideas introduced in
% <DensityEstimation.html Density Estimation>.
%
%% References
%
% * A. P. Sutton and R. W. Balluffi,
% <https://obnb.uk/p11642002-interfaces-in-crystalline-materials Interfaces in Crystalline Materials>, Clarendon Press, 1995.
% This textbook develops interface structure, thermodynamics, and kinetics.
% * F. Bachmann, R. Hielscher, and H. Schaeben,
% <https://doi.org/10.1016/j.ultramic.2011.08.002 Grain Detection from 2d and 3d EBSD Data - Specification of the MTEX Algorithm>, _Ultramicroscopy_ 111 (2011), 1720--1733.
% This paper derives the reconstructed boundary network.
% * A. P. Sutton, E. P. Banks, and A. R. Warwick,
% <https://doi.org/10.1098/rspa.2015.0442 The Five-Dimensional Parameter Space of Grain Boundaries>, _Proceedings of the Royal Society A_ 471 (2015), 20150442.
% This paper separates misorientation from plane orientation.
% * D. M. Saylor, B. S. El-Dasher, B. L. Adams, and G. S. Rohrer,
% <https://doi.org/10.1007/s11661-004-0147-z Measuring the Five-Parameter Grain-Boundary Distribution from Observations of Planar Sections>, _Metallurgical and Materials Transactions A_ 35 (2004), 1981--1989.
% * G. S. Rohrer,
% <https://doi.org/10.1007/s10853-011-5677-3 Grain Boundary Energy Anisotropy: A Review>, _Journal of Materials Science_ 46 (2011), 5881--5895.
% This review relates the five parameters and junction geometry to energy.
%
%% Next
%
% The regions separated here are introduced in <Grains.html Grains>, and the
% lattice relationships across them in <Misorientations.html Misorientations>.
% Selected relationships created by a solid-state transformation feed into
% <PhaseTransitions.html Phase Transitions>.
%
% The next top-level chapter is <EBSD3Analysis.html 3D EBSD>. Its interface
% faces supply the inclination that a two-dimensional boundary trace lacks.

%#ok<*NOPTS>
