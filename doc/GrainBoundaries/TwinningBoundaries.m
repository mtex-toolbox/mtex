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
% Now we can extract from the grains its boundary and save it to a separate
% variable

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
plot(twinBoundary,'linecolor','w','linewidth',2,'displayName','twin boundary')
hold off

%% Merge twins along twin boundaries
% Grains that have a common twin boundary are assumed to inherite
% from one common grain. To reconstruct those initial grains we merge grains
% together which have a common twin boundary. This is done by the command
% <grain2d.merge.html merge>. 

[mergedGrains,parentId] = merge(grains,twinBoundary);

% plot the merged grains
%plot(ebsd,ebsd.orientations)
hold on
plot(mergedGrains.boundary,'linecolor','k','linewidth',2.5,'linestyle','-',...
  'displayName','merged grains')
hold off

%% Grain relationships
% The second output argument |paraentId| of <grain2d.merge.html merge> is a
% list with the same size as grains which indicates for each grain into
% which common grain it has been merged. The id of the common grain is
% usually different from the ids of the merged grains and can be found by

mergedGrains(16).id

%%
% Hence, we can find all childs of grain 16 by 

childs = grains(parentId == mergedGrains(16).id)

%% Calculate the twinned area
% We can also answer the question about the relative area of these
% initial grains that have undergone twinning to total area.

twinId = unique(gB_MgMg(isTwinning).grainId);

% compute the area fraction
sum(area(grains(twinId))) / sum(area(grains)) * 100

%%
% The |parentId| may also used to compute properties of the parent grains
% by averaging over the corresponding child grain properties.

mergedGrains.prop.GOS = accumarray(parentId,grains.GOS,size(mergedGrains),@nanmean)

figure(1)
plot(grains,grains.GOS ./ degree)
hold on
plot(mergedGrains.boundary,'lineColor','white','lineWidth',2)
mtexColorbar

figure(2)
plot(mergedGrains,mergedGrains.GOS  ./ degree)
mtexColorbar
caxis([0,1.5])

%%
% The above result is a bit unrealistic since the averages are computed
% between the childs ignoring their relative areas. A better approach is to
% compute a weighted average by the following lines.

% extract GOS and area
childGOS = grains.GOS;
childArea = grains.area;

% compute the weighted averages
mergedGrains.prop.GOS = accumarray(parentId,1:length(grains),size(mergedGrains),...
  @(id) nanmeanWeights(childGOS(id),childArea(id)));

figure(3)
plot(mergedGrains,mergedGrains.GOS  ./ degree)
mtexColorbar
caxis([0,1.5])


%% Setting Up the EBSD Data for the Merged Grains
% Note that the Id's of the merged grains does not fit the grainIds
% stored in the initial ebsd variable. As a consequence, the following
% command will not give the right result

close all
plot(mergedGrains(16).boundary,'linewidth',2)
hold on
plot(ebsd(mergedGrains(16)),ebsd(mergedGrains(16)).orientations)
hold off

%%
% In order to update the grainId in the ebsd variable to the merged grains,
% we proceed as follows.

% copy ebsd data into a new variable to not change the old data
ebsd_merged = ebsd;

% update the grainIds to the parentIds
ebsd_merged('indexed').grainId = parentId(ebsd('indexed').grainId)

%%
% Now the variable |ebsd_merged| can be indexed by the merged grains, i.e.

plot(ebsd_merged(mergedGrains(16)),ebsd_merged(mergedGrains(16)).orientations)
hold on
plot(mergedGrains(16).boundary,'linewidth',2)
hold off

