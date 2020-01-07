%% Tilt and Twist Boundaries
%
%% Theory
% If a material deforms through the movement of dislocations, re-
% arrangement of dislocationsto a low-energy configuration may happen
% during deformation (i.e. in slow, geologic deformation) or 
% or afterwards (in many metals). In any case, the arrangement of
% dislocation walls can lead to so-called subgrains boundaries. If such a
% boundary is composed of edge dislocations, it is called a tilt
% boundary and the rotation axis relating both parts of the grain at each
% side can be expected to be within the boudnary plane (ideally parallel to
% the edge dislocation line). If the boundary is composed of screw 
% dislocations, the rotation axis should be normal to the boundary. 
% Between those end-members, there are general boundaries where
% the rotation axis is not easily related to the type of dislocations
% unless further information is available.

%% Data import and grain detection
% Lets start by loading an MTEX standard data set, reconstuct grains and
% grain boundaries

% import data
mtexdata forsterite

% reconstruct grains
[grains, ebsd.grainId] = calcGrains(ebsd);
ebsd = ebsd(grains(grains.grainSize>10));
[grains, ebsd.grainId, ebsd.mis2mean] = calcGrains(ebsd);

% smooth grain boundaries to avoid stair casing effect
grains = smooth(grains,5);

% consider only the very big grains
grains = grains(grains.grainSize>300,'fo')

%%
% Colorize the orientations according to their misorientation axis / angle
% with respect to the grains mean orientation


% sett the color key
colorKey = axisAngleColorKey(ebsd('f').CS);

% set reference orientation to be the grain mean orientation
colorKey.oriRef = grains{ebsd(grains).grainId}.meanOrientation;

% plot orientations according to this color key
plot(ebsd(grains),colorKey.orientation2color(ebsd(grains).orientations),'micronbar','off')

% plot grain boundaries
hold on
plot(grains('f').boundary,'lineWidth',2)

% plot grain index
text(grains('f'),arrayfun(@num2str,1:length(grains),'uniformOutput',false),'FontSize',18)


% mark one specific grain
ind = 73;
plot(grains(ind).boundary,'lineColor','red','lineWidth',3)
hold off

%%
% Lets restrict ourself to one specific grain and investigate its
% microtexture in more detail.

% restrict the 
ebsd = ebsd(grains(ind));

% and denoise a little and fill
F = halfQuadraticFilter;
F.alpha = 1;
F.threshold  = 1.5*degree;

ebsdS = smooth(ebsd,F,'fill',grains(ind));
ebsdS = ebsdS('indexed');

%%

colorKey.oriRef = mean(ebsd.orientations);
plot(ebsdS,colorKey.orientation2color(ebsdS.orientations),'micronbar','off')

% plot grain boundaries
hold on
plot(grains(ind).boundary,'lineWidth',2)
hold off

%% Low angle subgrain boundaries
% Since we want to investiage the microtexture of the low angle
% boundaries, let's segment at a small angle


[subGrains, ebsdS.grainId,ebsdS.mis2mean] = calcGrains(ebsdS,'angle',1.25*degree,'boundary','tight');

subGrains = smooth(subGrains,5);

% gather all subgrain boundaries
gbfo = [subGrains.boundary('f','f') subGrains.innerBoundary('f','f')];

% colorize orientation according to their misorientation to the meanorientation
plot(ebsdS,colorKey.orientation2color(ebsdS.orientations),'micronbar','off')
hold on

% colorize subgrain boundaries according to their misorientation angle
plot(gbfo,gbfo.misorientation.angle./degree,'lineWidth',3)
plot(subGrains.boundary('notIndexed'),'lineWidth',2)
hold off
mtexColorbar('Title','Misorientation angle [\circ]','locacation','southoutside')
mtexColorMap blue2red

%% The misorientation axes in crystal coordinats
% Our next goal is to investiage the misorientation axes at the subgrain
% boundaries. Lets start by plotting them with respect to the crystal
% coordinate system while colorizing them according to the misorientation
% angle.

plot(gbfo.misorientation.axis,gbfo.misorientation.angle./degree,...
  'fundamentalRegion','MarkerEdgeColor','k')
mtexColorMap white2black
mtexColorbar('Title','Misorientation angle [\circ]','locacation','southoutside')

%%
% We observe that the misorientation axes have a strong tendency to be
% perpendicular to [100].


%% The misorientation axis in specimen coordinats
% The computation of the misorientation axis in specimen coordinates is a
% little bit more complicated as it is impossible using only the
% misorientions. In fact we require the adjecent orientations on both sides
% of the subgrain boundaries. We can find those by the command

ori_boundary = ebsdS('id',gbfo.ebsdId).orientations

%%
% which results in a Nx2 matrix of orientations with rows corresponding to
% the boundary segments and the two columns to the both sides of the
% boundary. The misorientation axis in specimen coordinates is now computed
% by

axS = axis(ori_boundary(:,1),ori_boundary(:,2),'antipodal')

%%
% and we may visualize them in a spherical plot using

plot(axS,gbfo.misorientation.angle./degree,'upper','MarkerEdgeColor','k','MarkerSize',10)
mtexColorMap white2black
mtexColorbar('Title','Misorientation angle [\circ]','locacation','southoutside')


%% Colorize low angle boundaries by misorientation axes

% First, we plot some crystal directions of the grain in a pole figure
% so we understand the orientation of the grain a little better
close all
h = Miller({1,0,0},{0,1,0},{0,0,1},ebsd.CS);
ori = ebsdS.orientations;
plotPDF(ori,colorKey.orientation2color(ori),h,'MarkerSize',5)

%%
% now we plot the grain with subboundaries color coded with the direction
% mapping according to the misorientation axes in crystal coordinates


plot(ebsdS,colorKey.orientation2color(ori),'faceAlpha',0.3)
hold on
axisKey = HSVDirectionKey(ori.CS);
color = axisKey.direction2color(gbfo.misorientation.axis);
plot(gbfo,'linewidth',6)
plot(gbfo,color,'linewidth',4)
hold off
mtexTitle('misor crystal')

%%
% Next we plot the grain with subboundaries colorcoded with the direction
% mapping according to the misorientation axes in specimen coordinates

plot(ebsdS,colorKey.orientation2color(ori),'faceAlpha',0.3)
hold on
axisKey = HSVDirectionKey;
color = axisKey.direction2color(axS);
plot(gbfo,'linewidth',6)
plot(gbfo,color,'linewidth',4)
hold off
mtexTitle('misor specimen')


