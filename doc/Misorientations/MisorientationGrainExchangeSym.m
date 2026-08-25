%% Grain Exchange Symmetry
%
% A <MisorientationTheory.html misorientation> maps crystal coordinates of
% one crystal into those of another. For grains of the *same* phase, neither
% side of their shared boundary is intrinsically first. Swapping the grains
% replaces the misorientation by its inverse, but it does not describe a
% different boundary, and no measurement can tell the two apart.
%
% This identification is *grain exchange symmetry*. It is a symmetry of an
% unordered pair of grains, not an additional symmetry of either crystal.
% MTEX records it in the |antipodal| property of a misorientation.
%
% The name is shared with the flag that identifies opposite directions,
% described in <VectorsAxes.html Axes and Antipodal Symmetry>. For a vector
% it means that $\mathbf{v}$ and $-\mathbf{v}$ are equivalent. For a
% misorientation it means that $m$ and $m^{-1}$ are equivalent.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('622');

%% Without Grain Exchange Symmetry
%
% Start with a $40^\circ$ misorientation and compare it with its inverse.
% The |antipodal| property is initially false, so the order of the two
% crystals matters.

mori = orientation.byAxisAngle(Miller(1,2,-3,1,cs),40*degree,cs,cs);

angle(mori,inv(mori)) ./ degree

%%
% The two descriptions are about $14.1^\circ$ apart after crystal symmetry
% has been applied. They are therefore distinct when MTEX treats the pair as
% ordered. That is the right answer between two different phases, where
% "first" and "second" mean something - the parent and the child of a
% transformation, say.
%
% In axis--angle coordinates, inversion keeps the rotation angle and
% reverses the axis. The two markers below consequently occupy opposite
% points on the upper and lower hemispheres.

axMori = axis(mori,'noSymmetry');
axInverse = axis(inv(mori),'noSymmetry');

plot(axMori,'complete','MarkerSize',12,'DisplayName','m',...
  'figSize','small')
hold on
plot(axInverse,'complete','MarkerSize',12,'DisplayName','inverse(m)')
hold off
legend('show','Location','southoutside');

%%
% The blue and orange points are antipodal: they mark the same $40^\circ$
% angle about opposite axes. Grain exchange symmetry will identify this
% pair; it will not change the stored rotation.
%
% Point group |622| has 12 proper rotations. Acting from both crystal frames
% gives $12 \times 12 = 144$ symmetrically equivalent descriptions for this
% ordered pair.

numEquivalentOrdered = length(mori.symmetrise)

%% With Grain Exchange Symmetry
%
% Set |antipodal| when the grain order is arbitrary.

mori.antipodal = true;

angle(mori,inv(mori)) ./ degree

%%
% The symmetry-aware distance is now zero because the inverse belongs to the
% same equivalence class. This does not say that the misorientation is the
% identity; its rotation angle is still $40^\circ$.
%
% For this generic example, <orientation.symmetrise.html |symmetrise|> now
% includes the inverse of every crystal-symmetry equivalent. The displayed
% list therefore doubles from 144 to 288 descriptions.

numEquivalentUnordered = length(mori.symmetrise)

%% The Fundamental Region Becomes Smaller
%
% A <OrientationFundamentalRegion.html fundamental region> keeps one
% representative of each equivalence class. Adding grain exchange symmetry
% identifies each misorientation with its inverse, so fewer representatives
% are needed.

orderedRegion = fundamentalRegion(cs,cs);
exchangeRegion = fundamentalRegion(cs,cs,'antipodal');

plot(orderedRegion,'boundaryColor',[0.2 0.4 0.8],...
  'noSurface','figSize','small')
hold on
plot(exchangeRegion,'boundaryColor',[0.85 0.3 0.1],'noSurface')
hold off

%%
% The blue outline is the region for an ordered pair. The orange outline is
% the region after inverse misorientations have been identified. It has half
% the volume, and here it lies inside the blue one. The number of faces is
% not a measure of region size.

%% Where MTEX Sets the Flag Automatically
%
% A grain is a phase-homogeneous, spatially connected region of EBSD pixels
% produced by segmentation. See <GrainReconstruction.html grain
% reconstruction> for that step. Boundary misorientations between grains of
% one phase receive grain exchange symmetry automatically.

mtexdata twins silent

grains = calcGrains(ebsd,'threshold',5*degree,'minPixel',5);

grains.boundary('Mag','Mag').misorientation.antipodal

%%
% Between two phases, the phase labels distinguish the source and target
% crystal frames. Reversing a forsterite-to-enstatite mapping gives an
% enstatite-to-forsterite mapping, so MTEX leaves the flag off.

mtexdata forsterite silent

grains = calcGrains(ebsd);

grains.boundary('Fo','En').misorientation.antipodal

%%
% The same distinction applies inside one grain. A misorientation between
% the grain mean and an orientation measured within that grain has a fixed
% reference and target, so |antipodal| belongs off. See
% <GrainOrientationParameters.html Grain Orientation Parameters> for this
% grain-reference orientation deviation.

%% Why Swapping Gives the Inverse
%
% Let $g_1$ and $g_2$ be orientations that map the two crystal frames into
% the specimen frame. The misorientation of the ordered pair maps crystal 2
% coordinates into crystal 1,
%
% $$m_{12} = g_1^{-1}g_2.$$
%
% Swapping the grains reverses the composition:
%
% $$m_{21} = g_2^{-1}g_1 = m_{12}^{-1}.$$
%
% The algebra always gives the inverse. Grain exchange symmetry identifies
% the two results only when the grain pair is physically unordered and both
% grains have the same phase.

%% References
%
% * A. Morawiec, <https://doi.org/10.1007/978-3-662-09156-2 Orientations
% and Rotations: Computations in Crystallographic Textures>, Springer,
% 2004, develops rotation-space geometry and crystalline-interface symmetry.
% * S. Patala and C. A. Schuh,
% <https://doi.org/10.3970/cmc.2010.017.001 Topology of Homophase Grain
% Boundaries in Two-Dimensional Crystals: The Role of Grain Exchange
% Symmetry>, _Computers, Materials & Continua_ 17 (2010), 1--18, develops
% the topological consequences of indistinguishable adjoining grains.
% * R. Krakow _et al._,
% <https://doi.org/10.1098/rspa.2017.0274 On Three-Dimensional
% Misorientation Spaces>, _Proceedings of the Royal Society A_ 473 (2017),
% 20170274, shows how grain exchange symmetry halves a same-phase
% misorientation fundamental zone.

%% Next
%
% Continue with <Twinning.html Twinning>, where same-phase boundary
% misorientations are compared with an ideal orientation relationship. The
% geometric effect of the flag is developed further in
% <OrientationFundamentalRegion.html Fundamental Region>, and its effect on
% populations appears in <AxisDistributionFunction.html Axis Distribution>.

%#ok<*NOPTS>
