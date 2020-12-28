%% Martensite Parent Grain Reconstruction
%
%% 
% This script demonstrates the tools MTEX offers to reconstruct a parent
% austenite phase from a measured martensite phase. Some of the ideas are
% from
% <https://www.researchgate.net/deref/http%3A%2F%2Fdx.doi.org%2F10.1007%2Fs11661-018-4904-9?_sg%5B0%5D=gRJGzFvY4PyFk-FFoOIj2jDqqumCsy3e8TU6qDnJoVtZaeUoXjzpsGmpe3TDKsNukQYQX9AtKGniFzbdpymYvzYwhg.5jfOl5Ohgg7pW_6yACRXN3QiR-oTn8UsxZjTbJoS_XqwSaaB7r8NgifJyjSES2iXP6iOVx57sy8HC4q2XyZZaA
% Crystallography, Morphology, and Martensite Transformation of Prior
% Austenite in Intercritically Annealed High-Aluminum Steel> by Tuomo
% Nyyssönen. We shall use the following sample data set.

% load the data
mtexdata martensite 
plotx2east

% grain reconstruction
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'), 'angle', 3*degree);

% remove small grains
ebsd(grains(grains.grainSize < 4)) = [];

% reidentify grains with small grains removed:
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',3*degree);
grains = smooth(grains,5);

% plot the data and the grain boundaries
plot(ebsd('Iron bcc'),ebsd('Iron bcc').orientations,'figSize','large')
hold on
plot(grains.boundary,'linewidth',2)
hold off

%% Setting up the parent grain reconstructor
% 
% Grain reconstruction is guided in MTEX by a variable of type
% <parentGrainReconstructor.parentGrainReconstructor.html
% |parentGrainReconstructor|>. During the reconstruction process this class
% keeps track about the relationship between the measured child grains and
% the recovered parent grains.

job = parentGrainReconstructor(ebsd,grains);

%%
% The |parentGrainReconstructor| guesses from the EBSD data what is the
% parent and what is the child phase. If this guess is not correct it might
% by specified explicitely by defining an initial guess for the parent to
% child orientation relationship first an passing it as a third argument to
% <parentGrainReconstructor.parentGrainReconstructor.html
% |parentGrainReconstructor|>.
%
%% Determine the parent child orientation relationship
%
% It is well known that the phase transformation from austenite to
% martensite is not described by a fixed orientation relationship. In fact,
% the actual orientation relationship needs to be determined for each
% sample individualy. Here, we used the iterative method proposed by Tuomo
% Nyyssönen and implemented in the function <calcParent2Child.html
% |calcParent2Child|> that starts at an initial guess of the orientation
% relation ship and (hopefuly) iterates towards the true orientation
% relationship.
%
% Here we use as the initial guess the Kurdjumov Sachs orientation
% relationship

% initial gues is Kurdjumov Sachs
job.p2c = orientation.KurdjumovSachs(job.csParent, job.csChild);

% compute the best fitting parent to child orientation relationship
job.calcParent2Child

%%
% Beside the optimized parent to child orientation relationship the command
% <calcParent2Child.html |calcParent2Child|> also stores the misfit between
% all grain to grain misorientations and the theoretical child to child
% misorientations in the variable |job.fit|. In fact, the algorithm assumes
% that the majority of all boundary misorientations are child to child
% misorientations and finds the parent to child orientations relationship
% by minimizing this misfit. The following histogram displays the
% distribution of the misfit over all grain to grain misorientations.

close all
histogram(job.fit./degree)
xlabel('disorientation angle')

%%
% We may also explicitely compute the misfit for all child to child
% boundaries using the command <parentGrainReconstructor.calcGBFit.html
% |calcGBFit|>. Beside the list |fit| it returns also the list of grain
% pairs for which these fits have been computed. Using th command
% <grainBoundary.selectByGrainId.html |selectByGrainId|> we can find the
% corresponding boundary segments and colorize them according to this
% misfit.

% compute the misfit for all child to child grain neighbours
[fit,c2cPairs] = job.calcGBFit;

% select grain boundary segments by grain ids
[gB,pairId] = job.grains.boundary.selectByGrainId(c2cPairs);

% plot the child phase
plot(ebsd('Iron bcc'),ebsd('Iron bcc').orientations,'figSize','large')

% and on top of it the boundaries colorized by the misfit
hold on;
plot(gB, fit(pairId) ./ degree,'linewidth',2);
hold off

setColorRange([2.5,5])
mtexColorMap white2black
mtexColorbar

%% Graph based parent grain reconstruction
%
% Next we set up a graph where each edge describes two neighbouring grains
% and the value of this edge is the probability that these two grains
% belong to the same parent grain. This graph is computed by the function
% <parentGrainReconstructor.buildGraph.html |buildGraph|>. The probability
% is computed from the misfit of the misorientation between the two child
% grains to the theoretical child to child misorientation. More precisely,
% we model the probability by a cumulative Gaussian distribution with the
% mean value |'threshold'| which describes the misfit at which the
% probability is exactly 50 percent and the standard deviation
% |'tolerance'|.

job.buildGraph('threshold',2*degree,'tolerance',1.5*degree)

%% 
% We may visualize th graph by coloring the boundary between grains
% according to the edge value of the graph. This can be accomplished by the
% command <parentGrainReconstructor.plotGraph.html |plotGraph|>

plot(ebsd('Iron bcc'),ebsd('Iron bcc').orientations,'figSize','large')
hold on;
job.plotGraph('linewidth',3)
hold off

mtexColorMap black2white
mtexColorbar
setColorRange([0.5,1])

%%
% The next step is to cluster the graph into components. This is done by
% the command <parentGrainReconstructor.clusterGraph.html |clusterGraph|>
% which uses by default the Markovian clustering algorithm. The number of
% clusters can be controlled by the option |'inflationPower'|.s

job.clusterGraph('inflationPower',1.7)

%%
% Finaly, we reconstruct parent orientation for clusters which have a
% misfit below a certain |'threshold'|.

job.mergeByGraph('threshold',5*degree)

% plot the result
plot(job.grains('Iron fcc'),job.grains('Iron fcc').meanOrientation)

%% Merge similar grains and inclusions
%
% We observe that we have some neighbouring parent grains with similar
% orientations. These can be merged into big parent grains using the
% command <parentGrainReconstructor.clusterGraph.html |mergeSimilar|>

% merge grains with similar orientation
job.mergeSimilar('threshold',3*degree)

% plot the result
plot(job.grains('Iron fcc'),job.grains('Iron fcc').meanOrientation)

%%
% We may be still a bit unsatisfied with the result as the large parent
% grains contain a lot of poorly indexed inclusions where we failed to
% assign a parent orientation. We may use the command
% <parentGrainReconstructor.mergeInclusions.html |mergeInclusions|> to
% merge all inclusions that a fever pixels then a certain threshold into
% the surrounding parent grains.

job.mergeInclusions('maxSize',50)

% plot the result
plot(job.grains('Iron fcc'),job.grains('Iron fcc').meanOrientation)

%% Compute Child Variants
% 
% Knowing the parent grain orientations we may compute the variants and
% packets of each child grain using the command
% <parentGrainReconstructor.calcVariants.html |calcVariants|>. The values
% are stored with the properties |job.transformedGrains.variantId| and
% |job.transformedGrains.packetId|. The |packetId| is defined as the
% closest {111} plane in austenite to the (011) plane in martensite.

job.calcVariants

% associate to each packet id a color and plot
color = ind2color(job.transformedGrains.packetId);
plot(job.transformedGrains,color)

hold on
parentGrains = smooth(job.parentGrains,5)
plot(parentGrains.boundary,'linewidth',3)

% outline a specific parent grain
hold on
id = 412;
plot(parentGrains('id',id).boundary,'linewidth',3,'lineColor','w')
hold off

%% 
% In order to check our parent grain reconstruction we chose the single
% parent grain outlined in the above map and plot all child variants of its
% reconstructed parent orientation together with the actually measured
% child orientations inside the parent grain.

% the measured child orientations that belong to parent grain 279
childOri = ebsd(job.ebsd.grainId==id).orientations;
plotPDF(childOri,Miller(0,0,1,childOri.CS),'MarkerSize',3)

% the orientation of parent grain 279
hold on
parentOri = job.parentGrains('id',id).meanOrientation;
plot(parentOri.symmetrise * Miller(0,0,1,parentOri.CS))

% the theoretical child variants
childVariants = variants(job.p2c, parentOri);
plotPDF(childVariants, 'markerFaceColor','none','linewidth',2,'markerEdgeColor','orange')
hold off

%% Parent EBSD reconstruction
%
% So far our analysis was at the grain level. However, once parent grain
% orientations have been computed we may also use them to compute parent
% orientations of each pixel in our original EBSD map. This is done by the command
% <parentGrainReconstructor.calcParentEBSD.html |calcParentEBSD|>

parentEBSD = job.calcParentEBSD;

% plot the result
plot(parentEBSD('Iron fcc'),parentEBSD('Iron fcc').orientations,'figSize','large')

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


%% Denoise the parent map
%
% Finaly we may apply filtering to the parent map to fill non indexed or
% not reconstructed pixels. To this end we first run grain reconstruction
% on the parent map

[parentGrains, parentEBSD.grainId] = calcGrains(parentEBSD('indexed'),'angle',3*degree);

% remove very small grains
parentEBSD(parentGrains(parentGrains.grainSize<10)) = [];

% redo grain reconstrucion
[parentGrains, parentEBSD.grainId] = calcGrains(parentEBSD('indexed'),'angle',3*degree);
parentGrains = smooth(parentGrains,5);

plot(ebsd('indexed'),ebsd('indexed').orientations,'figSize','large')

hold on
plot(parentGrains.boundary,'lineWidth',4)
hold off

%%
% and then use the command <EBSD.smooth.html |smooth|> to fill the holes in
% the reconstructed parent map

% fill the holes
F = halfQuadraticFilter;
parentEBSD = smooth(parentEBSD('indexed'),F,'fill',parentGrains);

% plot the parent map
plot(parentEBSD('Iron fcc'),parentEBSD('Iron fcc').orientations,'figSize','large')

% with grain boundaries
hold on
plot(parentGrains.boundary,'lineWidth',4)
hold off
