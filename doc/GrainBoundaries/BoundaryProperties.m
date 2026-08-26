%% Grain Boundary Properties
%
%%
% A grain boundary is stored as short segments between neighbouring EBSD
% measurements that belong to different grains. Most properties come in
% pairs: two pixels, grains, phases, and the misorientation between them.
% The remaining properties describe the segment's geometry and its place in
% the boundary network.
%
% This page assumes that the map has already been divided into grains as in
% <GrainReconstruction.html Grain Reconstruction>.
% <BoundarySelect.html Select Grain Boundaries> covers phase and grain
% selection. <GrainBoundaries.html Grain Boundaries> explains the physical
% meaning of a boundary trace in a two-dimensional section.
%
% || property || meaning || property || meaning ||
% || |ebsdId| || neighbouring pixel IDs || |grainId| || neighbouring grain IDs ||
% || |phaseId| || neighbouring phase IDs || |misorientation| || rotation across the segment ||
% || |F| || endpoint vertex IDs || |direction| || segment direction ||
% || |midPoint| || segment midpoint || <grainBoundary.segLength.html |segLength|> || segment length ||
% || <grainBoundary.curvature.html |curvature|> || signed segment curvature || |triplePoints| || triple-point list ||
% || |chainId| || chain label || |chainSize| || number of segments in the chain ||
% || |arcLength| || distance along the chain || |chainLength| || total chain length ||
% || |isClosed| || whether the chain closes || |junctionId| || junction vertex IDs ||
% || |componentId| || connected-component label || |componentSize| || number of segments in the component ||

close all;

% load the example map in its specimen plotting frame
plottingConvention.default('y↑→x');
mtexdata twins silent;
ebsd.prop = rmfield(ebsd.prop,{'error','bands'});

% reconstruct the grains
[grains,ebsd] = calcGrains(ebsd,'angle',10*degree,'minPixel',3);

%% Preserve the segment-to-pixel relation
%
% This page uses |ebsdId| to inspect the pixel pair beside each segment.
% Boundary simplification and refinement change the segment count, and a
% resampled segment no longer lies between one specific pixel pair.
% The <grain2d.smoothBoundary.html |smoothBoundary|> options
% |'noSimplify'| and |'noRefine'| preserve that relation while smoothing.

grains = grains.smoothBoundary(5,'noSimplify','noRefine');

% draw the grains and overlay the complete boundary network
plot(grains,'FaceColor',[0.9 0.9 0.9],'micronbar','off');
gB = grains.boundary;
hold on;
plot(gB,'lineWidth',2);
hold off;

%%
% The thick black lines show that the boundary is a network of individual
% segments. Each segment separates one pair of neighbouring measurements.

%% The two sides of a segment
%
% |ebsdId|, |grainId|, and |phaseId| are $N \times 2$ matrices. Each row
% records what lies on the two sides of one segment. Consider the boundary
% of one small grain:

gB4 = grains(4).boundary

%%
% The object summary reports eight segments. Its |ebsdId| property is
% therefore an 8 by 2 matrix.

gB4.ebsdId

%%
% These values are measurement IDs, not positions in the current list.
% IDs and list positions differ as soon as measurements have been removed
% from the map. Indexing by ID must say so explicitly.

ebsd('id',gB4.ebsdId)

%%
% The grain IDs on the two sides reveal the local grain arrangement.

gB4.grainId

%%
% Grain 4 has grain 42 on the far side of all eight segments. Grain 4 is
% therefore an inclusion: it is entirely surrounded by one other grain.

plot(grains(4),'FaceColor','DarkBlue','micronbar','off');
hold on;
plot(grains(42),'FaceColor','LightCoral');
hold off;

%%
% The dark-blue inclusion sits wholly inside the coral grain. The plot is
% the spatial counterpart of the repeated pair |[4 42]| above.

%% From segments to chains
%
% A *chain* is a maximal run of segments laid end to end. It runs from one
% junction to the next and never passes through a junction. Every segment
% belongs to exactly one chain. The same two grains lie on its two sides
% along the entire chain.
%
% A *junction* is a vertex where the number of meeting segments is not two.
% It need not be a triple point. For example, the end of a boundary at the
% map rim is a junction but not a point where three real grains meet.
%
% The inclusion boundary reaches no junction and closes onto itself. Its
% eight segments consequently form one closed chain.

chainSummary = table(gB4.chainId(1),gB4.chainSize(1),gB4.isClosed(1),...
  'VariableNames',{'chainId','chainSize','isClosed'})

%%
% |arcLength| is the cumulative length from the start of a chain to the end
% of each segment. |chainLength| repeats the total length on every segment,
% so either property remains aligned with the boundary list during indexing.

%% The misorientation across a segment
%
% A segment's misorientation is the rotation from the orientation of its
% second pixel to that of its first. It follows the column order of
% |ebsdId| and can be reproduced from the two pixel orientations.

gB4(1).misorientation

inv(ebsd('id',gB4.ebsdId(1,2)).orientations) .* ...
  ebsd('id',gB4.ebsdId(1,1)).orientations

%%
% The two rotations agree, but only the stored one has its |antipodal| flag
% set. A boundary has no preferred side, so MTEX treats that rotation and
% its inverse as the same boundary misorientation. The rotation computed
% directly from two ordered orientations retains its direction.
%
% A list of misorientations is meaningful only when every segment relates
% the same two phases. Select the phase pair before analysing angles or
% axes.

gB_Mg = gB('Magnesium','Magnesium');

% plot the misorientation angle on each magnesium boundary segment
moriAngle = gB_Mg.misorientation.angle ./ degree;
plot(gB_Mg,moriAngle,'lineWidth',4,'micronbar','off');
mtexColorbar('title','misorientation angle (°)');

%%
% Long runs share nearly the same colour, as expected for segments along
% one twin boundary. Most non-twin boundaries form the contrasting shorter
% runs.
%
% The dominant magnesium twin has a misorientation angle of 86.3 degrees.
% In this map, 52.8 percent of the magnesium segments are within 3 degrees
% of that angle, and the median angle is 84.3 degrees.

fractionNearTwin = mean(abs(moriAngle - 86.3) < 3)
medianMoriAngle = median(moriAngle)

%%
% The high fraction confirms that this specimen is dominated by twin
% boundaries. <TwinningBoundaries.html Twinning> develops that selection.

%% Which way a segment runs
%
% |direction| is the direction of the segment trace. Its angle to the
% misorientation axis is used when classifying tilt and twist boundaries.
% See <TiltAndTwistBoundaries.html Twist and Tilt>. Compute the axis in
% specimen coordinates from the two pixel orientations. The stored
% misorientation alone no longer retains that specimen-frame information.

% compute misorientation axes in specimen coordinates
ori = ebsd('id',gB_Mg.ebsdId).orientations;
axes = axis(ori(:,1),ori(:,2),'antipodal');

% plot the angle between each axis and its raw segment direction
rawAxisTraceAngle = angle(gB_Mg.direction,axes) ./ degree;
plot(gB_Mg,rawAxisTraceAngle,'lineWidth',4,'micronbar','off');
mtexColorbar('title','axis-to-trace angle (°)');

%%
% The colour flickers along boundaries that are straight on the scale of
% several pixels. This is the pixel staircase: one segment has only a few
% possible grid directions, regardless of the direction of the underlying
% boundary.
%
% <grainBoundary.calcMeanDirection.html |calcMeanDirection|> uses a window
% along each chain and never crosses a junction. An argument of 4 includes
% four neighbouring segments on each side of the segment.

meanDirection = gB_Mg.calcMeanDirection(4);
meanAxisTraceAngle = angle(meanDirection,axes) ./ degree;
plot(gB_Mg,meanAxisTraceAngle,'lineWidth',4,'micronbar','off');
mtexColorbar('title','axis-to-mean-trace angle (°)');

%%
% The flicker is suppressed, so nearby segments on one boundary now carry
% similar colours. The values differ from boundary to boundary, which is
% the information the flicker was hiding. The median angle is 43.2 degrees,
% and 10.5 percent of the segments lie below 20 degrees. The misorientation
% axes are therefore mostly not aligned with the traces in this section.

medianAxisTraceAngle = median(meanAxisTraceAngle)
fractionBelow20 = mean(meanAxisTraceAngle < 20)

%%
% Be careful with what follows from that comparison. A trace is not a plane.
% It is the one direction of the boundary plane revealed by the section,
% while the inclination remains unknown. An axis parallel to the
% trace lies in the boundary plane and identifies a tilt boundary. A large
% angle to the trace settles nothing on its own.
% <TiltAndTwistBoundaries.html Twist and Tilt> takes this further.

%% Where a segment is
%
% |midPoint| gives the segment position as a
% <vector3d.vector3d.html |vector3d|>. It supplies the anchor for quantities
% drawn at a segment, such as the misorientation axes computed above.

plot(grains,'FaceColor',[0.9 0.9 0.9],...
  'faceAlpha',0.3,'micronbar','off');
hold on;
quiver(gB_Mg(1:3:end),axes(1:3:end),...
  'color','black','autoScaleFactor',0.6);
hold off;

%%
% The black arrows are anchored at every third magnesium boundary midpoint.
% Their positions come from the boundary segments, while their directions
% come from the two neighbouring pixel orientations.
%
% The same midpoint property supports spatial selection.

pos = gB_Mg.midPoint;
isTop = pos.y > 30;

plot(grains,'FaceColor',[0.9 0.9 0.9],...
  'faceAlpha',0.3,'micronbar','off');
hold on;
plot(gB_Mg(isTop),'lineWidth',3,'lineColor','red');
plot(gB_Mg(~isTop),'lineWidth',3,'lineColor','blue');
hold off;

%%
% Red marks segments above $y = 30$ micrometres, and blue marks the rest.
% <BoundarySelect.html Select Grain Boundaries> develops this indexing
% pattern for other per-segment properties.
%
% Two lengths are easy to confuse. |length(gB_Mg)| is the number of
% segments, whereas <grainBoundary.segLength.html |segLength(gB_Mg)|>
% contains the length of each segment in µm. Their sum is the total length
% of the selected boundary list.

totalBoundaryLength = sum(gB_Mg.segLength)

%% Chains and connected components
%
% A chain stops at a junction. A *connected component* does not: it contains
% every segment reachable through touching segments, including branches
% through junctions. One component can therefore contain several chains.
%
% |componentId| labels each connected group. |componentSize| repeats the
% number of segments in that component on every row. It is a segment count,
% not a geometric length.
%
% The next example first selects segments close to the magnesium twin
% relation, then colours each segment by the size of its component.

CS = ebsd.CS;
twinning = orientation.map(Miller(1,-1,0,1,CS),Miller(1,0,-1,-1,CS),...
  Miller(0,1,-1,1,CS,'uvw'),Miller(1,-1,0,1,CS,'uvw'));

gBTwin = gB(gB.isTwinning(twinning));

plot(grains,'FaceColor',[0.9 0.9 0.9],...
  'faceAlpha',0.25,'micronbar','off');
hold on;
plot(gBTwin,gBTwin.componentSize,'lineWidth',4);
hold off;
mtexColorbar('title','segments per component');

%%
% Long twin lamellae appear as large connected components. Short isolated
% matches appear in the low end of the colour scale and may be accidental.

numTwinComponents = max(gBTwin.componentId);
componentSummary = table(length(gBTwin),numTwinComponents,...
  'VariableNames',{'twinSegments','components'})

%%
% The 1648 selected segments form 54 components. A twin lamella crossing a
% grain is one long component. A few isolated segments that happen to meet
% the twin criterion form a short component, which is why component labels
% are useful.

%% A component-scale straightness descriptor
%
% A simple straightness descriptor divides the maximum distance between two
% component midpoints by the component's total segment length. Its value
% approaches 1 for one straight lamella. It decreases when a component
% meanders or branches. This is a user-defined descriptor, not a built-in
% MTEX property.

componentId = gBTwin.componentId;
numComponents = max(componentId);
span = zeros(numComponents,1);

for k = 1:numComponents
  x = gBTwin.midPoint.x(componentId == k);
  y = gBTwin.midPoint.y(componentId == k);
  distanceSquared = (x-x.').^2 + (y-y.').^2;
  span(k) = sqrt(max(distanceSquared(:)));
end

componentLength = accumarray(componentId,gBTwin.segLength,...
  [numComponents,1],@sum);
straightness = span ./ componentLength;

plot(grains,'FaceColor',[0.9 0.9 0.9],...
  'faceAlpha',0.25,'micronbar','off');
hold on;
plot(gBTwin,straightness(componentId),'lineWidth',4);
hold off;
mtexColorMap blue2red;
mtexColorbar('title','component straightness');

%%
% Straight components are red, while meandering or branched components are
% blue. The values reach 0.97 and have a median of 0.66.
%
% Define a large component here as one containing more than 50 segments.
% The 13 large components have a median of 0.48, compared with 0.67 for the
% rest. A large component in this map is often several lamellae meeting
% inside one grain, rather than one long straight lamella.

componentSegmentCount = accumarray(componentId,1);
isLarge = componentSegmentCount > 50;
straightnessSummary = table(max(straightness),median(straightness),...
  sum(isLarge),median(straightness(isLarge)),...
  median(straightness(~isLarge)),...
  'VariableNames',{'maximum','median','largeComponents',...
  'largeMedian','otherMedian'})

%%
% This descriptor separates single straight lamellae from branched networks,
% rather than twins from misindexing. It is still worth checking for the
% latter. A few segments selected by accident, for example because of
% pseudosymmetry, form neither a lamella nor a branched twin network.

%% Next
%
% <BoundaryMisorientations.html Misorientations at Grain Boundaries>
% develops the angle and axis on each side of a boundary.
% <BoundaryCurvature.html Curvature> uses chain order for signed curvature,
% and <TriplePoints.html Triple Points> develops the junctions where three
% real grains meet.

%% Further reading
%
% * V. Randle,
% <https://www.routledge.com/The-Measurement-of-Grain-Boundary-Geometry/Randle/p/book/9780367402358
% _The Measurement of Grain Boundary Geometry_>, Institute of Physics,
% 1993. This monograph connects measurable interface geometry with material
% properties.
% * A. P. Sutton, E. P. Banks, and A. R. Warwick,
% <https://doi.org/10.1098/rspa.2015.0442 The five-dimensional parameter
% space of grain boundaries>, _Proceedings of the Royal Society A_ 471
% (2015), 20150442. It formalises the three misorientation and two boundary-
% plane degrees of freedom.
% * G. S. Rohrer,
% <https://doi.org/10.1111/j.1551-2916.2011.04384.x Measuring and
% Interpreting the Structure of Grain-Boundary Networks>, _Journal of the
% American Ceramic Society_ 94 (2011), 633-646. This review connects
% two-dimensional boundary maps with three-dimensional interface networks.
