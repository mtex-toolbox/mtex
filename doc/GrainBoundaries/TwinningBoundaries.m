%% Twinning Analysis
%
%%
% In this section we consider the analysis of twining. Therefore lets start
% by importing some Magnesium data and reconstructing the grain structure.

% load some example data
mtexdata twins

% segment grains
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',5*degree);

% remove two pixel grains
ebsd(grains(grains.grainSize<=2)) = [];
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',5*degree);

% smooth them
grains = grains.smooth(5);

% visualize the grains
plot(grains,grains.meanOrientation)

% store crystal symmetry of Magnesium
CS = grains.CS;

%%
% Next we extract the grainboundaries and save them to a separate variable

gB = grains.boundary

%%
% The output tells us that we have 3219 Magnesium to Magnesium boundary
% segments and 606 boundary segements where the grains are cut by the
% scanning boundary. To restrict the grain boundaries to a specific phase
% transistion you shall do

gB_MgMg = gB('Magnesium','Magnesium')

%% Properties of grain boundaries
%
% A variable of type grain boundary contains the following properties
%
% * misorientation
% * direction
% * segLength
%
% These can be used to colorize the grain boundaries. By the following
% command, we plot the grain boundaries colorized by the misorientation
% angle

plot(gB_MgMg,gB_MgMg.misorientation.angle./degree,'linewidth',2)
mtexColorbar

%%
% We observe that we have many grain boundaries with misorientation angle
% larger than 80 degree. In order to investigate the distribution of
% misorientation angles further we have the look at a misorientation angle
% histogramm.

close all
histogram(gB_MgMg.misorientation.angle./degree,40)
xlabel('misorientation angle (degree)')

%%
% Lets analyze the misorientations corresponding to the peak around 86
% degree in more detail. Therefore, we consider only those misorientations
% with misorientation angle between 85 and 87 degree

ind = gB_MgMg.misorientation.angle>85*degree & gB_MgMg.misorientation.angle<87*degree;
mori = gB_MgMg.misorientation(ind);

%%
% and observe that when plotted in axis angle domain they form a strong
% cluster close to one of the corners of the domain.

scatter(mori)

%%
% We may determin the center of the cluster and check whether it is close
% to some special orientation relation ship

% determine the mean of the cluster
mori_mean = mean(mori,'robust')

% determine the closest special orientation relation ship
round2Miller(mori_mean)

%%
% Bases on the output above we may now define the special orientation
% relationship as

twinning = orientation.map(Miller(0,1,-1,-2,CS),Miller(0,-1,1,-2,CS),...
  Miller(2,-1,-1,0,CS),Miller(2,-1,-1,0,CS))

%%
% and observe that it is actually a rotation about axis (-1210) and angle
% 86.3 degree

% the rotational axis
round(twinning.axis)

% the rotational angle
twinning.angle / degree

%%
% Next, we check for each boundary segment whether it is a twinning boundary,
% i.e., whether boundary misorientation is close to the twinning.

% restrict to twinnings with threshold 5 degree
isTwinning = angle(gB_MgMg.misorientation,twinning) < 5*degree;
twinBoundary = gB_MgMg(isTwinning)

% plot the twinning boundaries
plot(grains,grains.meanOrientation)
%plot(ebsd('indexed'),ebsd('indexed').orientations)
hold on
%plot(gB_MgMg,angle(gB_MgMg.misorientation,twinning),'linewidth',4)
plot(twinBoundary,'linecolor','w','linewidth',4,'displayName','twin boundary')
hold off

%%
% A common next step is to reconstruct the grain structure parent to
% twinning by merging the twinned grains. This is explained in detail in
% the section <GrainMerge.html Merging Grains>.
