%% Low-Level Parent Phase Reconstruction
%
% This page rebuilds the triple-point workflow from
% <TriplePointBasedReconstruction.html Triple-Point-Based Parent Phase
% Reconstruction> with low-level functions. It exposes the candidate variant
% IDs, vote counts, grain-ID remapping, and per-pixel parent calculation that
% the |parentGrainReconstructor| normally manages.
%
% Use this route when you need to inspect or replace one of those operations.
% For a routine reconstruction, the higher-level workflow is shorter and less
% vulnerable to inconsistent bookkeeping.

mtexdata alphaBetaTitanium

alphaName = 'Ti (alpha)';
betaName = 'Ti (Beta)';

plot(ebsd(alphaName),ebsd(alphaName).orientations,'figSize','large')

%%
% The preceding page measures the same 99.8% alpha and 0.2% beta phase
% fractions and explains what to notice in this map. It also defines the
% Burgers OR and the required parent-to-child direction. We reuse that OR
% without redefining it here.

beta2alpha = orientation.Burgers(...
  ebsd(betaName).CS,ebsd(alphaName).CS)

%% Segment grains for triple-point analysis
%
% The preceding page defines a triple point and explains why this workflow
% uses a 1.5-degree segmentation threshold with
% <QuadruplePoints.html |removeQuadruplePoints|>.
% We add one boundary-smoothing iteration while keeping the triple points
% attached to the boundary network.

[grains,ebsd] = calcGrains(ebsd,'threshold',1.5*degree,...
  'removeQuadruplePoints');
grains = smoothBoundary(grains,1,'moveTriplePoints');

region = [299 401 440 500];
plot(ebsd(alphaName),ebsd(alphaName).orientations,...
  'region',region,'micronbar','off','figSize','large')

hold on
plot(grains.boundary,'lineWidth',2,'region',region)
hold off

%%
% The black lines show how finely the 1.5-degree threshold partitions the
% alpha map. Each former four-way junction is now a pair of three-segment
% junctions. Smoothing has turned the network into free-form polygons, so
% those pairs are not something to pick out by eye here; the next step
% counts them instead.

%% Compute two parent candidates at every triple point
%
% Extract only alpha-alpha-alpha triple points. The high-level
% |calcTPVotes| call performed this phase selection internally.

tP = grains.triplePoints(alphaName,alphaName,alphaName)

%%
% <calcParent.html |calcParent|> tests the three mean alpha orientations at
% each point against all Burgers variants. The |'id'| flag returns variant
% IDs instead of parent orientations. The |'numFit',2| option retains the
% best and second-best combinations.

tPori = grains(tP.grainId).meanOrientation;
[tripleParentId,tripleFit] = calcParent(tPori,beta2alpha,...
  'numFit',2,'id','threshold',5*degree);

tripleFitQuantiles = quantile(tripleFit(:,1)./degree,...
  [0.25 0.5 0.75])

hold on
plot(tP,tripleFit(:,1)./degree,'MarkerEdgeColor','k',...
  'MarkerSize',10,'region',region)
setColorRange([0,5])
mtexColorMap('LaboTeX')
mtexColorbar('title','best fit (degrees)')
hold off

%%
% The first fit is the largest pairwise mismatch among the three candidate
% parent orientations, reported in radians by |calcParent| and converted to
% degrees here. Its quartiles are 1.156, 1.531, and 2.038 degrees.
% The colour map runs from white at zero to dark red at five degrees, so the
% palest markers are the triples compatible with one beta orientation and
% the dark ones are the misfits the next section rejects.

%% Reject ambiguous triple points
%
% Keep a triple point when its best fit is below 2.5 degrees and its
% second-best fit is above 2.5 degrees. This low-level example uses the same
% value on both sides of the decision. The preceding high-level page imposed
% a wider ambiguity gap by requiring its second-best fit to exceed 5 degrees.

consistentTP = tripleFit(:,1) < 2.5*degree & ...
  tripleFit(:,2) > 2.5*degree;
numConsistentTriplePoints = nnz(consistentTP)

hold on
plot(tP(consistentTP),'MarkerEdgeColor','r','MarkerSize',10,...
  'MarkerFaceColor','none','lineWidth',2,'region',region)
hold off

%%
% Red circles mark 54,868 retained seeds. Many survive even though the
% best-fit cutoff is sharp. The next check asks whether a grain receives
% compatible variant IDs from all of its retained triple points.

%% Require consistent votes within each child grain
%
% Each retained triple point casts one variant-ID vote for each of its three
% grains. <majorityVote.html |majorityVote|> with |'strict'| returns an ID only
% when every vote received by that grain is identical. Conflicting grains
% receive |NaN|.

[seedParentId,numVotes] = majorityVote(...
  tP(consistentTP).grainId,tripleParentId(consistentTP,:,1),...
  max(grains.id),'strict');

%%
% |numVotes| is the number of agreeing triple-point votes, not the number of
% unique IDs. Requiring |numVotes>2| therefore means at least three votes.

hasSeed = numVotes > 2;
numSeedGrains = nnz(hasSeed)

parentGrains = grains;
parentGrains(hasSeed).meanOrientation = variants(beta2alpha,...
  grains(hasSeed).meanOrientation,seedParentId(hasSeed));
parentGrains = parentGrains.update;

ipfKey = ipfColorKey(ebsd(betaName));
ipfKey.ipfDirection = vector3d.Y;

parentColor = ipfKey.orientation2color(...
  parentGrains(betaName).meanOrientation);
plot(parentGrains(betaName),parentColor,'figSize','large')

%%
% The vote requirement transforms 26,828 child grains into coloured beta
% fragments. Their footprints still follow the original alpha boundaries
% because no merge has occurred.

%% Reject isolated seeds before merging
%
% As an additional consistency check, require every proposed parent component
% to contain at least two measured child grains. A test run of
% <grain2d.merge.html |merge|> returns the proposed old-to-new grain IDs
% without modifying the map.

[~,trialMergeId] = merge(parentGrains,'threshold',2.5*degree,...
  'testRun');
trialComponentSize = accumarray(trialMergeId,1);

setBack = trialComponentSize(trialMergeId) < 2 & hasSeed;
numIsolatedSeeds = nnz(setBack)

parentGrains(setBack).meanOrientation = grains(setBack).meanOrientation;
parentGrains = parentGrains.update;

%%
% Only the seeded grains can be set back, so |hasSeed| restricts the test to
% them. This check reverts the 9 seeds that would have stood alone and leaves
% 26,819 of the 26,828 in place. It can be omitted when independent
% single-grain parents are plausible.

%% Merge the accepted seed fragments
%
% Neighbouring beta fragments within 2.5 degrees are now merged. The returned
% |seedMergeId| maps every original grain to its current grain ID.

[parentGrains,seedMergeId] = merge(parentGrains,...
  'threshold',2.5*degree);
numSeedParentGrains = length(parentGrains(betaName))

%%
% The EBSD map needs the same ID change. A connected notIndexed area can be a
% grain, so all pixels must be remapped rather than only indexed pixels.
% The leading zero preserves pixels whose grain ID is zero.

parentEBSD = ebsd;
old2new = [0;seedMergeId];
parentEBSD.grainId = old2new(1 + ebsd.grainId);

parentColor = ipfKey.orientation2color(...
  parentGrains(betaName).meanOrientation);
plot(parentGrains(betaName),parentColor,'figSize','large')

%%
% Compatible fragments now form 114 beta-grain footprints. Remaining alpha
% grains are candidates for growth from a reconstructed neighbour.

%% Find alpha grains next to reconstructed beta grains
%
% <grain2d.neighbors.html |neighbors|> returns the IDs of neighbouring alpha
% and beta grains. For every pair, |calcParent| compares the measured alpha
% orientation with the reconstructed beta orientation.

grainPairs = neighbors(parentGrains(alphaName),parentGrains(betaName));

oriAlpha = parentGrains(grainPairs(:,1)).meanOrientation;
oriBeta = parentGrains(grainPairs(:,2)).meanOrientation;

[pairParentId,pairFit] = calcParent(oriAlpha,oriBeta,beta2alpha,...
  'numFit',2,'id');

pairFitQuantiles = quantile(pairFit(:,1)./degree,[0.25 0.5 0.75])

%%
% The first returned ID selects the alpha variant compatible with its beta
% neighbour. Its fit quartiles are 0.966, 1.427, and 2.129 degrees.
% The second fit exposes whether that choice is unambiguous.

%% Transform alpha grains supported by boundary pairs
%
% The executable criterion keeps pairs whose best fit is below 5 degrees and
% whose second-best fit is above 5 degrees. Earlier prose and its threshold
% summary called this a 2.5-degree step, but that did not match the code.

consistentPairs = pairFit(:,1) < 5*degree & ...
  pairFit(:,2) > 5*degree;
numConsistentPairs = nnz(consistentPairs)

%%
% Here |majorityVote| is used without |'strict'|. An alpha grain with
% conflicting neighbours therefore takes its most frequent candidate rather
% than being rejected outright.

growthParentId = majorityVote(grainPairs(consistentPairs,1),...
  pairParentId(consistentPairs,1),max(parentGrains.id));

hasGrowthVote = ~isnan(growthParentId);
numGrownAlphaGrains = nnz(hasGrowthVote)

parentGrains(hasGrowthVote).meanOrientation = variants(beta2alpha,...
  parentGrains(hasGrowthVote).meanOrientation,...
  growthParentId(hasGrowthVote));
parentGrains = parentGrains.update;

[parentGrains,growthMergeId] = merge(parentGrains,...
  'threshold',5*degree);

old2new = [0;growthMergeId];
parentEBSD.grainId = old2new(1 + parentEBSD.grainId);

remainingAlphaPercent = 100 * sum(parentGrains(alphaName).numPixel) ./ ...
  sum(parentGrains.numPixel)

parentColor = ipfKey.orientation2color(...
  parentGrains(betaName).meanOrientation);
plot(parentGrains(betaName),parentColor,'lineWidth',2,...
  'figSize','large')

%%
% Of 16,251 consistent pairs, the majority vote transforms 16,205 alpha
% grains. The unreconstructed alpha area is then 1.207%.
% Repeating the pair-vote step with gradually increasing thresholds can grow
% the reconstruction further, but each relaxation also accepts weaker fits.
%
% The original page also proposed treating the remaining alpha grains as
% noise and replacing them during denoising. The closing denoising step below
% fills only sites with missing orientations; indexed alpha pixels remain
% alpha unless they are first removed from the map.

%% Reconstruct a beta orientation at each transformed pixel
%
% The grain means are beta orientations, but the EBSD pixels still store their
% measured alpha orientations. Select original alpha pixels whose remapped
% grain now has the beta phase.

isNowBeta = parentGrains.phaseId(...
  max(1,parentEBSD.grainId(:))) == ebsd.name2id(betaName) & ...
  parentEBSD.phaseId(:) == ebsd.name2id(alphaName);

%%
% The |(:)| conversions are essential on a gridded map. Per-pixel properties
% have the map shape, while the stored |phaseId| is a column. Flattening both
% prevents an unintended row-by-column comparison.
%
% With a measured child orientation and a reconstructed parent grain,
% <calcParent.html |calcParent|> returns the compatible beta orientation and
% its angular fit.

[parentEBSD(isNowBeta).orientations,pixelFit] = calcParent(...
  parentEBSD(isNowBeta).orientations,...
  parentGrains(parentEBSD(isNowBeta).grainId).meanOrientation,...
  beta2alpha);

pixelFitQuantiles = quantile(pixelFit./degree,[0.5 0.9 0.99])

plot(parentEBSD(isNowBeta),pixelFit./degree,'figSize','large')
mtexColorbar('title','fit (degrees)')
setColorRange([0,5])
mtexColorMap('LaboTeX')

hold on
plot(parentGrains.boundary,'lineWidth',2)
hold off

%%
% The median pixel fit is 1.183 degrees, 90% are below 2.087 degrees, and 99%
% are below 3.209 degrees. Low values indicate agreement with the Burgers
% variant predicted by the beta grain. The boundary overlay shows whether
% high fits concentrate near reconstructed grain edges.

parentColor = ipfKey.orientation2color(...
  parentEBSD(betaName).orientations);
plot(parentEBSD(betaName),parentColor,'figSize','large')

%%
% The beta pixel map follows the merged parent footprints while preserving
% intra-grain orientation variation that was absent from the grain-mean map.

%% Denoise the reconstructed beta phase
%
% Segment the current parent map at 5 degrees and mark indexed grains smaller
% than 15 pixels as notIndexed. Five smoothing iterations regularize the
% retained boundaries.

[parentGrains,parentEBSD] = calcGrains(parentEBSD,...
  'angle',5*degree,'minPixel',15);
parentGrains = smoothBoundary(parentGrains,5);

%%
% A <halfQuadraticFilter.html |halfQuadraticFilter|> with a small |alpha|
% preserves more local detail. The |'fill'| option interpolates missing
% orientations inside the supplied grain boundaries.

F = halfQuadraticFilter;
F.alpha = 0.1;
parentEBSD = smooth(parentEBSD,F,'fill',parentGrains);

parentColor = ipfKey.orientation2color(...
  parentEBSD(betaName).orientations);
plot(parentEBSD(betaName),parentColor,'figSize','large')

hold on
plot(parentGrains.boundary,'lineWidth',3)
hold off

%%
% The filter reduces pixel-scale colour variation without blurring across the
% supplied grain boundaries. It can fill small grains that |minPixel| changed
% to notIndexed, but it does not overwrite larger indexed alpha grains.

%% Compare the final boundaries with the measured child map
%
% Return to the measured alpha orientations and overlay the reconstructed
% grain boundaries.

plot(ebsd(alphaName),ebsd(alphaName).orientations,'figSize','large')

hold on
plot(parentGrains.boundary,'lineWidth',3,'lineColor','white')
hold off

%%
% The white outlines should enclose groups of related alpha colours.
% Boundaries that cut through a visually coherent group are candidates for
% revisiting the vote or merge thresholds.

%% Read the intra-grain orientation structure
%
% The final diagnostic colours every beta pixel by the axis and angle of its
% misorientation from the mean orientation of its grain.

betaPixels = parentEBSD(betaName);
betaMean = parentGrains(betaPixels.grainId).meanOrientation;
mis2MeanDegree = angle(betaPixels.orientations,betaMean)./degree;
mis2MeanQuantiles = quantile(mis2MeanDegree,[0.5 0.9 0.99])

cKey = axisAngleColorKey;
deviationColor = cKey.orientation2color(...
  betaPixels.orientations,betaMean);
plot(betaPixels,deviationColor,'figSize','large')

hold on
plot(parentGrains.boundary,'lineWidth',3)
hold off

%%
% The median deviation from the grain mean is 1.160 degrees, 90% are below
% 2.054 degrees, and 99% are below 3.147 degrees. Colour changes inside a
% boundary reveal structure that an IPF map of grain means would hide.
% Large coherent deviations can indicate deformation or an over-merged grain.

%% Thresholds used on this page
%
% * Initial child-grain segmentation: 1.5 degrees.
% * Best triple-point fit: below 2.5 degrees.
% * Second-best triple-point fit: above 2.5 degrees.
% * Strict seed support: at least three agreeing votes.
% * Seed-fragment merge: below 2.5 degrees and at least two child grains per
% proposed parent component. The merge may be skipped if the separate
% fragments are needed.
% * Parent-child pair fit and growth merge: 5 degrees.
%
% The earlier summary listed a minimum of two consistent votes and a
% 2.5-degree alpha-beta threshold. The executable conditions are three votes
% and 5 degrees, respectively.

%% References
%
% * F. Niessen, T. Nyyssönen, A. A. Gazder, and R. Hielscher,
% <https://doi.org/10.1107/S1600576721011560 Parent grain reconstruction
% from partially or fully transformed microstructures in MTEX>, _Journal
% of Applied Crystallography_ 55 (2022), 180-194, gives the parent-candidate,
% voting, transformation, and merging framework implemented manually here.

%% Next
%
% Continue with <MaParentGrainReconstructionAdvanced.html Advanced Low-Level
% Parent Grain Reconstruction> to apply low-level candidate fitting and graph
% clustering to a martensitic steel map.
