%% Twist and Tilt Boundaries
% Explains how to analyze twist and tilt grain boundaries
%
%% Open in Editor
%
%% Contents
%
%% Theory
%
%

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
grains = smooth(grains,5)

% consider only the very big grains
grains = grains(grains.grainSize>100,'fo');

%%
% Colorize the orientations according to their misorientation axis / angle
% with respect to the grains mean orientation


% sett the color key
oM = axisAngleColorKey(ebsd('f').CS);

% set reference orientation to be the grain mean orientation
oM.oriRef = grains{ebsd(grains).grainId}.meanOrientation;

% plot orientations according to this color key
plot(ebsd(grains),oM.orientation2color(ebsd(grains).orientations),'micronbar','off')

% plot grain boundaries
hold on
plot(grains('f').boundary,'lineWidth',2)

% plot grain index
text(grains('f'),arrayfun(@num2str,1:length(grains),'uniformOutput',false),'FontSize',18)


% mark one specific grain
ind = 136;
plot(grains(ind).boundary,'lineColor','red','lineWidth',3)
hold off

%%
% Lets restrict ourself to one specific grain and investigate its
% microtexture in more detail.

% restrict the 
ebsd = ebsd(grains(136));
%ebsd = ebsd(ebsd.inpolygon([3000,8500,2700,-3100]));

% and denoise a little and fill
f = halfQuadraticFilter;
f.alpha =0.05;
f.threshold=1.5*degree;

ebsd = smooth(ebsd,f,grains,'fill');
ebsd = ebsd('indexed')

%%

oM.oriRef = mean(ebsd.orientations);
plot(ebsd,oM.orientation2color(ebsd.orientations),'micronbar','off')

% plot grain boundaries
hold on
plot(grains(ind).boundary,'lineWidth',2)
hold off

%% Low angle subgrain boundaries
% Since we want to investiage the microstructure of the 


[grains, ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',1.5*degree,'boundary','tight')

grains = smooth(grains,5)

% gather all subgrain boundaries
gbfo = [grains.boundary('f','f') grains.innerBoundary('f','f')];

% colorize orientation according to their misorientation to the meanorientation
plot(ebsd,oM.orientation2color(ebsd.orientations),'micronbar','off')
hold on

% colorize subgrain boundaries according to their misorientation angle
plot(gbfo,gbfo.misorientation.angle./degree,'lineWidth',6)
plot(grains.boundary('notIndexed'),'lineWidth',3)
hold off
mtexColorbar('Title','Misorientation angle [\circ]','locacation','southoutside')
mtexColorMap blue2red

%% The misorientation axes in crystal coordinats
% Our next goal is to investiage the misorientation axes at the subgrain
% boundaries. Lets start by plotting them with respect to the crystal
% coordinate system while colorizing them according to the misorientatio
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

ori_boundary = ebsd(gbfo.ebsdId).orientations

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

% First, we plot some crytsal directions of the grain in a pole figure
% so we understand the orientation of the grain a little better
close all
h= Miller({1,0,0},{0,1,0},{0,0,1},ebsd.CS);
ori = ebsd.orientations;
plotPDF(ori,oM.orientation2color(ori),h,'MarkerSize',5)

%%
% now we plot the grain with subboundaries colorcoded with the direction mapping 
%  according to the misorientation axes in crystal coordinates

plot(ebsd,oM.orientation2color(ori),'faceAlpha',0.3)
hold on
plot(gbfo,'linewidth',6)
plot(gbfo,colC,'linewidth',4)
hold off
mtexTitle('misor crystal')

%%
nextAxis

% now we add the grain with subboundaries colorcoded with the direction mapping 
%  according to the misorientation axes in specimen coordinates
plot(ebsd('f'),ecol,'faceAlpha',0.3)
hold on
plot(gbfo,colS,'linewidth',2)
hold off
mtexTitle('misor specimen')

nextAxis
nextAxis

% now we plot the  direction mapping and the misorientation axes in crystal coordinates
plot(omC)
hold on
plot(axC,'MarkerSize',3,'MarkerFaceColor','k','antipodal','fundamentalRegion')
hold off
mtexTitle('crystCC')

% and the  direction mapping and the misorientation axes in specimen coordinates
% and misorientation axes in specimen coordinates
nextAxis
plot(omS,'xAxisDirection','east','zAxisDirection','intoplane')
hold on
plot(axS,'MarkerSize',3,'MarkerFaceColor','k','antipodal','fundamentalRegion')
hold off
mtexTitle('specCC')


nextAxis
nextAxis

% It might be interesintg to understand which misorientation axis in 
% crystal coordiantes corresponds to which direction in specimen
% coordiantes.
% So, we can plot the misorientation axes in crystal coordinates but
% colorcoded for specimen coordinates and vice versa.

plot(axC,colS,'antipodal','fundamentalRegion')
mtexTitle('misorCryst-spCC')


nextAxis
plot(axS,colC,'antipodal','fundamentalRegion')
mtexTitle('misorSp-crystCC')

% and we can add the traces of some crystallographic planes
traces=mean(ebsd('f').orientations*h);
hold on
circle(traces(1),'lineStyle','--','lineColor','b')
hold on
circle(traces(2),'lineStyle',':','lineColor','g')
hold on
circle(traces(3),'lineStyle','-.','lineColor','r')
hold off

% 'shape' the figure
f=gcm; f.layoutMode='user'; f.ncols=3; f.nrows=4; f.drawNow;
%%
close 
%% type of boundary
% Sometimes people might be interested to "guess" the type of a low angle
% boundary they have, i.e. interpret the boundary as a subgrain boundary and decide
% whether it is a tilt, a twist or some general type of boundary.
% 
% For tilt boundaries, the misorienation axis in specimen coordinates is
% within the boundary, for twist boundaries, the misorientation axis is normal
% to the boundary.
% 
% Since from a 2D EBSD map one can only guess the inclination of a boundary,
% i.e. we only see the trend of the boundary, this cannot be decided for
% all cases.
% 
% One special case would be, if the boundary trend is parallel to a
% misorientation axis in specimen coordinates - which can then be
% interpreted as a a tilt boundary. At the same time, this might not mean
% that other boundaries are not tilt boundaries, but we simply can't
% decide becuase we do not know the true boundary direction in 3D.
% For twist boundaries, ther is no case where we could distinguish a pure
% twist boundary for a mixed one.

% To find possible tilt boundaries, we need to know boundary trend and
% the angle between the boundary trend and the misorientation
% axis, and a threshold angle which we use to define a cone within we
% accept the boundary trend and the misorienation axis to be "parallel"

% For the angle between mean boundary trend and misorienation axis
% we can us md = gbfo.calcMeanDirection(2) for that and plot those as
% quiver, howver for now, we cannot colorcode the quiver plot, so let's use
% smooth grain boundaries
grainsSM =grains.smooth(5);
gbfoSM=[grainsSM.boundary('f','f') grainsSM.innerBoundary('f','f')];

md=gbfoSM.direction;
tA = angle(md,axS,'antipodal');
tT = 15*degree;
tB_ind = tA<tT; % condition for tilt boundary candidate

plot(ebsd('f'),ecol,'faceAlpha',0.3)
hold on
plot(gbfoSM,'linewidth',6)
plot(gbfoSM(tB_ind),'linecolor','r','linewidth',6)
plot(gbfoSM,tA/degree,'linewidth',3)
hold off

nextAxis
plot(axC,tA/degree,'antipodal','fundamentalRegion')
nextAxis
plot(axS,tA/degree,'antipodal','fundamentalRegion')
hold on
circle(traces(1),'lineStyle','--','lineColor','b')
hold on
circle(traces(2),'lineStyle',':','lineColor','g')
hold on
circle(traces(3),'lineStyle','-.','lineColor','r')
hold off
mtexColorbar('title','angle(gbtrend,misorAx)');

% Accordingly, one could interpret two boundaries as tilt boundaries of either
% (100)[001] or a (001)[100] slip system. While both boundaries might 
% theoretically be tilt boundaries as well, the 3D boundary orientation
% is unknown and therefore they cannot be verified as such.

%%
close
%% Now we can do that for the entire sample
mtexdata forsterite
% prepare some data that might look interesting
[grains, ebsd.grainId, ebsd.mis2mean]=calcGrains(ebsd);
ebsd=ebsd(grains(grains.grainSize>100 & grains.phase==1)); %discard all small grains and non-forsterite grains fefore labeling
ebsd = ebsd.gridify;
ebsd(isnan(ebsd.phaseId)).phase=0;
[grains, ebsd.grainId, ebsd.mis2mean]=calcGrains(ebsd);
ebsd=ebsd(grains(grains.grainSize>4)); % delete small, nonindexed inside so the can be filled
% and denoise a little bit
f=halfQuadraticFilter;
f.alpha=[0.05 0.05];
f.threshold=1.5*degree;
ebsd=smooth(ebsd,f,'fill');
%%
% calculate boundaries
[grains, ebsd.grainId,ebsd.mis2mean]=calcGrains(ebsd,'angle',1.5*degree)
gbfo=[grains.boundary('f','f') grains.innerBoundary('f','f')]
% only consider boundaries smaller 10 degree
cond = gbfo.misorientation.angle<10*degree;
gbfo = gbfo(cond)

% get the orientations along all 
ori_boundary=ebsd(gbfo.ebsdId).orientations;
axS=axis(ori_boundary(:,1),ori_boundary(:,2));
axC=gbfo.misorientation.axis;

% smooth grain outlines and select relevant boundaries
grainsSM =grains.smooth(5);
gbfoSM=[grainsSM.boundary('f','f') grainsSM.innerBoundary('f','f')];
gbfoSM = gbfoSM(cond)
% get the direction (trend) of the boundary segment
md=gbfoSM.direction;
% get the angle between the boundary trend and the misorientation axis
tA = angle(md,axS,'antipodal');
% plot axes and map
plot(axC,tA/degree,'antipodal','fundamentalRegion') 
nextAxis
plot(axS,tA/degree,'antipodal','fundamentalRegion')

ecol=oM.orientation2color(ebsd('f').orientations); 
plot(ebsd('f'),ecol,'faceAlpha',0.3)
hold on
plot(gbfoSM,tA/degree,'linewidth',4)
hold off
f=gcm; f.layoutMode='user'; f.ncols=2; f.nrows=2; f.drawNow;

% Obviously, the criterion is not very useful for a section cut in a
% standard kinematic reference frame (normal to the foliation,parallel to the 
% lineation) where we would expect rotation axes of tilt boundaries to be
% normal to the the image plane (parallel to the structural/strain
% y-direction, or the vorticity vector, which is the z-direction
% in specimen coordinates).



%%

%% define some color codings (CC)
% get the crystalSymmetry
cs=ebsd('f').CS;

% Colors for the EBSD maps

% another way (compared to earlier) to do a "sharper" colorcoding to display minor orientation
% changes within a grain
% om = ipfHSVKey(cs);
% om.inversePoleFigureDirection=mean(ebsd('f').orientations)*om.whiteCenter;
% om.maxAngle = 8*degree;
% ecol=om.orientation2color(ebsd('f').orientations); % the colors for ebsd

% yet another color coding to show minor orientation changes within a grain
oM = axisAngleColorKey(cs,cs);
oM.oriRef= mean(ebsd('f').orientations);
oM.maxAngle = 3*degree;
% get the colors in a length(ebsd-by-3 matrix)
ecol=oM.orientation2color(ebsd('f').orientations); 

% Colors for the misorientation axes
% in crystal coordinates
%omC=ipdfHSVOrientationMapping(cs); % old syntax
omC=ipfHSVKey(cs);
colC = omC.Miller2Color(axC);

% in specimen coordinates
omS=ipfHSVKey(crystalSymmetry('-1'));
colS = omS.Miller2Color(axS); % new syntax