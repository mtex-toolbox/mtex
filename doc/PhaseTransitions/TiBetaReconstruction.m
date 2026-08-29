%% Parent Beta Phase Reconstruction in Titanium Alloys
%
% This page reconstructs the former beta-grain map of a titanium alloy from
% a nearly complete alpha-phase EBSD map. It continues the Burgers-variant
% example in <ParentChildVariants.html Parent and Child Variants> and uses
% the reconstruction ideas prepared by
% <MartensiteVariants.html Martensite Variants>.

mtexdata alphaBetaTitanium

% Plot the measured alpha phase with inverse pole figure colours.
plot(ebsd('Ti (alpha)'),ebsd('Ti (alpha)').orientations,...
  'figSize','large')

%%
% The map contains 99.8% alpha titanium and 0.2% beta titanium among its
% indexed measurements. The goal is to recover the original beta phase.

phaseFraction = 100 .* ...
  [length(ebsd('Ti (alpha)')),length(ebsd('Ti (beta)'))] ./ ...
  length(ebsd('indexed'))

%%
% The former beta-grain structure is almost visible by eye. Groups of alpha
% regions with related colours form larger blocks, but colour alone does
% not decide which regions came from the same beta grain.

%% Set the parent-to-child relationship
%
% We use the Burgers OR introduced on the first page. It aligns a beta
% $(110)$ plane with an alpha $(0001)$ plane and a beta $[1\bar{1}1]$
% direction with an alpha $[\bar{2}110]$ direction.

beta2alpha = orientation.Burgers(...
  ebsd('Ti (beta)').CS,ebsd('Ti (alpha)').CS)

%%
% Every parent grain reconstruction method expects the OR in the
% parent-to-child direction. Passing its inverse would make all candidate
% parent orientations wrong even though their number still looked
% plausible.

%% Segment the child grains
%
% A grain is a phase-homogeneous, spatially connected region of EBSD pixels
% produced by segmentation. A small angular threshold keeps alpha regions
% from different beta grains separate at this stage.

[grains,ebsd] = calcGrains(ebsd,'threshold',1.5*degree,...
  'removeQuadruplePoints');

%%
% The 1.5-degree threshold is deliberately small. If two alpha orientations
% from different beta grains were merged now, reconstruction could not
% separate them later.

%% Set up the reconstruction job
%
% A <parentGrainReconstructor.parentGrainReconstructor.html
% |parentGrainReconstructor|> stores the input, the current reconstruction,
% and the relation between them. Assigning |p2c| tells it which phase is the
% parent and which phase is the child.

job = parentGrainReconstructor(ebsd,grains);
job.p2c = beta2alpha

%%
% The displayed |job| summary reports the current parent and child grain
% counts, areas, and reconstructed fraction. The most useful properties
% are grouped below.
%
% * |job.grainsPrior| and |job.ebsdPrior| preserve the input grains and EBSD
% data.
% * |job.grains| and |job.ebsd| expose the current grains and reconstructed
% EBSD data.
% * |job.mergeId| maps each input grain |job.grainsPrior(ind)| to the current
% grain |job.grains(job.mergeId(ind))|.
% * |job.numChilds| counts the input grains represented by each current
% grain.
% * |job.parentGrains| and |job.childGrains| select the current parent and
% child grains.
% * |job.isTransformed| marks input child grains assigned a parent
% orientation.
% * |job.isMerged| marks input grains that have been combined into a current
% grain.
% * |job.transformedGrains| selects the input child grains with a computed
% parent orientation.
%
% The class also provides several reconstruction routes and cleanup
% operations.
%
% * <parentGrainReconstructor.calcVariantGraph.html |calcVariantGraph|>
% constructs a variant graph.
% * <parentGrainReconstructor.clusterVariantGraph.html
% |clusterVariantGraph|> converts graph clusters into parent votes.
% * <parentGrainReconstructor.calcGBVotes.html |calcGBVotes|> obtains votes
% from child-child and parent-child grain boundaries.
% * <parentGrainReconstructor.calcTPVotes.html |calcTPVotes|> obtains votes
% from child-child-child triple points.
% * <parentGrainReconstructor.calcParentFromVote.html
% |calcParentFromVote|> transforms grains selected by votes.
% * <parentGrainReconstructor.calcParentFromGraph.html
% |calcParentFromGraph|> transforms and merges graph clusters.
% * <parentGrainReconstructor.mergeSimilar.html |mergeSimilar|> merges
% neighbouring parent grains with similar orientations.
% * <parentGrainReconstructor.mergeInclusions.html |mergeInclusions|> merges
% small enclosed grains into parent hosts.
%
% These operations can be repeated while refining a reconstruction. They
% are not arbitrary in order: graph clustering needs a graph, and
% vote-based transformation needs votes.

%% Build the variant graph
%
% A *variant graph* has one node for every combination of child grain and
% candidate parent variant. Its edges connect compatible candidate variants
% of neighbouring grains.
%
% <parentGrainReconstructor.calcVariantGraph.html |calcVariantGraph|>
% converts angular fit into edge probability. Here 1.5 degrees is the
% misfit at which the default probability model gives an edge weight of
% one half.

job.calcVariantGraph('threshold',1.5*degree)

%% Cluster candidate variants
%
% <parentGrainReconstructor.clusterVariantGraph.html
% |clusterVariantGraph|> propagates compatibility through the graph. Three
% iterations produce probabilities for the candidate parents of each child
% grain.

job.clusterVariantGraph('numIter',3)

%%
% The rows of |job.votes.prob| contain the candidate probabilities. The
% matching columns of |job.votes.parentId| contain their parent-variant IDs.
% The first column is the highest-ranked candidate for each grain.

%% Transform child grains to candidate parents
%
% *Transform* is the first reconstruction step. Each selected child grain
% is assigned one candidate parent orientation and changes from the child
% phase to the parent phase.
%
% <parentGrainReconstructor.calcParentFromVote.html
% |calcParentFromVote|> accepts the highest-probability candidate here.

job.calcParentFromVote

reconstructedFraction = 100 * nnz(job.isTransformed) ./ ...
  nnz(job.grainsPrior.phaseId == job.childPhaseId)

%%
% At this stage, 96.10% of the input child grains have parent orientations.
%
% The displayed fraction reaches 99% after the inclusion cleanup below.
% Neighbouring candidates have not yet all been merged into their shared
% beta-grain footprints.

% Define a beta-phase IPF colour key.
ipfKey = ipfColorKey(ebsd('Ti (Beta)'));
ipfKey.ipfDirection = vector3d.Y;

% Plot the transformed beta grains.
parentColor = ipfKey.orientation2color(...
  job.parentGrains.meanOrientation);
plot(job.parentGrains,parentColor,'figSize','large')

%%
% The map now contains many small regions with almost identical colours.
% Those regions are compatible parent candidates that still need the merge
% step.

%% Merge similar parent grains
%
% *Merge* is the second reconstruction step. Neighbouring transformed
% grains with compatible parent orientations are combined into one grain
% footprint.
%
% <parentGrainReconstructor.mergeSimilar.html |mergeSimilar|> uses an
% angular threshold. Here neighbours within 5 degrees are treated as one
% parent grain.

job.mergeSimilar('threshold',5*degree)

parentColor = ipfKey.orientation2color(...
  job.parentGrains.meanOrientation);
plot(job.parentGrains,parentColor,'figSize','large')

%%
% The many similarly coloured fragments have coalesced into a small number
% of large beta grains. Their remaining enclosed specks require a separate
% topological cleanup.

%% Merge small inclusions
%
% An inclusion is a grain entirely enclosed by another grain. Some small
% child grains remain as inclusions because no parent orientation was
% assigned to them confidently.
%
% <parentGrainReconstructor.mergeInclusions.html |mergeInclusions|> merges
% inclusions of at most 10 pixels into their surrounding parent grains.

job.mergeInclusions('maxSize',10)

parentColor = ipfKey.orientation2color(...
  job.parentGrains.meanOrientation);
plot(job.parentGrains,parentColor,'figSize','large')

%%
% The large parent-grain shapes remain, while the small enclosed fragments
% no longer interrupt them. This operation changes topology rather than
% choosing another orientation variant.

%% Reconstruct a parent orientation at every pixel
%
% So far, parent orientations have been stored as grain means.
% <parentGrainReconstructor.calcParentEBSD.html |calcParentEBSD|> transfers
% the reconstruction to an EBSD variable and assigns a parent orientation
% to every transformed child pixel.

parentEBSD = job.calcParentEBSD;

parentColor = ipfKey.orientation2color(...
  parentEBSD('Ti (Beta)').orientations);
plot(parentEBSD('Ti (Beta)'),parentColor,'figSize','large')

%%
% The pixel map is piecewise consistent with the reconstructed grain map.
% It can now be analysed with ordinary EBSD tools while retaining the
% reconstructed beta phase and parent grain IDs.

%% Check the per-pixel reconstruction fit
%
% |parentEBSD.fit| is a per-pixel property. It is the angular mismatch
% between the measured alpha orientation and the child variant predicted
% from its reconstructed beta-grain orientation.

fitDegree = parentEBSD('Ti (Beta)').fit ./ degree;
fitQuantiles = quantile(fitDegree(~isnan(fitDegree)),[0.5 0.9 0.99])

plot(parentEBSD,parentEBSD.fit ./ degree,'figSize','large')
mtexColorbar
setColorRange([0,5])
mtexColorMap('LaboTeX')

hold on
plot(job.grains.boundary,'lineWidth',2)
hold off

%%
% Low values indicate pixels consistent with the assigned Burgers variant.
% The median is 1.19 degrees, 90% are below 2.10 degrees, and 99% are below
% 3.58 degrees.
%
% The black outlines show whether larger mismatches collect at reconstructed
% parent boundaries rather than filling a grain interior.

%% Compare reconstructed boundaries with the child map
%
% The final plot returns to the measured alpha orientations. White lines
% show the smoothed reconstructed beta-grain boundaries.

plot(ebsd('Ti (Alpha)'),ebsd('Ti (Alpha)').orientations,...
  'figSize','large')

hold on
parentGrains = smoothBoundary(job.parentGrains,5);
plot(parentGrains.boundary,'lineWidth',3,'lineColor','White')
hold off

%%
% The white boundaries enclose the large alpha-variant groups that were
% only hinted at by colour in the first map. The overlay is the final visual
% check that graph compatibility recovered the structure visible by eye.

%% References
%
% * F. Niessen, T. Nyyssönen, A. A. Gazder, and R. Hielscher,
% <https://doi.org/10.1107/S1600576721011560 Parent grain reconstruction
% from partially or fully transformed microstructures in MTEX>, _Journal
% of Applied Crystallography_ 55 (2022), 180-194, defines the generic MTEX
% reconstruction framework and the |parentGrainReconstructor| class.
% * R. Hielscher, T. Nyyssönen, F. Niessen, and A. A. Gazder,
% <https://doi.org/10.1016/j.mtla.2022.101399 The variant graph approach to
% improved parent grain reconstruction>, _Materialia_ 22 (2022), 101399,
% gives the graph construction and clustering algorithm used here.

%% Next
%
% Continue with <MaParentGrainReconstruction.html Parent Austenite
% Reconstruction> for a steel workflow that first fits the OR and then
% combines variant-graph reconstruction with further cleanup strategies.
