%% Grains
%
%%
% An orientation map tells you what the crystal lattice is doing at every
% measured point. It does not tell you where one crystal ends and the next
% one begins. Grain reconstruction draws those borders: neighbouring
% measurements whose lattices point in nearly the same direction are
% grouped into one region, and the result is a list of objects you can
% count, measure and compare.
%
% This changes the question you are able to ask. A map of a million
% measurements becomes a few thousand grains, each with a size, a shape, a
% mean orientation and a list of neighbours. "How large are the grains?",
% "are they elongated, and along which direction?", "which grain touches
% which?" only become answerable once the borders exist.
%
% Here is the whole idea in one picture. The colours are the measured
% orientations; the black lines are the borders that reconstruction found.

plottingConvention.default('y↑→x');
mtexdata forsterite silent

% restrict the map to a subregion of interest
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% group neighbouring measurements into grains
grains = calcGrains(ebsd('indexed'),'threshold',10*degree);

plot(ebsd('Forsterite'),ebsd('Forsterite').orientations,'micronbar','off')
hold on
plot(grains.boundary,'lineWidth',1.5)
hold off

%%
% Notice that the borders are not free-hand curves. Every one of them runs
% between two neighbouring measurement points, which is why they look
% stepped when you zoom in far enough, and why smoothing them is a separate
% decision rather than part of the reconstruction.
%
%% The words used in this chapter
%
% *Grain* - a connected region of measurements that belong to one phase and
% whose orientations agree to within a threshold. A change of phase between
% two neighbouring pixels is always a border, so a grain never spans two
% phases.
%
% *notIndexed* - the phase given to a measurement whose diffraction pattern
% could not be indexed. It behaves like any other phase, so a connected
% patch of it can form a grain of its own. It is not a hole in the data.
%
% *Grain boundary* - the segment between two neighbouring measurements that
% ended up in different grains. Boundaries are objects in their own right,
% with their own properties, and they have
% <GrainBoundaries.html a chapter of their own>.
%
% *Hole* and *inclusion* - one grain lying entirely inside another. Seen
% from the outside the enclosing grain has a hole; seen from the inside the
% enclosed grain is an inclusion. These are one fact described from two
% sides, not two separate things.
%
%% Where to start
%
% Read <GrainReconstruction.html Reconstruction> first. It explains the
% threshold that decides what counts as one grain, and what to do about
% measurements that were never indexed - the two choices that shape
% everything computed afterwards.
%
% With grains in hand, <GrainSpatialPlots.html Plot> covers how to display
% them and <SelectingGrains.html Select> how to pick out the ones you care
% about, by size, by phase, by position or by orientation.
%
% The measuring pages come next, and they differ in what they take a grain
% to be. <ShapeParameters.html Shape Parameters> covers the direct
% measurements - area, perimeter, diameter. The three that follow each fit
% a simpler object to the grain and measure that instead:
% <EllipseBasedParameters.html an ellipse>,
% <HullBasedParameters.html a convex hull>, or
% <ProjectionBasedParameters.html a set of projections>. Which one is right
% depends on the shape you expect. <GrainOrientationParameters.html
% Orientation Parameters> and <Grain_dispersion_axes.html Dispersion Axes>
% leave shape aside and describe the orientations inside a grain instead -
% its mean, and how far the measurements scatter around it.
%
% <GrainNeighbours.html Neighbours> and <GrainMerge.html Merge> treat the
% grains as a network rather than as a list, which is what you need when
% grains have to be combined - across a twin boundary, for instance.
%
% Two further reconstruction methods are described separately, for cases
% where the threshold approach struggles:
% <GrainReconstructionAdvanced.html Advanced Reconstruction> and
% <GrainReconstructionMCL.html Markovian Clustering>.
%
% Finally, <GrainExport.html Export> writes grains out for use elsewhere,
% and <NeperInterface.html Neper Interface> connects them to
% polycrystal generation.
%
%% Next
%
% Grains come from an orientation map, so <EBSDAnalysis.html EBSD> is the
% chapter before this one. Their borders are the subject of
% <GrainBoundaries.html Grain Boundaries>, and the orientations they
% contain are described statistically in <ODFAnalysis.html ODF>.
%
