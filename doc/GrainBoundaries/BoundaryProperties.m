%% Grain Boundary Properties
%
%%
% In this section we discus geometric properties that can be derived from
% grain boundaries. Lets start by importing some EBSD data and computing
% grain boundaries.

% load some example data
mtexdata twins
ebsd.prop = rmfield(ebsd.prop,{'error','bands'});

% detect grains
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'));

% smooth them
grains = grains.smooth;

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
% || |misorientation| || between |ebsdId(:,1)| and  |ebsdId(:,2)| || || ||
% || |componentId|    || connected component id || |componentSize| || connected component size ||
%
% The first three properties refer to $N \times 2$ matrices where $N$ is
% the number of boundary segments. Each row of these matrices contains the
% information about the EBSD data, and grain data on both sides of the
% grain boundary. To illustrate this consider the grain boundary of one
% specific grain

gB8 = grains(8).boundary

%%
% This boundary consists of 8 segemts and hence ebsdId forms a 8x2 matrix

gB8.ebsdId

%%
% It is important to understand that the *id* is not neccesarily the same
% as the index in the list. In order to index an variable of type EBSD by
% id and not by index the following syntax has to be used

ebsd('id',gB8.ebsdId)

%%
% Similarly

gB8.grainId

%%
% results in 8x2 matrix indicating that grain 8 is an inclusion of grain
% 21.

plot(grains(8),'FaceColor','DarkBlue','micronbar','off')
hold on
plot(grains(21),'FaceColor','LightCoral')
hold off

%% Grain boundary misorientations
%
% The grain boundary misorientation defined as the misorientation between
% the orientations corresponding to ids in first and second column of
% ebsdId, i.e. following two commands should give the same result

gB8(1).misorientation

inv(ebsd('id',gB8.ebsdId(1,2)).orientations) .* ebsd('id',gB8.ebsdId(1,1)).orientations

%%
% Note that in the first result the antipodal flag is true while it is
% false in the second result. 
%
% Obviously, misorientations of a list of grain boundaries can only be
% extracted if all of them have the same type of phase transition. Let us
% consider only Magnesium to Magnesium grain boundaries, i.e., ommit all
% grain boundaries to an not indexed region. 

gB_Mg = gB('Magnesium','Magnesium')

%%
% Then the misorientation angles can be plotted by

plot(gB_Mg,gB_Mg.misorientation.angle./degree,'linewidth',3)
mtexColorbar('title','misorientation angle (°)')

%% Geometric properties
% The *direction* property of the boundary segments is usefull when
% checking for tilt and twist boundaries, i.e., when we want to compare the
% misorientation axis with the interface between the grains

% compute misorientation axes in specimen coordinates
ori = ebsd('id',gB_Mg.ebsdId).orientations;
axes = axis(ori(:,1),ori(:,2),'antipodal')

% plot the angle between the misorientation axis and the boundary direction
plot(gB_Mg,angle(gB_Mg.direction,axes),'linewidth',3)

%%
% We observe that the angle is quite oscilatory. This is because of the
% stair casing effect when reconstructing grains from gridded EBSD data.
% The weaken this effect we may average the segment directions using the
% command <grainBoundary.calcMeanDirection.html calcMeanDirection>

% plot the angle between the misorientation axis and the boundary direction
plot(gB_Mg,angle(gB_Mg.calcMeanDirection(4),axes),'linewidth',3)

%%
% The *midPoint* property is usefull when  TODO:


%%
% While the command

length(gB_Mg)

%%
% gives us the total number of all Magnesium to Magnesium grain boundary
% segements the following command gives us its their total length in um.

sum(gB_Mg.segLength)


%% Connected components
% 
% TODO: explain this in more detail

components = unique(gB.componentId);
for cId = components.'
  plot(gB(gB.componentId == cId),'lineColor',ind2color(cId),...
    'micronbar','off','lineWidth',3,'displayName',num2str(cId))
  hold on
end
hold off




