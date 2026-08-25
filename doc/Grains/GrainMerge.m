%% Merging Grains
%
%%
% A twin is a grain by every rule the reconstruction uses - it is a
% connected region of one phase whose orientation differs from its
% surroundings by far more than any threshold. It is not a grain in the
% sense the material was made: it grew inside a parent grain and belongs to
% it. Merging is how the parent is put back together, and the same operation
% undoes a phase transition, where each parent grain broke up into several
% child orientations.
%
% This page uses twins in magnesium.

% load some example data
plottingConvention.default('y↑→x');
mtexdata twins silent

% segment grains
[grains,ebsd] = calcGrains(ebsd,'angle',5*degree,'minPixel',3);

% smooth them
grains = grains.smoothBoundary(5);
grains = grains('indexed');

% visualize the grains
plot(grains,grains.meanOrientation)

%%
% What tells a twin from a grain boundary is the misorientation across it.
% Twinning maps two specific pairs of crystal directions onto each other, so
% the boundaries that do that within 5 degrees are the twin boundaries.

% define twinning misorientation
CS = grains.CS;
twinning = orientation.map(Miller(0,1,-1,-2,CS),Miller(0,-1,1,-2,CS),...
  Miller(2,-1,-1,0,CS),Miller(2,-1,-1,0,CS));

% extract all Magnesium Magnesium grain boundaries
gB = grains.boundary('Magnesium','Magnesium');

% and check which of them are twinning boundaries with threshold 5 degree
isTwinning = angle(gB.misorientation,twinning) < 5*degree;
twinBoundary = gB(isTwinning)

% plot the twinning boundaries
hold on
plot(twinBoundary,'linecolor','w','linewidth',4,'displayName','twin boundary')
hold off

%%
% Half of all boundary segments in this map, 1406 of 2696, are twin
% boundaries.

%% Merging along a set of boundaries
%
% <grain2d.merge.html |merge|> joins the grains on the two sides of every
% boundary it is given. Handed the twin boundaries, it dissolves the twins
% into their parents and leaves every other boundary standing.

[mergedGrains,parentId] = merge(grains,twinBoundary);

% plot the merged grains
hold on
plot(mergedGrains.boundary,'linecolor','k','linewidth',2.5,'linestyle','-',...
  'displayName','merged grains')
hold off

%%
% 91 grains have become 28. The black lines are the parent grain structure;
% every white line is now inside a parent rather than between two of them.

%% Keeping track of what went where
%
% The second output, |parentId|, says for every original grain which merged
% grain it ended up in - the same bookkeeping that |grainId| does between
% measurements and grains.

mergedGrains(16).id

%%
% So the grains that were merged into number 16 are

childs = grains(parentId == mergedGrains(16).id)

%% Which of the children were the twins
%
% Merging says which grains belong together; it does not say which of them
% is the parent and which the twin. Deciding that is genuinely hard. A
% simple rule that works when twinning has not consumed the grain: cluster
% the children of each parent by orientation, and call the largest cluster
% by area the original grain.

% extract grain area for faster access
gArea = grains.area;

% loop over mergedGrains and determine children that are not twins
isTwin = true(grains.length,1);
for i = 1:mergedGrains.length

  % get child ids
   childId = find(parentId==i);

   % cluster grains of similar orientations
   [fId,center] = calcCluster(grains.meanOrientation(childId),'maxAngle',...
       15*degree,'method','hierarchical','silent');

   % compute area of each cluster
   clusterArea = accumarray(fId,gArea(childId));

   % label the grains of largest cluster as original grain
   [~,fParent] = max(clusterArea);
   isTwin(childId(fId==fParent)) = false;
end

% compute the area fraction of twins
sum(area(grains(isTwin)))/sum(area(grains)) * 100

% visualize the result
close all
plot(grains(~isTwin),'FaceColor','darkgray','displayName','not twin')
hold on
plot(grains(isTwin),'FaceColor','red','displayName','twin')
plot(mergedGrains.boundary,'linecolor','k','linewidth',2,'linestyle','-',...
  'displayName','merged grains')
mtexTitle('twin id')

%%
% Seventeen percent of the mapped area is twin. Note where the red regions
% sit: they are lamellae inside the grey grains, which is what twins look
% like and a check that the rule did something sensible. It would fail on a
% grain more than half consumed by its twin, and there is no way to tell
% from the map alone that it had.

%% Properties of the parent grains
%
% A merged grain has a shape and a size of its own, but its orientation
% properties have to be carried over from the children. |parentId| is the
% index for that, and MATLAB's
% <matlab:doc('accumarray') |accumarray|> does the averaging.

% this averages the GOS of the child grains into the parent grains
mergedGrains.prop.GOS = accumarray(parentId,grains.GOS,size(mergedGrains),@mean);

% visualize the result
close all
plot(grains,grains.GOS ./ degree)
hold on
plot(mergedGrains.boundary,'lineColor','white','lineWidth',2)
mtexTitle('original GOS')

nextAxis(1,2)
plot(mergedGrains,mergedGrains.GOS  ./ degree)
mtexTitle('merged GOS')
mtexColorbar
setColorRange([0,1.5])

%%
% This average counts a two pixel twin as much as the grain that contains
% it, which is rarely what is meant. Weighting each child by its area is one
% line more and gives a parent value the children actually support.

% extract GOS and area
childGOS = grains.GOS;
childArea = grains.area;

% compute the weighted averages
mergedGrains.prop.GOS = accumarray(parentId,1:length(grains),size(mergedGrains),...
  @(id) nanmeanWeights(childGOS(id),childArea(id)));

nextAxis(1,3), hold on
plot(mergedGrains,mergedGrains.GOS  ./ degree)

%%
% The third map is the honest one, and it is mostly brighter than the
% second: in 24 of the 28 parents the weighted value is the larger, by up to
% 0.6 degrees. The reason is that orientation spread grows with grain size,
% so it is the big children that carry the high values and the small twins
% that were dragging the plain average down.

%% Pointing the measurements at the merged grains
%
% The measurements still carry the |grainId| of the original grains, and
% those ids mean something different now. Indexing the map with a merged
% grain therefore returns the wrong measurements, silently.

close all
plot(mergedGrains(22).boundary,'linewidth',2)
hold on
plot(ebsd(mergedGrains(22)),ebsd(mergedGrains(22)).orientations)
hold off

%%
% The data drawn inside that outline is not the data of that grain. Updating
% the ids is a single assignment: replace each measurement's grain id by the
% id of the parent that grain went into.

% copy ebsd data into a new variable to not change the old data
ebsd_merged = ebsd;

% update the grainIds to the parentIds
ebsd_merged('indexed').grainId = parentId(grains.id2ind(ebsd('indexed').grainId))

%%
% Now the merged grains index the map correctly.

plot(ebsd_merged(mergedGrains(22)),ebsd_merged(mergedGrains(22)).orientations)
hold on
plot(mergedGrains(22).boundary,'linewidth',3)
hold off
