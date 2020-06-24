
%% settings

% grain reconstruction threshold
delta_1 = 1.5*degree;

% triple point merge threshold
delta_2 = 2.5*degree;

% child 2 parent merge threshold - it increases with each run
%delta_3 = [1.5, 1.5, 3, 5, 5, 5]*degree;
delta_3 = 2.5*degree;

% parent 2 parent merge threshold
delta_4 = 2.5*degree;

plotx2east

%% Data Import & Grain Reconstruction

% load the data
ebsd = EBSD.load('EDXLMDTi64 Specimen 1 M1 Map Data 1.cpr','convertSpatial2EulerReferenceFrame');

% restrict to some subset of interest
%ebsd = ebsd(ebsd.inpolygon([0 -800 500 300]));  % small
%ebsd = ebsd(ebsd.inpolygon([300 -500 100 60])); % very small
%ebsd = ebsd(ebsd.inpolygon([1000 -600 300 300])); % strange
%ebsd = ebsd(ebsd.inpolygon([1050 -600 50 50])); % strange
%ebsd = ebsd(ebsd.inpolygon([900 -400 300 200])); % strange

% compute with the purely rotational symmetry groups only
ebsd('Ti (alpha)').CS = ebsd('Ti (alpha)').CS.properGroup;
ebsd('Ti (beta)').CS = ebsd('Ti (beta)').CS.properGroup;

% reconstruct grains
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'removeQuadruplePoints','threshold',delta_1);

grains = smooth(grains);

% define the beta2alpha misorientation relationship
beta2alpha = inv(orientation.byEuler(135*degree, 90*degree, 355*degree,...
  ebsd('Ti (alpha)').CS,ebsd('Ti (Beta)').CS));

%%

% Plot
%figure(1)
ipfKey = ipfColorKey(grains('Ti (beta)'));
ipfKey.inversePoleFigureDirection = vector3d.Y;

plot(ebsd('Ti (alpha)'),ebsd('Ti (alpha)').orientations)
hold on
plot(grains.boundary,'linewidth',2)
hold off


%% Detecting by child to child grain boundaries




%% Detecting by child, child, child triple points


% extract all alpha - alpha - alpha triple points
tP = grains.triplePoints('Ti (alpha)','Ti (alpha)','Ti (alpha)')

%%

% compute for each triple point the best fitting parentId and how well the fit is
[parentId, fit] = calcParent(grains(tP.grainId).meanOrientation,beta2alpha,'numFit',2,'id');

hold on
plot(tP,fit(:,1) ./ degree,'MarkerEdgecolor','k','MarkerSize',10)
setColorRange([0,10])
mtexColorMap LaboTeX
mtexColorbar
hold off


%%


% consistent triple points are those with a very small misfit
consistenTP = fit(:,1) < delta_2 & fit(:,2) > delta_2;

hold on
plot(tP(consistenTP),'MarkerEdgecolor','r','MarkerSize',10,'MarkerFaceColor','none','linewidth',2)
hold off

%%

% get a unique parentId vote for each grain
parentId = majorityVote( tP(consistenTP).grainId, ...
  parentId(consistenTP,:,1), max(grains.id),'strict');

% change orientations of consistent grains from child to parent
parentGrains = grains;
parentEBSD = ebsd;
hasVote = ~isnan(parentId);
parentGrains(hasVote).meanOrientation = ...
  variants(beta2alpha,grains(hasVote).meanOrientation,parentId(hasVote));

% update grain boundaries
parentGrains = parentGrains.update;

k = 1;
%%
% after this step it may happen that we have grains with a common grain
% boundary and very similar orientation -> merge those

[parentGrains,parentId] = merge(parentGrains,'threshold',delta_4);

% update grainId in the ebsd map
parentEBSD('indexed').grainId = parentId(ebsd('indexed').grainId);

plot(parentGrains('Ti (beta)'), ...
  ipfKey.orientation2color(parentGrains('Ti (beta)').meanOrientation))



%% Detecting by parent - child grain boundaries
%
% After step 1 we have quite some beta grains and we continue to merge
% these beta grains with the remaining alpha grains if they have the
% alpha2beta misorientation relation ship within a certain threshold
%
% Important: repeat this step until the number of grains does not change
% anymore (approx. 5 times)

% all neighbouring alpha - beta grains
grainPairs = neighbors(parentGrains('Ti (alpha)'), parentGrains('Ti (Beta)'));

% extract the corresponding meanorientations
oriAlpha = parentGrains( grainPairs(:,1) ).meanOrientation;
oriBeta = parentGrains( grainPairs(:,2) ).meanOrientation;

% compute for each alpha / beta pair of grains the best fitting parentId
[parentId, fit] = calcParent(oriAlpha,oriBeta,beta2alpha,'numFit',2,'id');

% consistent pairs are those with a very small misfit
consistenPairs = fit(:,1) < delta_3(k) & fit(:,2) > delta_3(k);

% get a unique parentId vote for each grain
if k == 1 % in the first run we consider only consistent grains
  parentId = majorityVote( grainPairs(consistenPairs,1), ...
    parentId(consistenPairs,1), max(parentGrains.id),'strict');
else
  parentId = majorityVote( grainPairs(consistenPairs,1), ...
    parentId(consistenPairs,1), max(parentGrains.id));  
end

% change grains from child to parent
hasVote = ~isnan(parentId);
if any(hasVote)
  parentGrains(hasVote).meanOrientation = ...
    variants(beta2alpha, parentGrains(hasVote).meanOrientation, parentId(hasVote));
end

% update grain boundaries
parentGrains = parentGrains.update;

% after this step it may happen that we have grains with a common grain
% boundary and very similar orientation -> merge those
[parentGrains,parentId] = merge(parentGrains,'threshold',delta_4);

% update grainId in the ebsd map
parentEBSD('indexed').grainId = parentId(parentEBSD('indexed').grainId);
k = k+1; parentGrains

figure
color = ipfKey.orientation2color(parentGrains('Ti (beta)').meanOrientation);
plot(parentGrains('Ti (beta)'),color,'linewidth',2)

%hold on
%plot(grains.boundary('Ti (alpha)','Ti (Beta)'),'lineWidth',3,'lineColor','blue');
%hold off


%% Reconstruct beta orientations in EBSD map

% consider only original alpha pixels that now belong to beta grains
isNowBeta = parentGrains.phaseId(max(1,parentEBSD.grainId)) == 2 & parentEBSD.phaseId == 3;

% update beta orientation
[parentEBSD(isNowBeta).orientations, fit] = calcParent(parentEBSD(isNowBeta).orientations,...
  parentGrains(parentEBSD(isNowBeta).grainId).meanOrientation,beta2alpha);

figure

% the beta phase
plot(parentEBSD(isNowBeta),fit ./ degree)
mtexColorbar
mtexColorMap('LaboTeX')

%% Plot the reconstructed beta phase on the ebsd grid

figure

% the beta phase
plot(parentEBSD('Ti (beta)'),ipfKey.orientation2color(parentEBSD('Ti (beta)').orientations))

%% Perform Grain reconstruction on the reconstructed beta phase

[parentGrains,parentEBSD.grainId] = calcGrains(parentEBSD('indexed'),'angle',5*degree);

% remove all the small grains
parentEBSD = parentEBSD(parentGrains(parentGrains.grainSize > 15));

% redo grain reconstruction
[parentGrains,parentEBSD.grainId] = calcGrains(parentEBSD('indexed'),'angle',5*degree);

% smooth the grains a bit
parentGrains = smooth(parentGrains);

% plot the grain boundaries
plot(parentEBSD('Ti (beta)'),ipfKey.orientation2color(parentEBSD('Ti (beta)').orientations))
hold on
plot(parentGrains.boundary,'lineWidth',3)
hold off

%%

F= halfQuadraticFilter;
ebsdS = smooth(parentEBSD,F,parentGrains,'fill')

plot(ebsdS('Ti (beta)'),ipfKey.orientation2color(ebsdS('Ti (beta)').orientations))

hold on
plot(parentGrains.boundary,'lineWidth',3)
hold off

