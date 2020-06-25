% This code is partely based on the code of Gerrit Ter Haar
% data are from Susanne Hemes, Aachen
%

%% Data Import & Grain Reconstruction

% load the data
ebsd = EBSD.load('EDXLMDTi64 Specimen 1 M1 Map Data 1.cpr','convertSpatial2EulerReferenceFrame')

%ebsd = ebsd(ebsd.inpolygon([0 -800 500 300]));
%ebsd = ebsd(ebsd.inpolygon([300 -500 100 60]));

csAlpha = ebsd('Ti (alpha)').CS.properGroup;
csBeta = ebsd('Ti (beta)').CS.properGroup;

% compute with the purely rotational symmetry groups only
ebsd('Ti (alpha)').CS = csAlpha;
ebsd('Ti (beta)').CS = csBeta;
ebsd('Ti (beta)').color = 'darkblue'

% reconstruct grains
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'))

%% Plot

plotx2east
figure(1)

plot(ebsd)


figure(2)
ipfKey = ipfHSVKey(csAlpha);
ipfKey.inversePoleFigureDirection = xvector
color = ipfKey.orientation2color(ebsd('Ti (alpha)').orientations);
plot(ebsd('Ti (alpha)'),color)
hold on
plot(grains.boundary,'linewidth',2)
hold off

%%

ori_beta = ebsd('Ti (beta)').orientations;

h_beta = Miller({1,0,0},{1,1,0},{1,1,1},csBeta);
plotPDF(ori_beta,h_beta,'MarkerSize',7,'MarkerFaceAlpha',0.1)
%plotPDF(ori_beta,Miller({1,0,0},{1,1,1},csBeta),'contourf')

%%

figure(1)
ori_alpha = ebsd('Ti (alpha)').orientations;

h_alpha = Miller({0,0,0,1},{-2,1,1,0},csAlpha);
plotPDF(ori_alpha,h_alpha,'MarkerSize',7,'MarkerFaceAlpha',0.1)
%plotPDF(ori_alpha,Miller({1,0,0},{1,1,1},csAlpha),'contourf')

%% alpha2beta misorientation

% define the alpha2beta misorientation relationship
alpha2beta = orientation.byEuler(135*degree, 90*degree, 355*degree,...
  ebsd('Ti (alpha)').CS,ebsd('Ti (Beta)').CS);

%%

round2Miller(alpha2beta)

%%

alpha2beta = orientation.map(Miller(0,0,0,1,csAlpha),Miller(1,1,0,csBeta),...
  Miller(2,-1,-1,0,csAlpha),Miller(-1,1,-1,csBeta))

beta2alpha = inv(alpha2beta)
round2Miller(beta2alpha)

%%

h_alpha = Miller({0,0,0,1},{-2,1,1,0},{1,0,-1,1},csAlpha);
plotPDF(alpha2beta,h_alpha)


%%

h_beta = Miller({1,0,0},{1,1,0},{1,1,1},{2,1,0},csBeta);
plotIPDF(alpha2beta,h_beta)

%%

plot(alpha2beta,'axisAngle','MarkerFaceColor','red')


%% transformation texture


%% the pole figure of the alpha phase

figure(1)
ori_alpha = ebsd('Ti (alpha)').orientations;

h_alpha = Miller({0,0,0,1},{-2,1,1,0},csAlpha);
plotPDF(ori_alpha,h_alpha,'MarkerSize',7,'MarkerFaceAlpha',0.1)
%plotPDF(ori_alpha,Miller({1,0,0},{1,1,1},csAlpha),'contourf')

%%

figure(2)
plotPDF(ori_beta * alpha2beta,h_alpha,'MarkerSize',7,'MarkerFaceAlpha',0.1)

%%

figure(3)
%plotPDF(ori_beta * csBeta * alpha2beta,h_alpha,'MarkerSize',7,'MarkerFaceAlpha',0.1)

plotPDF(ori_beta * inv(variants(beta2alpha)),h_alpha,'MarkerSize',7,'MarkerFaceAlpha',0.1)

%%

variants(alpha2beta)

variants(beta2alpha)

multiplicity(alpha2beta)

%% Step 1: Merge at Consistent Triple Points (this will take some time)

% extract all alpha - alpha - alpha triple points
tP = grains.triplePoints('Ti (alpha)','Ti (alpha)','Ti (alpha)');

% alpha orientations at the triple points
tpAlpha = grains(tP.grainId).meanOrientation;

% Compute all beta variants for the adjacent grains. This will result in a
% n x 3 x number_of_variants table.
betaVariants = reshape(tpAlpha * inv(variants(alpha2beta)),[size(tpAlpha,1),3,6]);

% Check whether the variants at the triple points are compatible, i.e.,
% whether we find a betaOrientation which matches one of the variants of
% all three adjacent grains. To this end we compute the disorientation
% angle with respect to all combinations

mis12V = zeros(size(tpAlpha,1),6,6,6);
mis13V = mis12V;
mis23V = mis12V;
for i1=1:6
  for i2 = 1:6
    progress((i1-1)*6+i2,36)
    for i3 = 1:6      
      mis12V(:,i1,i2,i3) = angle(betaVariants(:,1,i1),betaVariants(:,2,i2));
      mis13V(:,i1,i2,i3) = angle(betaVariants(:,1,i1),betaVariants(:,3,i3));
      mis23V(:,i1,i2,i3) = angle(betaVariants(:,2,i2),betaVariants(:,3,i3));
    end
  end
end
progress(36,36);
%

% Ideally, we would like to find i1, i2, i3 such that all the
% disorientation angles mis12V(:,i1,i2,i3), mis13V(:,i1,i2,i3) and
% mis23V(:,i1,i2,i3) all small. One way to do this is to find the minimum
% of the sum
misV = reshape(sqrt(mis12V.^2 + mis13V.^2 + mis23V.^2),[],6*6*6) / 3;

% take the minimum
[minAngle,i123] = min(misV,[],2);

% the ids of the best fitting variants can now be computed by
[i1,i2,i3] = ind2sub([6 6 6],i123);

figure(2)
clf
histogram(min(10,minAngle./degree),30)

%%

figure(1)
clf
ipfKey = ipfHSVKey(csAlpha);
ipfKey.inversePoleFigureDirection = xvector;
color = ipfKey.orientation2color(ebsd('Ti (alpha)').orientations);
plot(ebsd('Ti (alpha)'),color)
hold on
plot(grains.boundary,'linewidth',2)
hold off


hold on
plot(tP,minAngle./degree,'MarkerEdgecolor','none','MarkerSize',10)
mtexColorMap blue2red
mtexColorbar
caxis([0,2])
hold off



%% Decide which triple points we shall take for merging

% consistent triple points are those with a very small misfit
consistenTP = minAngle < 5 * degree;

% however it might happen, that one grain gets different votes for its
% variant from different grains
I123 = [i1,i2,i3];
consistenGrain = ~accumarray(tP(consistenTP).grainId(:),...
  reshape(I123(consistenTP,:),[],1),[max(grains.id) 1],@(x) ~equal(x));

display(['consistent / inconsistent triplepoints: ',xnum2str(sum(consistenTP)),'/',xnum2str(sum(~consistenTP))]);
display(['consistent / inconsistent grains: ',xnum2str(sum(consistenGrain)), '/' xnum2str(sum(~consistenGrain))]);

figure(1)
hold on
plot(tP(consistenTP),'MarkerSize',3,'MarkerFaceColor','w','MarkerEdgeColor','w')
plot(tP(consistenTP & any(ismember(tP.grainId,find(~consistenGrain)),2)),'MarkerSize',3,'MarkerFaceColor','r','MarkerEdgeColor','r')
hold off

%%

% here we simply remove triple points corresponding to incosistent grains
% one could also look for majority votes
consistenTP = consistenTP & ~any(ismember(tP.grainId,find(~consistenGrain)),2);

% store the variant id within the grains such that we can make use of them
% during merging
grains.prop.variantId = accumarray(tP(consistenTP).grainId(:),...
  reshape(I123(consistenTP,:),[],1),[max(grains.id) 1],@(x) x(1));

text(grains,xnum2str(grains.variantId,'cell'))


%%

% do merging - this takes some time but can be speed up significantly
[grainsM, parentId] = merge(grains,tP(consistenTP),...
  'calcMeanOrientation',@(grains) mergeChildsOris(grains,inv(variants(alpha2beta)).'));

% update grainId in the ebsd map
ebsd('indexed').grainId = parentId(grains.id2ind(ebsd('indexed').grainId));


%%

figure(1)
clf
ipfKey = ipfHSVKey(csAlpha);
ipfKey.inversePoleFigureDirection = xvector;
color = ipfKey.orientation2color(ebsd('Ti (alpha)').orientations);
plot(ebsd('Ti (alpha)'),color)
hold on
plot(grainsM.boundary,'linewidth',3)
hold off


%% Step 2: Merge grains with the same orientation
% after step 1 it may happen that we have grains with a common grain
% boundary and very similar orientation -> merge those

% find all neighbouring beta - beta grains
gB = grainsM.boundary('Ti (beta)','Ti (beta)');
grainPairs = unique(gB.grainId,'rows');

% extract the meanorientations
oriPairs = grainsM(grainPairs).meanOrientation;

% and merge if mean orientation difference is below a threshold
doMerge = angle(oriPairs(:,1),oriPairs(:,2)) < 5*degree;

% peform merge
[grainsM,parentId] = merge(grainsM,grainPairs(doMerge,:),...
  'calcMeanOrientation');

display(['merged grains: ' xnum2str(sum(doMerge))]);

% update grainId in the ebsd map
ebsd('indexed').grainId = parentId(ebsd('indexed').grainId);

%%

figure(1)
clf
ipfKey = ipfHSVKey(csAlpha);
ipfKey.inversePoleFigureDirection = xvector;
color = ipfKey.orientation2color(ebsd('Ti (alpha)').orientations);
plot(ebsd('Ti (alpha)'),color)
hold on
plot(grainsM.boundary,'linewidth',2)
hold off



%% Step 3: Merge Alpha - Beta
% after step 2 we have quite some beta grains and we continue to merge
% these beta grains with the remaining alpha grains if they have the
% alpha2beta misorientation relation ship within a certain threshold

% find all neighbouring alpha - beta grains
gB = grainsM.boundary('Ti (alpha)','Ti (Beta)');
grainPairs = unique(gB.grainId,'rows');

% extract the corresponding meanorientations
oriAlpha = grainsM(grainPairs(:,1)).meanOrientation;
oriBeta = grainsM(grainPairs(:,2)).meanOrientation;

% and merge if misorientation is close to the alpha2beta misorientation
doMerge = angle(inv(oriBeta) .* oriAlpha,alpha2beta) < 5*degree;

display(['number of grains to merge: ', xnum2str(sum(doMerge))]);

% peform merge
[grainsM, parentId] = merge(grainsM,grainPairs(doMerge,:),...
  'calcMeanOrientation',@(grains) mergeChild2Parent(grains,inv(alpha2beta)));


% update grainId in the ebsd map
ebsd('indexed').grainId = parentId(ebsd('indexed').grainId);

% Important: repeat this step until the number of grains does not change anymore
% (approx. 5 times)

%%

figure(1)
clf
ipfKey = ipfHSVKey(csAlpha);
ipfKey.inversePoleFigureDirection = xvector;
color = ipfKey.orientation2color(ebsd('Ti (alpha)').orientations);
plot(ebsd('Ti (alpha)'),color)
hold on
plot(grainsM.boundary,'linewidth',4)
hold off

%%

plot(grainsM('Ti (beta)'),grainsM('Ti (beta)').meanOrientation)


%% Plot Result
% as Z - inverse pole figure map

plot(grainsM('Ti (beta)'),grainsM('Ti (beta)').meanOrientation,'linewidth',2)
hold on
%plot(grainsM('Ti (alpha)'),grainsM('Ti (alpha)').meanOrientation,'linewidth',1)
hold off

%%
% as Y - inverse pole figure map

ipfKey = ipfColorKey(grainsM('Ti (beta)'))
ipfKey.inversePoleFigureDirection = vector3d.Y;

plot(grainsM('Ti (beta)'),ipfKey.orientation2color(grainsM('Ti (beta)').meanOrientation),'linewidth',2)

%% Reconstruct beta orientations in EBSD map

% consider only original alpha pixels that now belong to beta grains
isNowBeta = full(grainsM.phaseId(ebsd('Ti (alpha)').grainId) == 2);

% compute beta orientation
oriBeta = calcParent(ebsd('Ti (alpha)').orientations(isNowBeta),...
  grainsM(ebsd('Ti (alpha)').grainId(isNowBeta)).meanOrientation,inv(alpha2beta));

% set beta orientation and new phase
ebsd('Ti (alpha)').rotations(isNowBeta) = rotation(oriBeta);
ebsd('Ti (alpha)').phaseId(isNowBeta) = 2;

%% Plot the reconstructed beta phase on the ebsd grid

% the beta phase
plot(ebsd('Ti (beta)'),ebsd('Ti (beta)').orientations)

% may be the alpha phase as well
hold on
%plot(ebsd('Ti (alpha)'),ebsd('Ti (alpha)').orientations)
hold off

%% Perform Grain reconstruction on the reconstructed beta phase

[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',7.5*degree);

% remove all the small grains
ebsd = ebsd(grains(grains.grainSize > 3));

% redo grain reconstruction
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',7.5*degree);

% smooth the grains a bit
grains = smooth(grains,5);

% plot the grain boundaries
hold on
plot(grains.boundary,'lineWidth',3)
hold off


%%
% At this point you might go back to step 3 and repeat the whole procedure

grainsM = grains;

%%


function meanParent = mergeChild2Parent(grains,parent2child)
% compute the beta orientation from a list of consistent alpha and beta orientations

parentId = grains.phaseId == 2;
childId = grains.phaseId == 3;

% first compute a mean of all involved parent grains
oriBeta = grains(parentId).meanOrientation;
meanParent = mean(oriBeta,'weights',grains.grainSize(parentId));

% compute parent orientations from child orientations
oriChild = grains(childId).meanOrientation;
oriParent = calcParent(oriChild,meanParent,parent2child);

% take the mean
meanParent = mean([meanParent;oriParent],'weights',...
  [sum(grains.grainSize(parentId));grains.grainSize(childId)]);

end

%%

function meanParent = mergeChildsOris(grains,parent2child)
% compute the beta orientation from a list of consistent alpha orientations

% compute parent orientations from child orientations
oriChild = grains.meanOrientation;

oriParent = oriChild .* parent2child(grains.prop.variantId);

% take the mean
meanParent = mean(oriParent,'weights',grains.grainSize);
  
end

