%% Parent Beta Phase Reconstruction in Titanium Alloys
%
%%
% In this section we discuss parent grain reconstruction at the example of
% a titanium alloy. Lets start by importing a sample data set

mtexdata alphaBetaTitanium

% and plot the alpha phase as an inverse pole figure map
ipfKey = ipfColorKey(grains('Ti (beta)'));
ipfKey.inversePoleFigureDirection = vector3d.Y;

plot(ebsd('Ti (alpha)'),ebsd('Ti (alpha)').orientations,'figSize','large')

%%
% The data set contains 99.8 percent alpha titanium and 0.2 percent alpha
% titanium. Our goal is to reconstuct the original beta phase. The
% original grain structure appears almost visible for human eyes.
% Our computations will be based on the following parent to child
% orientation relationship

beta2alpha = inv(orientation.byEuler(135*degree, 90*degree, 355*degree,...
  ebsd('Ti (alpha)').CS,ebsd('Ti (Beta)').CS))

%%
% Note that all MTEX functions for parent grain reconstruction expect the
% orientation relationship as parent to child and not as child to parent.
%
%% Detecting triple points that belong to the same parent orientation
%
% In a first step we want to identify triple junctions that have
% misorientations that are compatible with a common parent orientations. To
% this end we first compute alpha grains using the option
% <QuadruplePoints.html |removeQuadruplePoints|> which turn all quadruple
% junctions into 2 triple junctions. Furthermore, we choose a very small
% threshold of 1.5 degree for the identification of grain boundaries to
% avoid alpha orientations that belong to different beta grains get merged
% into the same alpha grain.

% reconstruct grains
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'removeQuadruplePoints','threshold',1.5*degree);
grains = smooth(grains);

% plot all alpha pixels
plot(ebsd('Ti (alpha)'),ebsd('Ti (alpha)').orientations,...
  'region',[300 400 -500 -440],'micronbar','off','figSize','large');

% and on top the grain boundaries
hold on
plot(grains.boundary,'linewidth',2 ,'region',[300 400 -500 -440]);
hold off

%%
% Above we have plotted only a very small subregion of the original data
% set to make the seperation of the qudruple junctions better visible.
%
% Next we extract all alpha - alpha - alpha triple junctions and use the
% command <calcParent.html |calcParent|> to find for each of these triple
% junctions the best fitting parent orientations. 

% extract all alpha - alpha - alpha triple points
tP = grains.triplePoints('Ti (alpha)','Ti (alpha)','Ti (alpha)')

% compute for each triple point the best fitting parentId and how well the fit is
[parentId, fit] = calcParent(grains(tP.grainId).meanOrientation,beta2alpha,'numFit',2,'id');

%%
% The command |calcParent| returns for each child orientation a |parentId|
% which allows us later to compute the parent orientation from the child
% orientation. Furthermore, the command return for each triple junction the
% misfit between the adjecent parent orientations in radiant. Finally, the
% option |'numFit',2| causes |calcParent| to return not only the best fit
% but also the second best fit. This will be used later. First we simple
% colorize the triple junctions according to the best fit.

hold on
plot(tP,fit(:,1) ./ degree,'MarkerEdgecolor','k','MarkerSize',10,'region',[300 400 -500 -440])
setColorRange([0,10])
mtexColorMap LaboTeX
mtexColorbar
hold off

%%
% Next we select those triple junctions as reliable that have a fit less
% than 2.5 degree and second best fit that is larger than  2.5 degree

consistenTP = fit(:,1) < 2.5*degree & fit(:,2) > 2.5*degree;

% marke thse triple points by a red cicle
hold on
plot(tP(consistenTP),'MarkerEdgecolor','r','MarkerSize',10,...
  'MarkerFaceColor','none','linewidth',2,'region',[300 400 -500 -440])
hold off

%% Recover beta grains from consistent triple junctions
%
% We observe that despite the quite sharp threshold we have many consistent
% triple points. In the next step we check wether all consistent triple
% junctions of a grain vote for the same parent orientation. Such a check
% for consistent votes can be computed by the command <majorityVote.html
% |majorityVote|> using the option |strict|.

% get a unique parentId vote for each grain
parentId = majorityVote( tP(consistenTP).grainId, ...
  parentId(consistenTP,:,1), max(grains.id),'strict');

%%
% The command |majorityVote| returns for each grain with consistent
% parentId votes this unique parentId and for all other grains |NaN|.
% Accordingly, we can idetify all grains with a unique vote by

hasVote = ~isnan(parentId);

%% 
% For all grains with a unique vote we now use the command <variants.html
% |variants|> to compute the parent orientation corresponding to the
% |parentId|. This parent orientations we assign as new |meanOrientation|
% to our grains.

% lets store the parent grains into a new variable
parentGrains = grains;

% change orientations of consistent grains from child to parent
parentGrains(hasVote).meanOrientation = ...
  variants(beta2alpha,grains(hasVote).meanOrientation,parentId(hasVote));

% update all grain properties that are related to the mean orientation
parentGrains = parentGrains.update;

plot(parentGrains('Ti (beta)'), ...
  ipfKey.orientation2color(parentGrains('Ti (beta)').meanOrientation),'figSize','large')

%%
% We observe that this first step already results in very many Beta grains.
% However, the grain boundaries are still the boundaries of the original
% alpha grains. To overcome this, we merge all Beta grains that have a
% misorientation angle smaller then 2.5 degree

% merge beta grains
[parentGrains,parentId] = merge(parentGrains,'threshold',2.5*degree);

% set up a EBSD map for the parent phase
parentEBSD = ebsd;

% and store there the grainIds of the parent grains
parentEBSD('indexed').grainId = parentId(ebsd('indexed').grainId);

plot(parentGrains('Ti (beta)'), ...
  ipfKey.orientation2color(parentGrains('Ti (beta)').meanOrientation),'figSize','large')


%% Merge alpha grains to beta grains
%
% After the first two steps we have quite some beta grains some alpha
% grains have not yet transformed into beta grains. In order to merge those
% left over alpha grains we check wether their misorientation with one of
% the neighbouring beta grains coincides with the parent to grain
% orientation relationship and if yes merge them evantually with the
% already reconstructed beta grains.
%
% First extract a list of all neighbouring alpha - beta grains

% all neighbouring alpha - beta grains
grainPairs = neighbors(parentGrains('Ti (alpha)'), parentGrains('Ti (Beta)'));

%%
% and check whether how well they fit to a common parent orientation

% extract the corresponding meanorientations
oriAlpha = parentGrains( grainPairs(:,1) ).meanOrientation;
oriBeta = parentGrains( grainPairs(:,2) ).meanOrientation;

% compute for each alpha / beta pair of grains the best fitting parentId
[parentId, fit] = calcParent(oriAlpha,oriBeta,beta2alpha,'numFit',2,'id');

%%
% Similarly, as in the first step the command <calcParent.html
% |calcParent|> return a list of |parentId| that allows the convert the
% child orientations into parent orientations using the command
% <variants.html |variants|> and the fitting to the given parent
% orientation. Similarly, as for the triple point we select only those
% alpha beta pairs such that the fit is below the threshold of 2.5 degree
% and at the same time the second best fit is above 2.5 degree.

% consistent pairs are those with a very small misfit
consistenPairs = fit(:,1) < 2.5*degree & fit(:,2) > 2.5*degree;

%%
% Next we compute for all alpha grains the majority vote of the surounding
% beta grains and change their orientation from alpha to beta

parentId = majorityVote( grainPairs(consistenPairs,1), ...
  parentId(consistenPairs,1), max(parentGrains.id));

% change grains from child to parent
hasVote = ~isnan(parentId);
parentGrains(hasVote).meanOrientation = ...
  variants(beta2alpha, parentGrains(hasVote).meanOrientation, parentId(hasVote));

% update grain boundaries
parentGrains = parentGrains.update;

% merge new beta grains into the old beta grains
[parentGrains,parentId] = merge(parentGrains,'threshold',2.5*degree);

% update grainId in the ebsd map
parentEBSD('indexed').grainId = parentId(parentEBSD('indexed').grainId);

% plot the result
color = ipfKey.orientation2color(parentGrains('Ti (beta)').meanOrientation);
plot(parentGrains('Ti (beta)'),color,'linewidth',2)

%%
% The above step has merged 

sum(hasVote)

%%
% alpha grains into the already reconstructed beta grain. This reduces the
% amount of grains not yet reconstructed to

sum(parentGrains('Ti (alpha').grainSize) ./ sum(parentGrains.grainSize)*100

%%
% percent. One way to proceed would be to repeat the steps of this section
% multiple time, maybe with increasing threshold, until the percentage of
% reconstructed beta grains is sufficiently high. Another approach in to
% consider the left over alpha grains as noise and use denoising techniques
% to replace them with beta orientations. This will be done in the last
% section.

%% Reconstruct beta orientations in EBSD map
%
% Until now we have only recovered the beta orientations as the mean
% orientations of the beta grains. In this section we want to set up the
% EBSD variable |parentEBSD| to contain for each pixel a reconstruction of
% the parent phase orientation.
%
% Therefore, we first identify all pixels that previously have been alpha
% titanium but now belong to a beta grain.

% consider only original alpha pixels that now belong to beta grains
isNowBeta = parentGrains.phaseId(max(1,parentEBSD.grainId)) == 2 & parentEBSD.phaseId == 3;

%%
% Next we can use once again the function <calcParent.html |calcParent|> to
% recover the original beta orientation from the measured alpha orientation
% giving the mean beta orientation of the grain.

% update beta orientation
[parentEBSD(isNowBeta).orientations, fit] = calcParent(parentEBSD(isNowBeta).orientations,...
  parentGrains(parentEBSD(isNowBeta).grainId).meanOrientation,beta2alpha);

%%
% We obtain even a measure |fit| for the corespondence between the beta
% orientation reconstructed for a single pixel and the beta orientation of
% the grain. Lets visualize this measure of fit

% the beta phase
plot(parentEBSD(isNowBeta),fit ./ degree,'figSize','large')
mtexColorbar
setColorRange([0,5])
mtexColorMap('LaboTeX')

hold on
plot(parentGrains.boundary)
hold off

%% 
% Lets finaly plot the reconstructed beta phase

plot(parentEBSD('Ti (beta)'),ipfKey.orientation2color(parentEBSD('Ti (beta)').orientations),'figSize','large')

%% Denoising of the reconstructed beta phase
% As promised we end our discussion by applying denoising techniques to
% fill the remaining holes of alpha grains. To this end we first
% reconstruct grains from the parent orientations and throw away all small
% grains

[parentGrains,parentEBSD.grainId] = calcGrains(parentEBSD('indexed'),'angle',5*degree);

% remove all the small grains
parentEBSD = parentEBSD(parentGrains(parentGrains.grainSize > 15));

% redo grain reconstruction
[parentGrains,parentEBSD.grainId] = calcGrains(parentEBSD('indexed'),'angle',5*degree);

% smooth the grains a bit
parentGrains = smooth(parentGrains);

%%
% Finally, we denoise the remaining beta orientations and at the same time
% fill the empty holes

F= halfQuadraticFilter;
parentEBSD = smooth(parentEBSD,F,'fill',parentGrains);

% plot the resulting beta phase
plot(parentEBSD('Ti (beta)'),ipfKey.orientation2color(parentEBSD('Ti (beta)').orientations),'figSize','large')

hold on
plot(parentGrains.boundary,'lineWidth',3)
hold off

%%
% For comparison the map with original alpha phase and on top the recovered
% beta grain boundaries

plot(ebsd('Ti (alpha)'),ebsd('Ti (alpha)').orientations,'figSize','large')

hold on
plot(parentGrains.boundary,'lineWidth',3)
hold off








