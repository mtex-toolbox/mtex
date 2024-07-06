%% Parent Beta Phase Reconstruction in Titanium Alloys
%
%%
% In this section we discuss parent grain reconstruction at the example of
% a titanium alloy. Lets start by importing a sample data set

mtexdata alphaBetaTitanium

% and plot the alpha phase as an inverse pole figure map
plot(ebsd('Ti (alpha)'),ebsd('Ti (alpha)').orientations,'figSize','large')

%%
% The data set contains 99.8 percent alpha titanium and 0.2 percent beta
% titanium. Our goal is to reconstruct the original beta phase. The
% original grain structure appears almost visible for human eyes.
% Our computations will be based on the Burgers orientation relationship

beta2alpha = orientation.Burgers(ebsd('Ti (beta)').CS,ebsd('Ti (alpha)').CS)

%%
% that aligns (110) plane of the beta phase with the (0001) plane of the
% alpha phase and the [1-11] direction of the beta phase with the [-2110]
% direction of the alpha phase.
%
% Note that all MTEX functions for parent grain reconstruction expect the
% orientation relationship as parent to child and not as child to parent.
%
%% Setting up the parent grain reconstructor
% 
% Grain reconstruction is guided in MTEX by a variable of type
% <parentGrainReconstructor.parentGrainReconstructor.html
% |parentGrainReconstructor|>. During the reconstruction process this class
% keeps track about the relationship between the measured child grains and
% the recovered parent grains. In order to set this variable up we first
% need to compute the initial child grains from out EBSD data set.

% reconstruct grains
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'threshold',1.5*degree);

%%
% We choose a very small threshold of 1.5 degree for the identification of
% grain boundaries to avoid alpha orientations that belong to different
% beta grains get merged into the same alpha grain.
%
% Now we are ready to set up the parent grain reconstruction job.

job = parentGrainReconstructor(ebsd, grains);
job.p2c = beta2alpha

%%
% The output of the |job| variable allows you to keep track of the amount
% of already recovered parent grains. Using the variable |job| you have
% access to the following properties
%
% * |job.grainsIn| - the input grains
% * |job.grains| - the grains at the current stage of reconstruction
% * |job.ebsdIn| - the input EBDS data
% * |job.ebsd| - the ebsd data at the current stage of reconstruction
% * |job.mergeId| - the relationship between the input grains
% |job.grainsIn| and the current grains |job.grains|, i.e.,
% |job.grainsIn(ind)| goes into the merged grain
% |job.grains(job.mergeId(ind))|
% * |job.numChilds| - number of childs of each current parent grain
% * |job.parenGrains| - the current parent grains
% * |job.childGrains| - the current child grains
% * |job.isTransformed| - which of the |grainsMeasured| have a computed
% parent
% * |job.isMerged| - which of the |grainsMeasured| have been merged into a parent grain
% * |job.transformedGrains| - child grains in |grainsMeasured| with computed
% parent grain
%
% Additionaly, the <parentGrainReconstructor.parentGrainReconstructor.html
% |parentGrainReconstructor|> class provides the following operations for
% parent grain reconstruction. These operators can be applied multiple
% times and in any order to archieve the best possible reconstruction.
%
% * |job.calcVariantGraph| - compute the variant graph
% * |job.clusterVariantGraph| - compute votes from the variant graph
% * |job.calcGBVotes| - detect child/child and parent/child grain boundaries
% * |job.calcTPVotes| - detect child/child/child triple points
% * |job.calcParentFromVote| - recover parent grains from votes
% * |job.calcParentFromGraph| - recover parent grains from graph clustering
% * |job.mergeSimilar| - merge similar parent grains
% * |job.mergeInclusions| - merge inclusions
%
%%
% The main line of the variant graph based reconstruction algorithm is as
% follows. First we compute the variant graph using the command
% <parentGrainReconstructor.calcVariantGraph |job.calcVariantGraph|>

job.calcVariantGraph('threshold',1.5*degree)

%%
% In a second step we cluster the variant graph and at the same time
% compute probabilities for potential parent orientations using the command
% <parentGrainReconstructor.clusterVariantGraph |job.clusterVariantGraph|>

job.clusterVariantGraph('numIter',3)

%%
% The probabilities are stored in |job.votes.prob| and the corresponding
% variant ids in |job.votes.parentId|. In order to use the parent
% orientation with the highest probability for the reconstruction we use
% the command <parentGrainReconstructor.calcParentFromVote
% |job.calcParentFromVote|>

job.calcParentFromVote

%%
% We observe that after this step more then 99 percent of the grains became
% parent grains. Lets visualize these reconstructed beta grains

% define a color key
ipfKey = ipfColorKey(ebsd('Ti (Beta)'));
ipfKey.inversePoleFigureDirection = vector3d.Y;

% plot the result
color = ipfKey.orientation2color(job.parentGrains.meanOrientation);
plot(job.parentGrains, color, 'figSize', 'large')

%% Merge parent grains
%
% After the previous steps we are left with many very similar parent
% grains. In order to merge all similarly oriented grains into large parent
% grains one can use the command
% <parentGrainReconstructor.mergeSimilar.html |mergeSimilar|>. It takes as
% an option the threshold below which two parent grains should be
% considered a a single grain.

job.mergeSimilar('threshold',5*degree)

% plot the result
color = ipfKey.orientation2color(job.parentGrains.meanOrientation);
plot(job.parentGrains, color, 'figSize', 'large')

%% Merge inclusions
% 
% We may be still a bit unsatisfied with the result as the large parent
% grains contain a lot of poorly indexed inclusions where we failed to
% assign a parent orientation. We use the command
% <parentGrainReconstructor.mergeInclusions.html |mergeInclusions|> to
% merge all inclusions that have fever pixels then a certain threshold into
% the surrounding parent grains.

job.mergeInclusions('maxSize',10)

% plot the result
color = ipfKey.orientation2color(job.parentGrains.meanOrientation);
plot(job.parentGrains, color, 'figSize', 'large')

%% Reconstruct beta orientations in EBSD map
%
% Until now we have only recovered the beta orientations as the mean
% orientations of the beta grains. In this section we want to set up the
% EBSD variable |parentEBSD| to contain for each pixel a reconstruction of
% the parent phase orientation. This is done by the command
% |<parentGrainReconstructor.calcParentEBSD.html calcParentEBSD>|

parentEBSD = job.ebsd;

% plot the result
color = ipfKey.orientation2color(parentEBSD('Ti (Beta)').orientations);
plot(parentEBSD('Ti (Beta)'),color,'figSize','large')

%%
% The recovered EBSD variable |parentEBSD| contains a measure
% |parentEBSD.fit| for the corespondence between the beta orientation
% reconstructed for a single pixel and the beta orientation of the grain.
% Lets visualize this

% the beta phase
plot(parentEBSD, parentEBSD.fit ./ degree,'figSize','large')
mtexColorbar
setColorRange([0,5])
mtexColorMap('LaboTeX')

hold on
plot(job.grains.boundary,'lineWidth',2)
hold off

%%
% For comparison the map with original alpha phase and on top the recovered
% beta grain boundaries

plot(ebsd('Ti (Alpha)'),ebsd('Ti (Alpha)').orientations,'figSize','large')

hold on
parentGrains = smooth(job.grains,5);
plot(parentGrains.boundary,'lineWidth',3,'lineColor','White')
hold off

