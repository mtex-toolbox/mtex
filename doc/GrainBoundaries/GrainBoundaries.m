%% Grain Boundaries
%
%%
% Once a map has been divided into grains, the interesting part is often
% not the grains but what lies between them. A grain boundary is where two
% crystals meet, and its character - how the two lattices are related, and
% which way the interface faces - controls a great deal of how the material
% behaves: how it fractures, how it corrodes, how easily an atom or a
% dislocation crosses.
%
% In a map, a boundary is a set of short segments, each lying between two
% neighbouring measurements that ended up in different grains. Those
% segments are objects with their own properties, not decoration drawn on
% top of the grains.

plottingConvention.default('y↑→x');
mtexdata forsterite silent

ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));
grains = calcGrains(ebsd('indexed'),'threshold',10*degree);
grains = smoothBoundary(grains,5);

% the boundary network, with the points where three grains meet
plot(grains,'micronbar','off')
hold on
plot(grains.boundary,'lineWidth',1.5)
plot(grains.triplePoints,'color','r','MarkerSize',4)
hold off

%%
% The red points are *triple points*, where three grains meet. They are not
% merely where lines cross: the angles at a triple point are set by the
% relative energies of the three boundaries, so they carry information that
% no single boundary does.
%
%% Five numbers, and how many you can have
%
% Describing an interface completely takes five numbers. Three fix the
% misorientation between the two crystals, and two more fix the direction
% the interface plane faces. Boundaries with the same misorientation but
% different planes are genuinely different objects, and often behave
% differently.
%
% A polished surface gives you the first three and only part of the last
% two. What a map records is the *trace* of the boundary plane - the line
% where it meets the surface - and a trace is consistent with any plane
% containing it. The inclination is unmeasured. Getting the full five needs
% either <EBSD3Analysis.html 3D data> or a statistical argument over many
% boundaries at once, which is what
% <BoundaryNormalDistribution.html Distribution> is for.
%
%% Boundaries are not all the same kind
%
% Two distinctions run through the chapter. A *phase boundary* is not a
% separate type of object - it is simply a boundary whose two grains happen
% to differ in phase, and it is a way of filtering rather than a class of
% its own.
%
% More consequential is the split between high-angle boundaries, which are
% what grain reconstruction produced, and *subgrain* boundaries, whose
% misorientation falls below the threshold and which therefore lie inside
% grains rather than between them. They are real features, usually walls of
% dislocations, and they are invisible to any analysis that only looks at
% grain outlines.
%
%% Where to start
%
% <BoundarySelect.html Select> and <BoundaryPlots.html Plot> come first, and
% between them do most of the routine work: picking out the boundaries
% between two particular phases, or above a misorientation, and colouring
% them by whatever you picked.
%
% <BoundaryProperties.html Properties> and
% <BoundaryMisorientations.html Misorientations> are the measurements -
% length, direction, and the crystallographic relationship across each
% segment.
%
% Then the pages on character.
% <TiltAndTwistBoundaries.html Twist and Tilt> classifies a boundary by how
% the misorientation axis sits relative to the boundary plane, which is the
% oldest and most physical distinction here.
% <CSLBoundaries.html CSL> covers coincidence site lattice relationships,
% where the two lattices share a fraction of their points and the boundary
% is correspondingly low in energy, and
% <TwinningBoundaries.html Twinning> covers the special case that dominates
% many real microstructures.
%
% <SubGrainBoundaries.html Subgrain Boundaries> handles the low-angle
% population described above, and <BoundaryCurvature.html Curvature> and
% <BoundaryIntersections.html Intersections> treat the boundary network as
% geometry.
%
% Two pages concern the junctions rather than the segments:
% <TriplePoints.html Triple Points> and
% <QuadruplePoints.html Quadruple Points>. Four grains meeting at a point is
% unstable in a real microstructure and usually means the segmentation put
% two triple points on top of each other, so it is worth knowing they exist.
%
% Finally, <GrainSmoothing.html Smoothing> and
% <GrainSmoothingAdvanced.html Smoothing Algorithms>. Raw boundaries follow
% the measurement grid and so run in staircases, which corrupts any length,
% direction or curvature computed from them. Smoothing is not cosmetic - but
% it does move the boundary, so how much of it to apply is a real decision.
%
%% Next
%
% The regions these boundaries separate are <Grains.html Grains>. The
% relationships across them are <Misorientations.html Misorientations>.
% Boundaries created by a phase transformation are the subject of
% <PhaseTransitions.html Phase Transitions>.
%
