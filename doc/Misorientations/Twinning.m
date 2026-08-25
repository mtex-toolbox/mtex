%% Twinning
%
%%
% A *twin law* is a special crystallographic orientation relationship
% between parts of the same crystal species. Growth, transformation, and
% deformation twins arise by different processes. Each repeats one discrete
% lattice relationship.
%
% MTEX represents the rotational part of a twin law as a same-phase
% misorientation. This page constructs an ideal twin law, explains why its
% quoted angle depends on crystal symmetry, and compares it with an EBSD map.
%
% Start with <MisorientationTheory.html Theory of Misorientations> if
% symmetry-equivalent misorientations and disorientation are unfamiliar.
% The treatment of an unordered pair of same-phase grains is introduced in
% <MisorientationGrainExchangeSym.html Grain Exchange Symmetry>.

plottingConvention.default('y↑→x');
mtexdata twins silent

% use the crystal symmetry and lattice parameters stored with the data
CS = ebsd('Magnesium').CS;

%% Constructing an Ideal Twin Relationship
%
% A rotation is fixed by two non-parallel correspondences. For the
% magnesium extension twin, choose a parent plane normal and direction.
% Their counterparts describe the same features in the twin.

parentPlane = Miller(1,-1,0,1,CS);
twinPlane = Miller(1,0,-1,-1,CS);
parentDirection = Miller(0,1,-1,1,CS,'uvw');
twinDirection = Miller(1,-1,0,1,CS,'uvw');

% map the parent correspondences onto the twin correspondences
twinning = orientation.map(parentPlane,twinPlane,...
  parentDirection,twinDirection);

%%
% <orientation.round2Miller.html |round2Miller|> recovers one low-index
% description of the relationship. Crystal symmetry permits several equally
% valid descriptions. The reported indices therefore need not repeat the
% input representatives.

round2Miller(twinning)

%% Seeing the Reorientation
%
% The same hexagonal crystal shape can represent the parent and the twin.
% The twin law rotates the orange copy while leaving its lattice and shape
% unchanged.

cS = crystalShape.hex(CS);

close all;
plot(cS,'FaceColor','LightSkyBlue','FaceAlpha',0.55,'figSize','large');
hold on;
plot(0.9 * (twinning * cS),'FaceColor','orange','FaceAlpha',0.55);
hold off;
view(35,20);

%%
% The two prisms have the same faces and proportions. Their discrete
% relative placement is the orientation relationship; the picture does not
% show the shear or the plane of their physical interface.

%% Why 86.3 Degrees and 180 Degrees Are Both Correct
%
% A twin law is an equivalence class of rotations under crystal symmetry.
% <orientation.angle.html |angle|> returns the smallest-angle representative
% by default, while the |max| option returns the largest-angle representative.

twinAngles = [angle(twinning),angle(twinning,'max')] ./ degree

%%
% The magnesium extension twin therefore has a disorientation angle of
% $86.299^\circ$, but the same twin law also has a $180^\circ$ representative.
% A textbook using the 180 degree description and MTEX reporting 86.3
% degrees are not in conflict.
%
% The rotation axis changes with the representative as well. Always state
% which representative and crystal frame an axis belongs to.
% <AxisDistributionFunction.html Axis Distribution> develops this
% distinction for populations of misorientations.

%% Comparing the Twin Law with Measured Boundaries
%
% A grain is a phase-homogeneous, spatially connected region of EBSD pixels
% produced by segmentation. The map is segmented at $5^\circ$, and grains
% with fewer than five indexed pixels are excluded. Boundary geometry is
% then smoothed for five iterations before trace lengths are compared.

grains = calcGrains(ebsd('indexed'),'angle',5*degree,'minPixel',5);
grains = smoothBoundary(grains,5);

% retain only boundaries between magnesium grains
gB = grains.boundary('Magnesium','Magnesium');

%%
% A same-phase boundary is unordered. Marking the ideal relationship as
% antipodal makes its inverse equivalent. This is the grain exchange
% symmetry required for the comparison.

twinBoundaryRelation = twinning;
twinBoundaryRelation.antipodal = true;

% compare the complete misorientation with the ideal relationship
twinDeviation = angle(gB.misorientation,twinBoundaryRelation) ./ degree;

close all;
histogram(twinDeviation,0:2:90);
xlabel('deviation from ideal twin (degree)');

%%
% The strong concentration near zero is the repeated extension-twin
% relationship. Comparing only boundary angles near 86.3 degrees would
% discard the axis information and can admit unrelated boundaries.

%% Candidate Twin Boundaries
%
% A five degree tolerance selects candidate boundaries in this example.
% The tolerance is an analyst choice, not a universal property of the twin
% law, and should reflect orientation uncertainty and the scientific aim.

isCandidate = twinDeviation < 5;

% weight the result by boundary trace length rather than segment count
candidateTracePercent = 100 * sum(gB(isCandidate).segLength) ...
  ./ sum(gB.segLength)

%%
% With this segmentation, smoothing, and tolerance, candidates account for
% about 49 percent of the magnesium-to-magnesium boundary trace length.

close all;
plot(grains,grains.meanOrientation,'ipfDirection',zvector,...
  'micronbar','off');
hold on;
plot(gB(isCandidate),'linecolor','w','linewidth',3);
hold off;

%%
% The white traces follow the thin lamellae in the orientation map. This
% spatial agreement supports the crystallographic classification.
%
% A misorientation match alone does not prove a twinning mechanism. A full
% boundary description also needs the interface-plane orientation.
% A two-dimensional EBSD map measures only its trace. Morphology, loading,
% and other evidence may also be needed.
% <TwinningBoundaries.html Twinning Analysis> infers a relationship from
% measured boundaries and inspects the selected traces.

%% References
%
% * Th. Hahn and H. Klapper,
% <https://doi.org/10.1107/97809553602060000644 Twinning of Crystals>,
% _International Tables for Crystallography_, Vol. D, ch. 3.3, pp. 393--448,
% 2006. This chapter treats twin laws, morphology, origins, and interfaces.
% * J. W. Christian and S. Mahajan,
% <https://doi.org/10.1016/0079-6425(94)00007-7 Deformation Twinning>,
% _Progress in Materials Science_ 39 (1995), 1--157. This review covers
% twinning shear, modes, and deformation mechanisms.
% * Y. Zhang _et al._, <https://doi.org/10.1107/S0021889810037180 A General
% Method to Determine Twinning Elements>, _Journal of Applied
% Crystallography_ 43 (2010), 1426--1430. This paper connects measured
% orientation relationships with classical twinning elements.

%% Next
%
% A single ideal relationship appears as a peak in a population.
% <MisorientationDistributionFunction.html Misorientation Distribution
% Function> compares correlated boundary misorientations with the
% uncorrelated distribution expected from texture.
%
% The same distinction reduced to rotation angle alone is developed in
% <AngleDistributionFunction.html Angle Distribution>. Twin laws between
% parent and product phases lead into <PhaseTransitions.html Phase
% Transitions>.

%#ok<*NOPTS>
