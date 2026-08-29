%% Advanced Low-Level Parent Grain Reconstruction
%
% This page reconstructs prior austenite from a martensite EBSD map by
% constructing similarity matrices directly. It compares two sources of
% evidence while holding the data and fitted orientation relationship (OR)
% fixed.
%
% The first matrix scores pairs of neighbouring child grains. The second
% scores all three child grains meeting at a triple point. The preceding
% <LowLevelParentGrainReconstruction.html Low-Level Parent Phase
% Reconstruction> explains the manual parent-candidate and grain-ID operations
% reused here.

plottingConvention.default('y↑→x');
mtexdata martensite

%% Segment the measured martensite
%
% Every indexed measurement in this map is bcc martensite. The phase list
% carries an empty fcc slot alongside it, and that slot is where the
% reconstruction writes the austenite it recovers.

csBCC = ebsd.CSList(2);
csFCC = ebsd.CSList(3);

[grains,ebsd] = calcGrains(ebsd,'angle',3*degree,...
  'minPixel',5,'removeQuadruplePoints');

plot(ebsd('Iron bcc'),ebsd('Iron bcc').orientations,...
  'figSize','large')
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%%
% The 3-degree segmentation deliberately divides the martensite into many
% small child grains. This executable version retains grains of at least five
% pixels. The earlier version used two pixels, but its two complete low-level
% graph reconstructions exceeded the page's practical runtime budget.
% Black boundaries inside a coherent colour group are candidates to disappear.

%% Fit the parent-to-child orientation relationship
%
% <MaParentGrainReconstruction.html Parent Austenite Reconstruction> explains
% why the OR must be fitted for each sample. It also introduces the iterative
% method of Nyyssönen and co-workers. Here the ideal Kurdjumov-Sachs (KS) OR
% is the initial parent-to-child guess.

KS = orientation.KurdjumovSachs(csFCC,csBCC);

%%
% The fit uses a two-column matrix of neighbouring child orientations.
% Excluding notIndexed grains keeps both columns in the martensite phase.
% Pairs below 5 degrees are removed because they provide little information
% about distinct transformation variants.

grainPairs = neighbors(grains('Iron bcc'));
pairOri = grains(grainPairs).meanOrientation;
grainPairs(angle(pairOri(:,1),pairOri(:,2)) < 5*degree,:) = [];

[fcc2bcc,boundaryFit] = calcParent2Child(...
  grains(grainPairs).meanOrientation,KS);

changeFromKS = angle(KS,fcc2bcc)./degree
boundaryFitQuantiles = quantile(boundaryFit./degree,...
  [0.2 0.4 0.6 0.8])

%%
% <calcParent2Child.html |calcParent2Child|> assumes that most retained pairs
% are child-to-child boundaries. It adjusts the OR to reduce their mismatch
% from theoretical child-to-child misorientations. The fitted OR is 3.132
% degrees from KS. Its 20th, 40th, 60th, and 80th fit percentiles are 1.483,
% 2.018, 2.613, and 4.207 degrees.

close all
histogram(boundaryFit./degree)
xlabel('disorientation angle (degrees)')
ylabel('grain-pair count')

%%
% The histogram shows the fitted mismatch distribution. Its low-angle mass
% supplies the high-similarity relations used by the first clustering route.

%% Map the boundary evidence
%
% <grainBoundary.selectByGrainId.html |selectByGrainId|> maps each retained
% grain pair to all of its boundary segments.

[gB,pairId] = grains.boundary.selectByGrainId(grainPairs);

plot(ebsd('Iron bcc'),ebsd('Iron bcc').orientations,...
  'figSize','large')
hold on
plot(gB,'lineWidth',3,'lineColor','white')
plot(gB,boundaryFit(pairId)./degree,'lineWidth',2,'smooth')
hold off

mtexColorMap('LaboTeX')
mtexColorbar('title','fit (degrees)')
setColorRange([0,5])

%%
% Low-fit segments are compatible with one austenite parent and may become
% internal boundaries. Large-fit segments join into outlines that are likely
% to remain as reconstructed parent boundaries.

%% Convert boundary fit to similarity
%
% A *grain graph* has one node per grain and an edge for every retained
% neighbour pair. The edge value below converts angular fit $\omega$ to the
% probability-like similarity
%
% $$P(\omega)=1-\frac{1}{2}\left[1+\mathrm{erf}\left(\frac{2(\omega-t)}{s}\right)\right].$$
%
% The threshold $t$ is the fit with similarity one half. The tolerance $s$
% controls the transition width.
% Earlier text called $s$ the Gaussian standard deviation, but the factor of
% two in this explicit model means it is not the standard deviation.

omega = linspace(0,5)*degree;
boundaryThreshold = 2*degree;
boundaryTolerance = 1.5*degree;

close all
plot(omega./degree,1 - 0.5 * (1 + erf(...
  2*(omega-boundaryThreshold)./boundaryTolerance)),...
  'lineWidth',2)
xlabel('fit (degrees)')
ylabel('similarity')

%%
% Fits below 2 degrees receive high similarity, while larger fits fall
% rapidly towards zero. The curve makes the consequences of both parameters
% visible before they are applied to the map.

boundaryProbability = 1 - 0.5 * (1 + erf(...
  2*(boundaryFit-boundaryThreshold)./boundaryTolerance));
boundaryProbabilityQuantiles = quantile(boundaryProbability,...
  [0.1 0.5 0.9])

boundaryA = sparse(grainPairs(:,1),grainPairs(:,2),...
  boundaryProbability,length(grains),length(grains));

%%
% The 10th, 50th, and 90th similarity percentiles are 0, 0.3040, and
% 0.9475. The zero-valued low tail corresponds to badly fitting pairs that
% should not bind a component.

%% Cluster the boundary graph
%
% <mclComponents.html |mclComponents|> applies Markov clustering to the
% similarity matrix. The inflation power controls cluster granularity.
% Larger values separate the graph more aggressively.

boundaryInflationPower = 1.6;
boundaryA = mclComponents(boundaryA,boundaryInflationPower);

%%
% Each resulting component is a candidate parent footprint.
% <grain2d.merge.html |merge|> removes boundaries within a component.

[boundaryParentGrains,boundaryParentId] = merge(grains,boundaryA);
boundaryParentGrains = smoothBoundary(boundaryParentGrains,20);
numBoundaryComponents = length(boundaryParentGrains)

%%
% All pixels, including pixels in connected notIndexed grains, need the same
% old-to-new grain-ID mapping. The leading zero preserves pixels that have no
% grain.

boundaryParentEBSD = ebsd;
old2new = [0;boundaryParentId];
boundaryParentEBSD.grainId = old2new(1 + ebsd.grainId);

plot(ebsd('Iron bcc'),ebsd('Iron bcc').orientations,...
  'figSize','large')
hold on
plot(boundaryParentGrains.boundary,'lineWidth',4,...
  'lineColor','white')
plot(boundaryParentGrains.boundary,'lineWidth',2,...
  'lineColor','black')
hold off

%%
% The graph produces 707 candidate components, shown by the double outlines.
% The components need not have their final size because similarly oriented
% neighbours can be merged after parent orientations are fitted.

%% Fit an austenite orientation to every component
%
% <calcParent.html |calcParent|> fits one common parent orientation to all
% martensite grains in a component. Pixel counts weight larger child grains
% more strongly. Components with fewer than two child grains are left
% unassigned, and fits of 5 degrees or more are rejected.

childGrains = grains('Iron bcc');
childOri = childGrains.meanOrientation;
childComponentId = boundaryParentId(...
  grains.id2ind(childGrains.id));

componentOri = orientation.nan(...
  max(boundaryParentId),1,fcc2bcc.CS);
componentFit = inf(size(componentOri));
weights = childGrains.numPixel;

pC = progressCounter(max(boundaryParentId));
for k = 1:max(boundaryParentId)
  inComponent = childComponentId == k;
  if nnz(inComponent) > 1
    [componentOri(k),componentFit(k)] = calcParent(...
      childOri(inComponent),fcc2bcc,'weights',weights(inComponent));
  end
  pC.show(k);
end

acceptComponent = componentFit < 5*degree;
numAcceptedComponents = nnz(acceptComponent)

boundaryParentGrains(acceptComponent).meanOrientation = ...
  componentOri(acceptComponent);
boundaryParentGrains = boundaryParentGrains.update;

%% Merge similarly oriented parent components
%
% Accepted components have changed from bcc child phase to fcc parent phase.
% A 4-degree merge combines neighbouring fcc components with similar
% orientations and returns a second ID mapping.
% Of the 707 components, 360 pass the child-count and 5-degree fit tests.

numParentsBeforeOrientationMerge = ...
  length(boundaryParentGrains('Iron fcc'))

[boundaryParentGrains,orientationMergeId] = merge(...
  boundaryParentGrains,'threshold',4*degree);

old2new = [0;orientationMergeId];
boundaryParentEBSD.grainId = old2new(...
  1 + boundaryParentEBSD.grainId);

numParentsAfterOrientationMerge = ...
  length(boundaryParentGrains('Iron fcc'))

plot(boundaryParentGrains('Iron fcc'),...
  boundaryParentGrains('Iron fcc').meanOrientation,...
  'figSize','large')

%%
% The orientation merge reduces 360 accepted components to 222 fcc parent
% grains. Their colours identify the reconstructed parent orientations.
% Neighbours with similar colours have coalesced into larger footprints.

%% Classify child variants and packets
%
% <MaParentGrainReconstruction.html Parent Austenite Reconstruction> defines
% variants and packets. Here <calcVariantId.html |calcVariantId|> classifies
% each child against its component orientation. For this OR, |packetId|
% selects the parent {111} plane closest to martensite (011).

[variantId,packetId] = calcVariantId(...
  componentOri(childComponentId),childOri,fcc2bcc);

packetColor = ind2color(packetId);
plot(childGrains,packetColor,'figSize','large')

hold on
plot(boundaryParentGrains.boundary,'lineWidth',2)

selectedParentInd = boundaryParentGrains.findByLocation([100,80]);
selectedParent = boundaryParentGrains(selectedParentInd);
selectedParentId = selectedParent.id
plot(selectedParent.boundary,'lineWidth',2,'lineColor','white')
hold off

%%
% Equal colours identify child grains in the same packet.
% Black lines show reconstructed parent boundaries, and the white line selects
% one parent at [100,80]. Earlier prose called it parent 279; this run returns
% ID 557. The executable lookup avoids assuming that a release-sensitive ID
% remains fixed.

%% Check the selected parent's variants
%
% Plot the measured child poles inside the selected footprint together with
% poles from the reconstructed parent and all theoretical child variants.

selectedChildOri = ebsd(...
  boundaryParentEBSD.grainId == selectedParentId).orientations;
plotPDF(selectedChildOri,Miller(0,0,1,csBCC),'MarkerSize',3)

hold on
selectedParentOri = selectedParent.meanOrientation;
plot(selectedParentOri.symmetrise * Miller(0,0,1,csFCC),...
  'markerSize',10,'marker','s','markerFaceColor','white',...
  'markerEdgeColor','black','lineWidth',2)

selectedChildVariants = variants(fcc2bcc,selectedParentOri);
plotPDF(selectedChildVariants,'markerFaceColor','none',...
  'lineWidth',2,'markerEdgeColor','orange')
hold off

%%
% Measured child poles should lie near the orange theoretical variants.
% Agreement tests the crystallography inside the selected parent rather than
% only checking its outline.

%% Reconstruct austenite orientations at individual pixels
%
% Select original martensite pixels whose remapped grain is now fcc.
% The |(:)| conversions follow the gridded-array rule explained on the
% preceding low-level page: both logical operands must be columns.

isNowFCC = boundaryParentGrains.phaseId(...
  max(1,boundaryParentEBSD.grainId(:))) == ...
  ebsd.name2id('Iron fcc') & ...
  boundaryParentEBSD.phaseId(:) == ebsd.name2id('Iron bcc');

[boundaryParentEBSD(isNowFCC).orientations,pixelFit] = calcParent(...
  ebsd(isNowFCC).orientations,...
  boundaryParentGrains(...
  boundaryParentEBSD(isNowFCC).grainId).meanOrientation,...
  fcc2bcc);

pixelFitQuantiles = quantile(pixelFit./degree,[0.5 0.9 0.99])

plot(boundaryParentEBSD('Iron fcc'),...
  boundaryParentEBSD('Iron fcc').orientations,'figSize','large')

%%
% The pixel colours preserve variation inside the reconstructed austenite
% footprints. Blank regions are not reconstructed as fcc.

plot(boundaryParentEBSD(isNowFCC),pixelFit./degree,...
  'figSize','large')
mtexColorMap('LaboTeX')
mtexColorbar('title','fit (degrees)')
setColorRange([0,5])

%%
% The median pixel fit is 1.830 degrees, 90% are below 3.768 degrees, and 99%
% are below 10.572 degrees. Low values indicate agreement between a
% martensite pixel and the variant predicted from its austenite grain.

%% Denoise and fill missing sites
%
% The preceding <MaParentGrainReconstruction.html Parent Austenite
% Reconstruction> executes the denoising step in full. The same optional
% sequence for this manually reconstructed map is:
%
%   [filledGrains,filledEBSD] = calcGrains(...
%     boundaryParentEBSD('indexed'),'angle',3*degree,'minPixel',10);
%   filledGrains = smoothBoundary(filledGrains,20);
%   F = halfQuadraticFilter;
%   filledEBSD = smooth(filledEBSD('indexed'),F,'fill',filledGrains);
%   plot(filledEBSD('Iron fcc'),...
%     filledEBSD('Iron fcc').orientations,'figSize','large')
%   hold on
%   plot(filledGrains.boundary,'lineWidth',2)
%   hold off
%
% The outlines constrain the fill, so interpolation does not cross the
% reconstructed boundaries. The filter fills missing and newly removed
% small-grain sites. Earlier text promised to fill all not reconstructed
% pixels, but larger indexed bcc regions are not missing and remain bcc.

%% Boundary-graph thresholds
%
% * Initial child-grain segmentation: 3 degrees and at least five pixels.
% The earlier page parameter was two pixels; lowering |minPixel| restores that
% finer, more expensive child partition.
% * Neighbour-pair prefilter: at least 5 degrees.
% * Boundary similarity: 2-degree threshold and 1.5-degree tolerance.
% * Boundary graph inflation power: 1.6.
% * Accepted parent-component fit: below 5 degrees and at least two children.
% * Similar-parent merge: below 4 degrees.

%% Reconstruct footprints from triple points
%
% Boundary evidence can be misleading when child variants from different
% parents happen to match a theoretical child-to-child misorientation.
% A triple point tests three distinct child grains against one common parent,
% providing a stronger local constraint.
% <TriplePointBasedReconstruction.html Triple-Point-Based Parent Phase
% Reconstruction> defines a triple point and explains that distinction in
% detail.

tP = grains.triplePoints('Iron bcc','Iron bcc','Iron bcc');
tPori = grains(tP.grainId).meanOrientation;

[~,tripleFit] = calcParent(tPori,fcc2bcc,...
  'id','threshold',5*degree);

tripleFitQuantiles = quantile(tripleFit./degree,...
  [0.2 0.4 0.6 0.8])

plot(ebsd('Iron bcc'),ebsd('Iron bcc').orientations,...
  'figSize','large')
hold on
plot(grains.boundary,'lineWidth',2)
plot(tP,tripleFit./degree,'MarkerEdgeColor','k','MarkerSize',8)
hold off

setColorRange([0,5])
mtexColorMap('LaboTeX')
mtexColorbar('title','triple-point fit (degrees)')

%%
% The 20th, 40th, 60th, and 80th triple-point fit percentiles are 2.648,
% 3.232, 4.015, and 6.295 degrees. Large-fit points often join into parent
% outlines. Low-fit points support removing all three child boundaries.

%% Build and cluster the triple-point similarity matrix
%
% Convert the common-parent fit to similarity with a 3-degree threshold and
% 2-degree tolerance. Every one of the three grain pairs at a triple point
% receives the same value.

tripleThreshold = 3*degree;
tripleTolerance = 2*degree;

tripleProbability = 1 - 0.5 * (1 + erf(...
  2*(tripleFit-tripleThreshold)./tripleTolerance));
tripleProbabilityQuantiles = quantile(tripleProbability,...
  [0.1 0.5 0.9])

tripleA = sparse(tP.grainId(:,1),tP.grainId(:,2),...
  tripleProbability,length(grains),length(grains));
tripleA = max(tripleA,sparse(tP.grainId(:,2),tP.grainId(:,3),...
  tripleProbability,length(grains),length(grains)));
tripleA = max(tripleA,sparse(tP.grainId(:,1),tP.grainId(:,3),...
  tripleProbability,length(grains),length(grains)));

tripleInflationPower = 1.4;
tripleA = mclComponents(tripleA,tripleInflationPower);

[tripleParentGrains,tripleParentId] = merge(grains,tripleA);
tripleParentGrains = smoothBoundary(tripleParentGrains,20);
numTripleComponents = length(tripleParentGrains)

tripleParentEBSD = ebsd;
old2new = [0;tripleParentId];
tripleParentEBSD.grainId = old2new(1 + ebsd.grainId);

plot(ebsd('Iron bcc'),ebsd('Iron bcc').orientations,...
  'figSize','large')
hold on
plot(tripleParentGrains.boundary,'lineWidth',2)
hold off

%%
% The triple-point probability has 10th, 50th, and 90th percentiles of 0,
% 0.2032, and 0.8536. Clustering produces 779 candidate parent footprints.
% Their outlines are shown above.
% At this stage they still carry child orientations and phases.
% Fit their common parent orientations, reject weak components, remap the
% pixels, and merge similar parents with the same sequence used above.

%% Triple-point graph thresholds
%
% * Common-parent fit pruning inside |calcParent|: 5 degrees.
% * Triple-point similarity: 3-degree threshold and 2-degree tolerance.
% * Triple-point graph inflation power: 1.4.

%% References
%
% * T. Nyyssönen, P. Peura, and V.-T. Kuokkala,
% <https://doi.org/10.1007/s11661-018-4904-9 Crystallography, morphology,
% and martensite transformation of prior austenite in intercritically
% annealed high-aluminum steel>, _Metallurgical and Materials Transactions A_
% 49 (2018), 6426-6441, develops the reconstruction and morphology ideas used
% by this low-level graph workflow.
% * T. Nyyssönen, M. Isakov, P. Peura, and V.-T. Kuokkala,
% <https://doi.org/10.1007/s11661-016-3462-2 Iterative determination of the
% orientation relationship between austenite and martensite from a large
% amount of grain pair misorientations>, _Metallurgical and Materials
% Transactions A_ 47 (2016), 2587-2590, gives the OR-fitting method used here.

%% Next
%
% Continue with <OrientationRelationshipFit.html Fitting the Orientation
% Relationship> for tools that diagnose, refine, and compare OR models beyond
% this reconstruction-specific fit.
