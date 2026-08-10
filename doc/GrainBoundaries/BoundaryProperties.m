%% Grain Boundary Properties
%
%%
% In this section we discus geometric properties that can be derived from
% grain boundaries. Lets start by importing some EBSD data and computing
% grain boundaries.

% load some example data
mtexdata twins silent
ebsd.prop = rmfield(ebsd.prop,{'error','bands'});

% detect grains
[grains,ebsd] = calcGrains(ebsd,'angle',10*degree,'minPixel',3);

% smooth them - this page reads ebsdId per segment, which only means something
% as long as every segment still runs between one pair of pixels, so the
% coarsening and resampling steps are switched off
grains = grains.smoothBoundary(5,'noSimplify','noRefine');

% visualize the grains
plot(grains,grains.meanOrientation)

% extract all grain boundaries
gB = grains.boundary;

hold on
plot(gB,'LineWidth',2)
hold off

%% Property overview
%
% A variable of type <grainBoundary.grainBoundary.html grainBoundary>
% contains the following properties
%
% || |ebsdId|         || neighboring pixel ids || |phaseId| || neighboring phase ids ||
% || |grainId|        || neighboring grain ids || |F| || vertices ids of the segments ||
% || <grainBoundary.segLength.html |segLength|> || length of each segment || |direction| || direction of each segment ||
% || |midPoint|       || mid point of the segment || <grainBoundary.curvature.html |curvature|> || curvature of each segment ||
% || |misorientation| || between |ebsdId(:,1)| and  |ebsdId(:,2)| || |triplePoints| || list of all triple points ||
% || |componentId|    || connected component id || |componentSize| || connected component size ||
%
% The first three properties refer to $N \times 2$ matrices where $N$ is
% the number of boundary segments. Each row of these matrices contains the
% information about the EBSD data, and grain data on both sides of the
% grain boundary. To illustrate this consider the grain boundary of one
% specific grain

gB4 = grains(4).boundary

%%
% This boundary consists of 8 segments and hence ebsdId forms a 8x2 matrix

gB4.ebsdId

%%
% It is important to understand that the *id* is not necessarily the same
% as the index in the list. In order to index an variable of type EBSD by
% id and not by index the following syntax has to be used

ebsd('id',gB4.ebsdId)

%%
% Similarly

gB4.grainId

%%
% results in 8x2 matrix indicating that grain 4 is a tiny inclusion of
% grain 15.

plot(grains(4),'FaceColor','DarkBlue','micronbar','off')
hold on
plot(grains(15),'FaceColor','LightCoral')
hold off

%% Grain boundary misorientations
%
% The grain boundary misorientation defined as the misorientation between
% the orientations corresponding to ids in first and second column of
% ebsdId, i.e. following two commands should give the same result

gB4(1).misorientation

inv(ebsd('id',gB4.ebsdId(1,2)).orientations) .* ebsd('id',gB4.ebsdId(1,1)).orientations

%%
% Note that in the first result the antipodal flag is true while it is
% false in the second result. 
%
% Obviously, misorientations of a list of grain boundaries can only be
% extracted if all of them have the same type of phase transition. Let us
% consider only Magnesium to Magnesium grain boundaries, i.e., omit all
% grain boundaries to an not indexed region. 

gB_Mg = gB('Magnesium','Magnesium')

%%
% Then the misorientation angles can be plotted by

plot(gB_Mg,gB_Mg.misorientation.angle./degree,'linewidth',4,'micronbar','off')
mtexColorbar('title','misorientation angle (°)')

%% Geometric properties
% The |direction| property of the boundary segments is useful when
% checking for tilt and twist boundaries, i.e., when we want to compare the
% misorientation axis with the interface between the grains

% compute misorientation axes in specimen coordinates
ori = ebsd('id',gB_Mg.ebsdId).orientations;
axes = axis(ori(:,1),ori(:,2),'antipodal')

% plot the angle between the misorientation axis and the boundary direction
plot(gB_Mg,angle(gB_Mg.direction,axes),'linewidth',4,'micronbar','off')

%%
% We observe that the angle is quite oscillatory. This is because of the
% stair casing effect when reconstructing grains from gridded EBSD data.
% The weaken this effect we may average the segment directions using the
% command <grainBoundary.calcMeanDirection.html |calcMeanDirection|>

% plot the angle between the misorientation axis and the boundary direction
plot(gB_Mg,angle(gB_Mg.calcMeanDirection(4),axes),'linewidth',4,'micronbar','off')

%%
% The *midPoint* property is useful when  TODO:

%%
% While the command <grainBoundary.length.html |length(gB_Mg)|> gives the
% total number of all Magnesium to Magnesium grain boundary segments the
% command <grainBoundary.segLength.html |segLength(gB_Mg)|> gives the
% length of each segment in µm. The total length of all Magnesium to
% Magnesium grain boundary segments is hence 

sum(gB_Mg.segLength)

%% Connected components
% 
% When analyzing the topology of boundary networks connected components of
% certain subsets of boundaries are of interest. Using the
% commands|gB.componentId| and |gB.componentSize| we are able to
% separate the boundary network into groups of connected components and
% analyze them separately. We do so below at the example of twin boundaries
% which we first colorize according to length.

CS = ebsd.CS;
twinning = orientation.map(Miller(1,-1,0,1,CS),Miller(1,0,-1,-1,CS),...
  Miller(0,1,-1,1,CS,'uvw'),Miller(1,-1,0,1,CS,'uvw'))

gBTwin = gB(gB.isTwinning(twinning));

plot(grains,grains.meanOrientation,'faceAlpha',0.25,'micronbar','off')

hold on
plot(gBTwin,gBTwin.componentSize,'lineWidth',4)
hold off
mtexColorbar

%%
% Next we compute how curvy each twin boundary component is, by dividing it
% spatial extension by its total length. This measure has proven to be
% useful to tell apart misindexing due to pseudosymmetries and true twin
% boundaries.

numComponents = max(gBTwin.componentId);
xmax = accumarray(gBTwin.componentId,gBTwin.midPoint.x,[numComponents,1],@max);
ymax = accumarray(gBTwin.componentId,gBTwin.midPoint.y,[numComponents,1],@max);
xmin = accumarray(gBTwin.componentId,gBTwin.midPoint.x,[numComponents,1],@min);
ymin = accumarray(gBTwin.componentId,gBTwin.midPoint.y,[numComponents,1],@min);

ext = sqrt((xmax-xmin).^2+(ymax-ymin).^2);
len = accumarray(gBTwin.componentId,gBTwin.segLength,[numComponents,1],@sum);
value = ext ./ len;

plot(grains,grains.meanOrientation,'faceAlpha',0.25)
hold on
plot(gBTwin,value(gBTwin.componentId),'lineWidth',4)
hold off
mtexColorbar
mtexColorMap blue2red

%%
