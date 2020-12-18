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
% titanium. Our goal is to reconstuct the original beta phase. The
% original grain structure appears almost visible for human eyes.
% Our computations will be based on the Burgers orientation relationship

beta2alpha = orientation.Burger(ebsd('Ti (beta)').CS,ebsd('Ti (alpha)').CS);
round2Miller(beta2alpha)

%%
% that alligns (110) plane of the beta phase with the (0001) plane of the
% alpha phase and the [1-11] direction of the beta phase with the [2110]
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
% need to compute the initital child grains from out EBSD data set.

% reconstruct grains
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'threshold',1.5*degree,...
  'removeQuadruplePoints');

%%
% As our reconstruction will be based on triple junctions we compute the
% child grains using the option <QuadruplePoints.html
% |removeQuadruplePoints|> which turns all quadruple junctions into 2
% triple junctions. Furthermore, we choose a very small threshold of 1.5
% degree for the identification of grain boundaries to avoid alpha
% orientations that belong to different beta grains get merged into the
% same alpha grain.
%
% Now we are ready to set up the parent grain reconstruction job.

job = parentGrainReconstructor(ebsd, grains, beta2alpha)

%%
% The output of the |job| variable allows you to keep track of the amount
% of already recovered parent grains. The following operations are
% available for parent grain reconstruction and can be applied multiple
% times and in any order to archieve the best possible reconstruction.
%
% * detect child/child and parent/child grain boundaries
% * detect child/child/child triple points
% * recover parent grains from votes
% * recover parent grains from graph clustering
% * merge similar parent grains
% * merge inclusions
%
%% Compute parent orientations from triple junctions
%
% In present datas set we have very little and unreliable parent
% measurements. Therefore, we use triple junctions as germ cells for the
% parent parent grains. In a first step we identify triple junctions that
% have misorientations that are compatible with a common parent orientation
% using the command <parentGrainReconstructor.calcTPVotes.html
% |calcTPVotes|>. This common parent orientation is then stored as votes
% for the three adjacent grains.

job.calcTPVotes('numFit',2)

%%
% In the above command we have not only computed the best fitting but also
% the second best fitting parent orientations. This allows us to ignore
% ambigues triple points which may vote equally well for different parent
% orientations. In the next command
% <parentGrainReconstructor.calcParentFromVote.html |calcParentFromVote|>
% this is controlled by the options |minFit| which controls how well the
% best fitting parent orientations fits the adjacent child orienttions and
% the option |maxFit| which controls how bad the second best needs to be
% such that this triple point is considered.
%
% After identifying, the reliable triple points the command
% <parentGrainReconstructor.calcParentFromVote.html |calcParentFromVote|>
% loops through all grains and checks for the votes from the adjecent
% triple junctions. If all votes coincide and we have at least as many
% votes as specified by the option |minVotes| the child grain is turned
% into a parent grain.

job.calcParentFromVote('strict', 'minFit',2.5*degree,'maxFit',2.5*degree,'minVotes',1)

%%
% We observe that after this step more then 90 percent of the grains became
% parent grains. Lets visualize these reconstructed beta grains

% define a color key
ipfKey = ipfColorKey(ebsd('Ti (Beta)'));
ipfKey.inversePoleFigureDirection = vector3d.Y;

% plot the result
color = ipfKey.orientation2color(job.parentGrains.meanOrientation);
plot(job.parentGrains, color, 'figSize', 'large')

%% Grow parent grains at grain boundaries
%
% Next we may grow the reconstructed parent grains into the regions of the
% remaining child grains. To this end we now use the command
% <parentGrainReconstructor.calcGBVotes.html |calcGBVotes|> to compute fit
% and votes from grain boundaries.

job.calcGBVotes;

%%
% Next we use the exact same command
% <parentGrainReconstructor.calcParentFromVote.html |calcParentFromVote|>
% to 

job.calcParentFromVote('minFit',5*degree,'maxFit',5*degree,'minVotes',1)

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
% assign a parent orientation. We may use the command
% <parentGrainReconstructor.mergeInclusions.html |mergeInclusions|> to
% merge all inclusions that a fever pixels then a certain threshold into
% the surrounding parent grains.

job.mergeInclusions('minSize',50)

% plot the result
color = ipfKey.orientation2color(job.parentGrains.meanOrientation);
plot(job.parentGrains, color, 'figSize', 'large')

%% Reconstruct beta orientations in EBSD map
%
% Until now we have only recovered the beta orientations as the mean
% orientations of the beta grains. In this section we want to set up the
% EBSD variable |parentEBSD| to contain for each pixel a reconstruction of
% the parent phase orientation. This is done by the command
% <parentGrainReconstructor.calcParentEBSD.html |calcParentEBSD|>

[parentEBSD,fit] = job.calcParentEBSD;

% plot the result
color = ipfKey.orientation2color(parentEBSD('Ti (Beta)').orientations);
plot(parentEBSD('Ti (Beta)'),color,'figSize','large')

%%
% We obtain even a measure |parentEBSD.fit| for the corespondence between
% the beta orientation reconstructed for a single pixel and the beta
% orientation of the grain. Lets visualize this 

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
plot(parentGrains.boundary,'lineWidth',3)
hold off
