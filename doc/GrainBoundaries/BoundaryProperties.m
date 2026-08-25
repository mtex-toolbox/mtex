%% Grain Boundary Properties
%
%%
% A boundary segment lies between two measurements, so most of what it knows
% comes in pairs: two pixels, two grains, two phases, and the misorientation
% between them. The rest is geometry - where the segment is, which way it
% runs, how long it is.
%
% || |ebsdId|         || neighboring pixel ids || |phaseId| || neighboring phase ids ||
% || |grainId|        || neighboring grain ids || |F| || vertices ids of the segments ||
% || <grainBoundary.segLength.html |segLength|> || length of each segment || |direction| || direction of each segment ||
% || |midPoint|       || mid point of the segment || <grainBoundary.curvature.html |curvature|> || curvature of each segment ||
% || |misorientation| || between |ebsdId(:,1)| and  |ebsdId(:,2)| || |triplePoints| || list of all triple points ||
% || |componentId|    || connected component id || |componentSize| || connected component size ||

% load some example data
plottingConvention.default('y↑→x');
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

%% The two sides of a segment
%
% |ebsdId|, |grainId| and |phaseId| are $N \times 2$ matrices, one row per
% segment, holding what lies on either side of it. Take the boundary of one
% small grain:

gB4 = grains(4).boundary

%%
% Eight segments, so |ebsdId| is 8 by 2.

gB4.ebsdId

%%
% These are ids, not positions in the list, and the two differ as soon as
% anything has been removed from the map. Indexing by id needs to say so.

ebsd('id',gB4.ebsdId)

%%
% The grain ids on either side tell us something about this grain in
% particular.

gB4.grainId

%%
% Grain 4 has grain 42 on the far side of every one of its segments, which
% is what it means to be an inclusion: it is entirely surrounded by that one
% grain.

plot(grains(4),'FaceColor','DarkBlue','micronbar','off')
hold on
plot(grains(42),'FaceColor','LightCoral')
hold off

%% The misorientation across a segment
%
% The misorientation of a segment is the rotation from the orientation of
% the second pixel to that of the first, so it follows the column order of
% |ebsdId| and can be computed by hand from the two orientations:

gB4(1).misorientation

inv(ebsd('id',gB4.ebsdId(1,2)).orientations) .* ebsd('id',gB4.ebsdId(1,1)).orientations

%%
% The two rotations agree; only the |antipodal| flag differs. A boundary has
% no preferred side, so the misorientation stored on a segment is marked
% antipodal - it and its inverse are treated as one - whereas the
% misorientation computed by hand from two orientations is not.
%
% A list of misorientations only makes sense when every segment in it
% relates the same two phases, which is why one selects a phase pair first.

gB_Mg = gB('Magnesium','Magnesium')

%%
% Their angles, drawn on the map:

plot(gB_Mg,gB_Mg.misorientation.angle./degree,'linewidth',4,'micronbar','off')
mtexColorbar('title','misorientation angle (°)')

%%
% The map is dominated by one angle: half of all segments are within 3
% degrees of 86.3, the misorientation angle of the magnesium twin, and the
% median over all of them is 84 degrees. This specimen is mostly twin
% boundaries, which <TwinningBoundaries.html Twinning> pursues.

%% Which way a segment runs
%
% |direction| is the direction of the segment itself, and comparing it with
% the misorientation axis is how a boundary is classified as tilt or twist -
% see <TiltAndTwistBoundaries.html Twist and Tilt>. The axis has to be
% computed in specimen coordinates, which needs the two orientations rather
% than the stored misorientation.

% compute misorientation axes in specimen coordinates
ori = ebsd('id',gB_Mg.ebsdId).orientations;
axes = axis(ori(:,1),ori(:,2),'antipodal')

% plot the angle between the misorientation axis and the boundary direction
plot(gB_Mg,angle(gB_Mg.direction,axes),'linewidth',4,'micronbar','off')

%%
% The colour flickers from segment to segment along what is one straight
% boundary. That is the staircase: a single segment lies between two pixels
% and so has only a few possible directions, whatever the boundary is really
% doing. <grainBoundary.calcMeanDirection.html |calcMeanDirection|> averages
% the direction over a few neighbouring segments and the flicker goes away.

% plot the angle between the misorientation axis and the boundary direction
plot(gB_Mg,angle(gB_Mg.calcMeanDirection(4),axes),'linewidth',4,'micronbar','off')

%%
% Now a boundary keeps one value along its length and the values differ from
% boundary to boundary, which is the information the flicker was hiding. The
% angles are large - a median of 43 degrees, with only one segment in ten
% below 20 - so the misorientation axes are mostly *not* aligned with the
% traces here.
%
% Be careful with what follows from that. A trace is not a plane: it is the
% one direction of the boundary plane that the section reveals, and the
% inclination is unknown. An axis parallel to the trace does lie in the
% boundary plane and makes a tilt boundary, but an axis at a large angle to
% the trace settles nothing on its own. <TiltAndTwistBoundaries.html Twist
% and Tilt> takes this further.

%% Where a segment is
%
% |midPoint| is the position of a segment as a
% <vector3d.vector3d.html |vector3d|>. It is what one needs to draw
% something at a segment - the misorientation axes above, for instance:

plot(grains,grains.meanOrientation,'faceAlpha',0.3,'micronbar','off')
hold on
quiver(gB_Mg(1:3:end),axes(1:3:end),'color','black','autoScaleFactor',0.6)
hold off

%%
% and equally to select segments by position:

pos = gB_Mg.midPoint;
isTop = pos.y > 30;

plot(grains,'faceAlpha',0.3,'micronbar','off')
hold on
plot(gB_Mg(isTop),'linewidth',3,'lineColor','red')
plot(gB_Mg(~isTop),'linewidth',3,'lineColor','blue')
hold off

%%
% Two lengths are easy to confuse. |length(gB_Mg)| is the number of
% segments, a count, while
% <grainBoundary.segLength.html |segLength(gB_Mg)|> is the length of each
% segment in µm. The total boundary length is the sum of the second:

sum(gB_Mg.segLength)

%% Connected components
%
% A boundary network is more than a bag of segments: segments that touch
% form a boundary, and boundaries that touch form a network. |componentId|
% labels each connected group and |componentSize| gives its size, which is
% what turns a question about single segments into one about whole
% boundaries.
%
% Here on the twin boundaries, which we first pick out by their
% misorientation and colour by the size of the component they belong to.

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
% The 1648 twin segments of this map form 54 components. A twin lamella
% crossing a whole grain is one long component; a handful of segments that
% happen to satisfy the twin relationship somewhere on their own are a short
% one, and being able to tell those apart is what the component id is for.
%
% Straightness can be measured directly: divide the distance between the two
% extreme points of a component by its total length. A single straight
% lamella gives close to 1, a component that meanders or branches much less.

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
% The values run up to 0.97 with a median of 0.70. Note which components
% score low: it is the *large* ones, at a median of 0.52 against 0.71 for
% the rest. A long component here is rarely a single lamella - it is several
% of them meeting inside one grain, and the straight line between its two
% extreme points is nothing it ever follows.
%
% So this measure separates single straight lamellae from branched networks
% rather than twins from misindexing. It is still worth computing for the
% latter, because a few segments that satisfy the twin relationship by
% accident, out of pseudosymmetry, form neither.
