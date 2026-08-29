%% Martensite Parent Grain Reconstruction
%
% This page reconstructs prior austenite grains from a martensite EBSD map.
% It continues the workflow introduced in
% <TiBetaReconstruction.html Parent Beta Phase Reconstruction>.
% Here the orientation relationship (OR) must first be fitted to the steel.
%
% The worked sequence has four stages: fit the OR, choose parent variants,
% merge compatible grains, and transfer the result back to the pixel map.

plottingConvention.default('y↑→x');
mtexdata martensite

%% Segment the measured martensite
%
% A grain is a phase-homogeneous, spatially connected region of EBSD pixels
% produced by segmentation. A 3-degree threshold separates the child grains.
% Grains with fewer than two pixels are removed during segmentation.

[grains,ebsd] = calcGrains(ebsd,'angle',3*degree,...
  'minPixel',2,'alpha',12);

plot(ebsd('Iron bcc'),ebsd('Iron bcc').orientations,...
  'figSize','large')
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%%
% The orientation colours form groups inside larger, former austenite
% regions. The black lines show the deliberately fine child-grain partition.
% Reconstruction must decide which neighbouring child grains share a parent.

%% Set up the reconstruction job
%
% A <parentGrainReconstructor.parentGrainReconstructor.html
% |parentGrainReconstructor|> stores the input and the current reconstruction.
% It also records how each measured child grain maps to a recovered parent.

job = parentGrainReconstructor(ebsd,grains);

%%
% The constructor guesses the parent and child phases from their populations.
% Supply an OR as the third constructor argument if that guess is wrong.
% In this fully transformed sample, we instead set the phase symmetries by
% assigning an initial parent-to-child OR after construction.

job.p2c = orientation.KurdjumovSachs(job.csParent,job.csChild)

%%
% The displayed summary reports parent and child grain counts, their areas,
% and the fraction of input child grains already transformed.
% It also reports four quintiles of the boundary OR misfit. For the initial
% Kurdjumov-Sachs (KS) guess these are 2.51, 3.49, 4.41, and 5.35 degrees,
% as printed below.

%% Fit the parent-to-child orientation relationship
%
% A real austenite-to-martensite transformation does not follow one ideal OR
% exactly. The OR should therefore be fitted for each sample.
% <parentGrainReconstructor.calcParent2Child.html |calcParent2Child|>
% implements the iterative method proposed by Nyyssönen and co-workers.
% It starts from the KS guess and fits the child-to-child misorientations.

initialFit = job.calcGBFit ./ degree;
fitQuantilesInitial = quantile(initialFit,[0.2 0.4 0.6 0.8])

% a line plot must not reuse the map figure - its axes leaves no room for labels
close all
histogram(initialFit,'BinMethod','sqrt','EdgeColor','auto')
hold on

job.calcParent2Child

optimizedFit = job.calcGBFit ./ degree;
fitQuantilesOptimized = quantile(optimizedFit,[0.2 0.4 0.6 0.8])
histogram(optimizedFit,'BinMethod','sqrt','EdgeColor','auto')
xlabel('disorientation angle (degrees)')
legend('initial KS OR','fitted OR')
hold off

%%
% The fitted OR is 2.5 degrees from the ideal Nishiyama-Wassermann OR.
% Its first misfit quintile is 1.3 degrees, rather than 2.5 degrees.
% The fitted histogram is therefore shifted towards smaller disorientations.
%
% The earlier version of this page said that |calcParent2Child| stored these
% values in |job.fit|. The current class has no such property.
% Use <parentGrainReconstructor.calcGBFit.html |calcGBFit|> to recompute them.
% The fit assumes that most measured boundaries are child-to-child boundaries.

%% Map the boundary misfit
%
% |calcGBFit| returns one fit for every child-grain neighbour pair.
% <grainBoundary.selectByGrainId.html |selectByGrainId|> selects all boundary
% segments belonging to those pairs.

[fit,c2cPairs] = job.calcGBFit;
[gB,pairId] = job.grains.boundary.selectByGrainId(c2cPairs);

plot(ebsd('Iron bcc'),ebsd('Iron bcc').orientations,...
  'figSize','large','faceAlpha',0.5)
hold on
plot(gB,'edgeAlpha',(fit(pairId)./degree-2.5)./2,...
  'lineWidth',2)
hold off

%%
% Transparency converts the angular fit to a boundary diagnostic.
% Opaque segments have larger misfit, while faint segments better match the
% fitted OR. Spatial clusters of opaque segments deserve scrutiny before the
% reconstruction parameters are relaxed.

%% Build the variant graph
%
% A *variant* is one crystallographically equivalent child orientation
% predicted from a single parent orientation through the known OR.
% A *variant graph* has one node per child-grain and candidate-variant pair.
% Edges connect compatible candidates belonging to neighbouring grains.
%
% <parentGrainReconstructor.calcVariantGraph.html |calcVariantGraph|>
% converts angular misfit into an edge weight.
% The |threshold| is the misfit whose weight is one half.
% The |tolerance| controls the width of the transition from high to low weight.
% Earlier text called |tolerance| a Gaussian standard deviation, but the
% implementation uses it directly as the transition-width parameter.

job.calcVariantGraph('threshold',3.5*degree,...
  'tolerance',3.5*degree)

%%
% Earlier versions also passed |'tortuosity'| here.
% |calcVariantGraph| has no such option, so MATLAB silently ignored it.
% The graph above uses only the documented threshold and tolerance options.
%
% Large maps can reduce the first graph by grouping similarly oriented
% variants, then separate them in a second pass:
%
%   job.calcVariantGraph('threshold',2.5*degree,...
%     'tolerance',2.5*degree,'mergeSimilar')
%   job.clusterVariantGraph
%   job.calcVariantGraph('threshold',2.5*degree,...
%     'tolerance',2.5*degree)
%
% This two-pass route trades variant resolution in the first graph for lower
% cost. The present map is small enough to retain every variant immediately.

%% Cluster candidate variants
%
% <parentGrainReconstructor.clusterVariantGraph.html
% |clusterVariantGraph|> propagates compatibility through the graph.
% The |includeSimilar| option lets candidates within 5 degrees share support.

job.clusterVariantGraph('includeSimilar')

%%
% The result is the table |job.votes|.
% Row |i| of |job.votes.prob| ranks the candidate probabilities for grain |i|.
% The matching entries in |job.votes.parentId| identify those candidates.
% The first column is the best-supported candidate.

plot(job.grains,job.votes.prob(:,1))
mtexColorbar

%%
% Large uniform values mark grains with a clear parent assignment.
% Values near 0.5 indicate at least two similarly plausible parents.
% Such ambiguity often occurs when the candidates are related by twinning.

%% Transform the confident child grains
%
% *Transform* is the first parent grain reconstruction step.
% Each selected child grain receives one candidate parent orientation and
% changes from the child phase to the parent phase.
% Here only best candidates with probability above 0.5 are accepted.

job.calcParentFromVote('minProb',0.5)

plot(job.parentGrains,job.parentGrains.meanOrientation)

%%
% The map contains transformed parent fragments rather than final parent
% grain footprints. The strict vote transforms 10,581 child grains,
% leaving 64 child grains that occupy 0.59% of the indexed area.
% A manual alternative is
% <parentGrainReconstructor.selectInteractive.html |selectInteractive|>:
%
%   job.selectInteractive
%
% It lets a reader click a grain and choose among its candidate parents.
% It is not executed here because a published page must run without clicks.

%% Reconsider uncertain grains from their neighbours
%
% A second variant-graph pass with relaxed probabilities is one route.
% Here <parentGrainReconstructor.calcGBVotes.html |calcGBVotes|> instead asks
% the already reconstructed neighbours to vote for potential parents.
% |reconsiderAll| also permits an earlier assignment to be replaced.

job.calcGBVotes('p2c','reconsiderAll','threshold',4*degree,...
  'tolerance',1.5*degree)

job.calcParentFromVote

plot(job.parentGrains,job.parentGrains.meanOrientation)

%%
% Earlier versions passed |'tortuosity'| to |calcGBVotes| as well.
% That function also has no such option, so it had no effect.
% The new parent fragments fill much of the space left by the strict vote.
% It leaves 48 child grains, occupying 0.088% of the indexed area.

%% Merge compatible parent fragments
%
% *Merge* is the second parent grain reconstruction step.
% Neighbouring transformed grains with compatible parent orientations are
% combined into one parent-grain footprint.
% <parentGrainReconstructor.mergeSimilar.html |mergeSimilar|> uses a
% 7.5-degree threshold here.

job.mergeSimilar('threshold',7.5*degree);
job.grains = smoothBoundary(job.grains,20);

plot(job.parentGrains,job.parentGrains.meanOrientation)

%%
% The similarly coloured fragments have coalesced into larger parent grains.
% Small enclosed child grains still interrupt some of those footprints.

%% Merge small inclusions
%
% An inclusion is a grain entirely enclosed by another grain.
% Some poorly indexed child grains remain as inclusions because no parent
% orientation could be assigned confidently.
% <parentGrainReconstructor.mergeInclusions.html |mergeInclusions|> merges
% inclusions of at most 50 pixels into the surrounding parent grain.

job.mergeInclusions('maxSize',50);

plot(job.parentGrains,job.parentGrains.meanOrientation)

%%
% The large parent-grain shapes remain, while small enclosed fragments no
% longer break them up. This operation changes topology rather than choosing
% another parent variant.

%% Identify variants and packets
%
% Once the parent orientations are known,
% <parentGrainReconstructor.calcVariants.html |calcVariants|> classifies each
% transformed child grain. |variantId| is its finest crystallographic class.
% A *packet* groups variants that share the parent {111} habit plane.
% In this reconstruction, |packetId| selects the parent {111} plane closest
% to the martensite (011) plane.

job.calcVariants

color = ind2color(job.transformedGrains.packetId);
plot(job.transformedGrains,color,'faceAlpha',0.5)

hold on
parentGrains = smoothBoundary(job.parentGrains,10);
plot(parentGrains.boundary,'lineWidth',3)

grainSelected = parentGrains(parentGrains.findByLocation([100,80]));
plot(grainSelected.boundary,'lineWidth',3,...
  'lineColor','w')
hold off

%%
% Equal colours identify child grains in the same packet.
% Thick black lines show reconstructed parent boundaries.
% The white outline selects one parent grain for a closer crystallographic
% check.

%% Trace the selected parent back to its children
%
% |job.grainsPrior| preserves the grains before reconstruction.
% For every input grain, |job.mergeId| stores the ID of its current parent.
% Combining them selects all children of the outlined parent grain.

childGrains = job.grainsPrior(...
  job.mergeId == grainSelected.id);

selectedParentId = grainSelected.id

plot(childGrains,childGrains.meanOrientation)
hold on
plot(grainSelected.boundary,'lineWidth',2)
hold off

%%
% The original page described this grain as parent 279.
% The printed |selectedParentId| checks that concrete ID against the current
% segmentation. It is 288 in the current run, showing why IDs should not be
% assumed to remain fixed across releases.
% The child-grain mosaic exactly fills the selected parent outline.

%% Check the selected parent's crystallography
%
% <calcVariantId.html |calcVariantId|> independently assigns variant and
% packet IDs to every measured child orientation inside the selected parent.

childOri = job.ebsdPrior(childGrains).orientations;
parentOri = grainSelected.meanOrientation;
[variantId,packetId] = calcVariantId(parentOri,childOri,job.p2c);

color = ind2color(packetId);
plotPDF(childOri,color,Miller(0,0,1,childOri.CS),...
  'MarkerSize',2,'all')

hold on
plot(parentOri.symmetrise * Miller(0,0,1,parentOri.CS),...
  'markerSize',10,'marker','s','markerFaceColor','w',...
  'markerEdgeColor','k','lineWidth',2)

childVariants = variants(job.p2c,parentOri);
plotPDF(childVariants,'markerFaceColor','none','lineWidth',1.5,...
  'markerEdgeColor','k')
hold off

%%
% Coloured points are measured child orientations, grouped by packet.
% Black open markers are the theoretical variants of the reconstructed parent.
% Their agreement tests the reconstruction inside one grain rather than only
% checking the final boundary shapes.

%% Reconstruct the parent EBSD map
%
% The reconstruction so far used grain means.
% <parentGrainReconstructor.calcParentEBSD.html |calcParentEBSD|> assigns a
% parent orientation to each transformed pixel in the original EBSD map.

parentEBSD = job.calcParentEBSD;

plot(parentEBSD('Iron fcc'),parentEBSD('Iron fcc').orientations,...
  'figSize','large')

%%
% The reconstructed pixel colours follow the parent-grain partition.
% Remaining blank pixels were not assigned a parent orientation.

%% Check the per-pixel reconstruction fit
%
% |parentEBSD.fit| is the angular mismatch between the parent orientation
% reconstructed from one pixel and the orientation assigned to its grain.

plot(parentEBSD,parentEBSD.fit./degree,'figSize','large')
mtexColorbar
setColorRange([0,5])
mtexColorMap('LaboTeX')

hold on
plot(job.grains.boundary,'lineWidth',2)
hold off

%%
% Low values show pixels consistent with the reconstructed parent grain.
% The black boundaries reveal whether larger fits concentrate at parent-grain
% edges or occupy a grain interior.

%% Fill the parent map
%
% Some pixels remain notIndexed or not reconstructed.
% We first segment the reconstructed parent map and smooth its boundaries.

[parentGrains,parentEBSD] = calcGrains(parentEBSD,...
  'angle',3*degree,'minPixel',10);
parentGrains = smoothBoundary(parentGrains,20);

plot(ebsd,ebsd.orientations,'figSize','large')
hold on
plot(parentGrains.boundary,'lineWidth',2)
hold off

%%
% The outlines define the parent regions that constrain the fill operation.
% <EBSD.smooth.html |smooth|> then fills holes without crossing those outlines.

F = halfQuadraticFilter;
parentEBSD = smooth(parentEBSD,F,'fill',parentGrains);

plot(parentEBSD('Iron fcc'),parentEBSD('Iron fcc').orientations,...
  'figSize','large')
hold on
plot(parentGrains.boundary,'lineWidth',2)
hold off

%%
% The filled map is continuous inside each reconstructed parent grain.
% The boundaries still preserve the grain partition used during filtering.

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
% * T. Nyyssönen, M. Isakov, P. Peura, and V.-T. Kuokkala,
% <https://doi.org/10.1007/s11661-016-3462-2 Iterative determination of the
% orientation relationship between austenite and martensite from a large
% amount of grain pair misorientations>, _Metallurgical and Materials
% Transactions A_ 47 (2016), 2587-2590, gives the OR-fitting method.

%% Next
%
% Continue with <TransformationTexture.html Transformation Texture> to use
% a parent-to-child OR to predict how a parent ODF transforms into child
% variants and how variant selection changes the resulting texture.
