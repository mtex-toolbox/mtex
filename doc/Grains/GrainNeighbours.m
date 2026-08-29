%% Grain Neighbors
%
%%
% Once a map has been divided into grains, it is also a network. Each grain
% touches a few others, and those connections carry information that a list
% of grains alone does not. Twins come in touching pairs, recrystallised
% grains are surrounded by their parent, and a second phase may sit at the
% corners between three grains of the first.
%
% A grain is a phase-homogeneous, spatially connected region of EBSD
% measurements produced by segmentation. See <GrainReconstruction.html Grain
% Reconstruction> for that step and <SelectingGrains.html Selecting Grains>
% for the distinction between a grain ID and its position in a list.
%
% The same relationships are represented measurement by measurement by the
% <GrainBoundaries.html grain-boundary network>. Working with the mean
% orientations of whole grains is coarser, but much cheaper on a large map.
% <MisorientationTheory.html Misorientation Theory> introduces the symmetry
% used when two mean orientations are compared below.

close all;

% load the sample in its specimen plotting frame
plottingConvention.default('y↑→x');
mtexdata twins silent
CS = ebsd.CS;

% reconstruct and smooth the grain outlines
[grains,ebsd] = calcGrains(ebsd,'angle',5*degree);
grains = smoothBoundary(grains,5);

% compute the mean-orientation colours without printing a colour-key notice
colorKey = ipfColorKey(grains);
grainColor = colorKey.orientation2color(grains.meanOrientation);

% colour each grain by its mean orientation
plot(grains,grainColor)

%%
% Each coloured region is one reconstructed grain. The narrow regions with
% colours unlike their surroundings are the twin candidates examined below.
% Smoothing changes the drawn outlines, but not which grains are neighbours.

%% Which grain touches which
%
% <grain2d.neighbors.html |neighbors|> returns an $N \times 2$ array of
% grain IDs. Each row is one pair of grains that share at least one grain
% boundary segment. The graph is undirected, so a pair appears only once.
%
% Calling the method on the indexed grains keeps pairs for which both grains
% are indexed. The outer map rim has a zero on its missing side and therefore
% does not create a neighbouring-grain pair.

indexedGrains = grains('indexed');
pairs = indexedGrains.neighbors;
pairCount = size(pairs,1)

%%
% The printed count is the number of unique indexed grain pairs, not the
% number of boundary segments. A long shared boundary and a short shared
% boundary each contribute one row.
%
% The values in |pairs| are persistent IDs rather than positions in
% |indexedGrains|. Use an explicit |'id'| lookup whenever they select grains.
% Row 188, for example, identifies the following touching pair.

pairIds = pairs(188,:);
pairGrains = grains('id',pairIds);

hold on
plot(pairGrains.boundary,'LineWidth',4,'lineColor','b')
hold off

%%
% The thick blue outlines enclose the two grains selected by row 188. Their
% outlines meet along the shared trace that makes them neighbours.

%% Counting neighbours
%
% <grain2d.numNeighbors.html |numNeighbors|> counts the distinct grains that
% touch each grain. It includes neighbours of any phase but does not count
% the outside of the scanned area as a grain.
%
% The option |'matrix'| gives the same complete network as a sparse adjacency
% matrix. Its row and column numbers are persistent grain IDs. For the full
% grain list it is symmetric because the network is undirected.

adjacency = grains.neighbors('matrix');

neighborCount = grains.numNeighbors;
plot(grains,neighborCount,'micronbar','off')
mtexColorbar('title','number of neighboring grains')

%%
% On this map the grains cut by the map edge have the higher counts: they
% average five neighbours against three and a half for the interior grains.
% Either count describes only the measured part of the microstructure, just
% as an observed area or shape does.

%% One misorientation per neighbouring pair
%
% Two grains that share a boundary have a misorientation. For their mean
% orientations it is one relationship per pair, rather than one relationship
% per boundary segment.
%
% A neighbouring pair has no intrinsic first grain. Setting |antipodal| to
% true gives its misorientation grain-exchange symmetry, so the relationship
% and its inverse are equivalent.

mori = inv(pairGrains(1).meanOrientation) * pairGrains(2).meanOrientation;
mori.antipodal = true;
mori

%%
% Since the pairs form an array, the same calculation handles every pair at
% once. Explicit ID lookup keeps the operation correct if the grain list has
% previously been filtered or reordered.

mori = inv(grains('id',pairs(:,1)).meanOrientation) .* ...
  grains('id',pairs(:,2)).meanOrientation;
mori.antipodal = true;
mori

close all;
histogram(mori.angle./degree,0:5:95)
xlabel('misorientation angle in degrees')

%%
% This is a grain-pair-weighted histogram: every neighbouring pair counts
% once, regardless of its shared trace length or number of segments. A
% boundary-segment histogram answers a different question.
%
% The result is not the smooth curve expected for a random misorientation
% distribution. It has a sharp peak in the 85 to 90 degree bin, which in
% magnesium is the signature of extension twinning.

%% Finding the twins
%
% A twin relationship is a specific orientation relationship. Here
% <orientation.map.html |orientation.map|> constructs it from two pairs of
% crystallographic vectors that the relationship maps onto each other.

twinning = orientation.map(Miller(0,1,-1,-2,CS),...
  Miller(0,-1,1,-2,CS),Miller(2,-1,-1,0,CS),...
  Miller(2,-1,-1,0,CS))
twinAngle = twinning.angle ./ degree

%%
% Its disorientation angle is 86.3 degrees, where the peak sits. Angle alone
% does not identify a twin: unrelated relationships can have the same angle.
% The comparison below measures distance from the complete crystallographic
% relationship and uses a 3 degree tolerance.

isTwinning = angle(mori,twinning) < 3*degree;
isPeakBin = mori.angle >= 85*degree & mori.angle < 90*degree;

numPairs = length(mori);
numTwinPairs = nnz(isTwinning);
numPairsInPeak = nnz(isPeakBin);
numTwinsInPeak = nnz(isTwinning & isPeakBin);
numOtherPairsInPeak = nnz(~isTwinning & isPeakBin);

twinSummary = table(numPairs,numTwinPairs,...
  100*numTwinPairs/numPairs,numPairsInPeak,numTwinsInPeak,...
  numOtherPairsInPeak,...
  'VariableNames',{'pairs','twinPairs','twinPercent',...
  'pairsIn85to90Bin','twinsIn85to90Bin','otherPairsIn85to90Bin'})

%%
% Of the 251 neighbouring pairs in this map, 93 are within 3 degrees of the
% twin relationship, or 37 percent. The 85 to 90 degree bin also contains 93
% pairs, but the two groups are not identical: 83 are twin matches and 10 are
% other relationships. The peak is dominated by twins, but angle alone does
% not select them. <TwinningBoundaries.html Twinning> pursues the complete
% relationship along the boundary segments themselves.

%% Pairs, and what counts as one
%
% |neighbors| normally returns a pair only when *both* grains belong to the
% list on which it was called. This is why
% |grains('phaseName').neighbors| returns relationships within one phase and
% nothing else.
%
% Sometimes the required rule is every pair in which at least one grain
% belongs to the list. That is how to ask for all neighbours of one grain.
% The option |'full'| switches to this rule.

centralId = 92;

% get all pairs containing grain ID 92
centralPairs = grains('id',centralId).neighbors('full');

% remove the centre ID from the array, leaving its neighbour IDs
neighborIds = centralPairs(centralPairs ~= centralId);

plot(grains,grainColor,'micronbar','off')
hold on
plot(grains('id',neighborIds),'FaceColor','black','FaceAlpha',0.5)
plot(grains('id',centralId).boundary,'lineColor','white','lineWidth',3)
hold off

%%
% The grain outlined in white has ID 92, and the darkened grains are the
% grains it touches. Without |'full'| this list would be empty because no
% pair has both grains inside a list containing only one grain.

%% References
%
% * F. Bachmann, R. Hielscher, and H. Schaeben,
% <https://doi.org/10.1016/j.ultramic.2011.08.002 Grain Detection from 2d
% and 3d EBSD Data--Specification of the MTEX Algorithm>, _Ultramicroscopy_
% 111 (2011), 1720--1733. This paper derives the reconstructed grain and
% boundary network on which the neighbour graph is based.
% * J. K. Mason, E. A. Lazar, R. D. MacPherson, and D. J. Srolovitz,
% <https://doi.org/10.1103/PhysRevE.86.051128 Statistical Topology of
% Cellular Networks in Two and Three Dimensions>, _Physical Review E_ 86
% (2012), 051128. This paper develops grain-neighbour statistics as a
% description of cellular microstructures.
% * J. W. Christian and S. Mahajan,
% <https://doi.org/10.1016/0079-6425(94)00007-7 Deformation Twinning>,
% _Progress in Materials Science_ 39 (1995), 1--157. This review develops
% deformation-twin crystallography and mechanisms.

%% Next
%
% Continue with <GrainMerge.html Merging Grains> to combine twins with their
% parent grains. For segment-weighted analysis, continue instead with
% <BoundaryMisorientations.html Misorientations at Grain Boundaries>.

%#ok<*NASGU>
%#ok<*NOPTS>
%#ok<*MINV>
