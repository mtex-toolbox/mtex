%% Tilt and Twist Boundaries
%
%%
% A subgrain boundary is a wall of dislocations. The two ideal end members
% differ in where the misorientation axis points:
%
% * a wall of *edge* dislocations rotates the lattice about an axis in the
% boundary plane - a *tilt boundary*
% * a wall of *screw* dislocations rotates it about the boundary normal - a
% *twist boundary*
%
% Real boundaries can contain both characters. This page computes the
% misorientation axes of the subgrain boundaries in a map and asks what
% they reveal. It ends with what a two-dimensional section can and cannot
% decide.
%
% The page assumes that the map has already been divided into grains.
% <SubGrainBoundaries.html Subgrain Boundaries> explains the two
% reconstruction thresholds used below. <BoundaryProperties.html Grain
% Boundary Properties> introduces the per-segment properties, and
% <MisorientationTheory.html Misorientation Theory> develops the angle-axis
% description.

close all;

% load the map in its specimen plotting frame
plottingConvention.default('y↑→x');
mtexdata forsterite silent

%% Reconstruct and display the subgrain walls
%
% The 1 degree threshold marks an inner boundary. The 15 degree threshold
% separates grains, while |'minPixel'| removes indexed grains containing
% fewer than five measurements.
%
% A raw boundary follows the square measurement grid, so its trace points
% mostly along the grid axes. Smoothing removes that staircase before the
% trace direction is interpreted. The flags |'noSimplify'| and
% |'noRefine'| retain every segment and its link to the two neighboring
% measurements through |ebsdId|.

% reconstruct low- and high-angle boundaries
[grains,ebsd] = calcGrains(ebsd,'threshold',[1*degree,15*degree],...
  'minPixel',5);

% smooth traces without breaking the segment-to-pixel relation
grains = smoothBoundary(grains,5,'noSimplify','noRefine');

% set up the IPF colouring
cKey = ipfColorKey(ebsd('fo').CS.properGroup);
cKey.ipfDirection = yvector;
color = cKey.orientation2color(ebsd('fo').orientations);

% draw the forsterite phase and both kinds of boundary
plot(ebsd('fo'),color,'faceAlpha',0.8,'figSize','large')
hold on
plot(grains.boundary,'lineWidth',2)

% fade the smallest boundary rotations and cap opacity at one
alpha = min(grains('fo').innerBoundary.misorientation.angle / ...
  (5*degree),1);
plot(grains('fo').innerBoundary,'lineWidth',1.5,...
  'edgeAlpha',alpha,'edgeColor','blue');
hold off

%%
% The blue lines are the subgrain boundaries. Rotations of 5 degrees and
% above are fully opaque, while smaller rotations fade towards the map.
% The lines are not scattered at random. They form families across the
% interiors of larger grains, which is the geometry expected of
% dislocation walls.

%% Misorientation axes in crystal coordinates
%
% A reference frame is the coordinate system in which data are expressed.
% The crystal frame is fixed to the lattice basis. In this frame, the axis
% describes a lattice direction. For an ideal tilt wall it is the line
% direction of the edge dislocations that build the wall.

% extract the forsterite subgrain boundaries
subGB = grains('fo').innerBoundary;

% plot their axes in the fundamental sector
plot(subGB.misorientation.axis,'fundamentalRegion','figSize','small')

%%
% The scatter is too dense to show whether any directions are preferred. A
% <DensityEstimation.html density estimate> of the same axes and its
% <S2FunOperations.html#4 local maxima> make the clustering visible.

% estimate and plot the crystal-frame axis density
crystalAxisDensity = calcDensity(subGB.misorientation.axis,...
  'halfwidth',3*degree);
plot(crystalAxisDensity,'figSize','small')
mtexColorbar('title','multiples of uniform density')

% report the two preferred crystal directions
[~,preferredCrystalAxes] = max(crystalAxisDensity,'numLocal',2);
preferredCrystalAxes = round(preferredCrystalAxes)

%%
% The two maxima are (001) and (071): rotations about the c axis and about
% an axis close to b. The clustering itself is the result. A few kinds of
% dislocation wall account for much of the subgrain-boundary population in
% this rock.
%
% Attributing either axis to a slip system is a further step. It is a
% question about the material rather than the data alone. Naming the system
% requires knowing which dislocation systems can be active in olivine under
% the conditions experienced by this rock.

%% A limit of low-angle EBSD axes
%
% The direction of a rotation axis becomes poorly constrained as its angle
% approaches zero. A small orientation error can then produce a large axis
% error. This page therefore uses clusters containing many segments and
% looks for continuity along walls. Do not interpret the axis of one faint,
% one-segment feature as evidence for a dislocation system.

%% Misorientation axes in specimen coordinates
%
% The specimen frame is fixed to the sample and supplies the coordinates of
% this map. Expressed in that frame, the same axes show how the rotations
% associated with the walls are oriented in the specimen. This can relate
% to flow geometry, whereas the crystal-frame axes relate to the lattice.
%
% A misorientation alone is a crystal-to-crystal rotation and contains no
% specimen-frame information. The orientations on both sides of each
% segment are needed, and |ebsdId| leads back to them.

oriGB = ebsd('id',subGB.ebsdId).orientations

%%
% The displayed size has one row per segment and two columns for its two
% sides. <orientation.axis.html |axis|> computes their axes in the specimen
% frame.

axS = axis(oriGB(:,1),oriGB(:,2),'antipodal')

% plot the specimen-frame axes
plot(axS,'MarkerAlpha',0.2,'MarkerSize',2,'figSize','small')

%%
% The flag |'antipodal'| is essential because the sides of a boundary have
% no intrinsic order. Swapping them inverts the misorientation and reverses
% its axis, but the physical axis has not changed.
%
% The scatter still overlaps heavily, so estimate its density as before.

% estimate and plot the specimen-frame axis density
specimenAxisDensity = calcDensity(axS,'halfwidth',5*degree);
plot(specimenAxisDensity,'figSize','small')
mtexColorbar('title','multiples of uniform density')

[~,preferredSpecimenAxis] = max(specimenAxisDensity)
annotate(preferredSpecimenAxis)

%%
% The maximum lies obliquely between TD and ND, with a smaller RD
% component. The specimen history is not supplied with this example, so
% the direction should not be assigned to a loading or flow mechanism here.

%% What a two-dimensional section can decide
%
% A polished section does not reveal the boundary plane. It reveals only
% the *trace*, the line where that plane intersects the section. The
% boundary inclination remains unknown, so tilt and twist cannot generally
% be distinguished from a two-dimensional map. One part of the question
% can still be answered.
%
% A twist boundary has its misorientation axis along the boundary normal.
% That axis is perpendicular to every direction in the plane, including the
% trace. An axis parallel to the trace therefore rules out twist and makes
% tilt likely. An axis perpendicular to the trace leaves tilt, twist, and
% mixed character open because the trace is only one direction in the
% plane.
%
% The map below colours every subgrain segment by the angle between its
% trace and specimen-frame axis. Blue means close to 0 degrees and therefore
% likely tilt. Red means close to 90 degrees and remains undecided. Colour
% saturation follows the misorientation angle, so that the least reliable
% axes fade towards neutral grey.

% compute the angle between each trace and its unoriented axis
traceAxisAngle = angle(subGB.direction,axS)./degree;

% desaturate the smallest rotations without changing their angle hue
traceAxisColor = num2rgb(traceAxisAngle,blue2redColorMap,...
  'range',[0 90]);
traceAxisColor = alpha .* traceAxisColor + (1-alpha) .* 0.65;

plot(ebsd('fo'),color,'faceAlpha',0.5,'figSize','large')
hold on
plot(grains.boundary,'lineWidth',2)
plot(subGB,traceAxisColor,'lineWidth',2)
hold off
mtexColorMap blue2red
setColorRange([0 90])
mtexColorbar('title','axis-trace angle (degrees)')

%%
% Both colours are present. A long, straight subgrain boundary generally
% holds one colour along its length, so its character can be read with more
% confidence. The intervening speckle is different: isolated one- and
% two-segment features can change colour from one segment to the next.
%
% The following calculation makes that difference explicit. It computes
% the standard deviation within every connected component containing at
% least 20 segments, then averages those deviations with segment-count
% weights. The comparison value is the standard deviation over the whole
% map.

isWall = subGB.componentSize >= 20;
[~,~,wallId] = unique(subGB.componentId(isWall));
wallSize = accumarray(wallId,1);
componentScatter = accumarray(wallId,traceAxisAngle(isWall),[],@std);
withinWallScatter = sum(wallSize .* componentScatter) / sum(wallSize);
mapScatter = std(traceAxisAngle);

fprintf('Mean within-wall scatter: %.1f degrees\n',withinWallScatter);
fprintf('Whole-map scatter: %.1f degrees\n',mapScatter);

%%
% The mean within-wall scatter is 19.4 degrees, against 22.5 degrees over
% the map. The difference is modest. Continuity along a long boundary is
% therefore more informative than the map-wide average.
%
% Deciding the red boundaries individually requires their boundary planes,
% which means three-dimensional data. A statistical argument over many
% traces can instead recover a distribution of planes, but not the plane of
% one segment. See <BoundaryNormalDistribution.html Grain Boundary Normal
% Distribution> for that population-level analysis.

%% References
%
% * W. T. Read and W. Shockley,
% <https://doi.org/10.1103/PhysRev.78.275 Dislocation Models of Crystal
% Grain Boundaries>, _Physical Review_ 78 (1950), 275--289. This is the
% classic dislocation model for low-angle boundaries.
% * A. P. Sutton and R. W. Balluffi,
% <https://global.oup.com/academic/product/interfaces-in-crystalline-materials-9780199211067
% Interfaces in Crystalline Materials>, Oxford University Press, 2006.
% Chapter 1 develops the five macroscopic boundary parameters and the tilt
% and twist end members.
% * G. E. Lloyd, A. B. Farmer and D. Mainprice,
% <https://doi.org/10.1016/S0040-1951(97)00115-7 Misorientation Analysis and
% the Formation and Orientation of Subgrain and Grain Boundaries>,
% _Tectonophysics_ 279 (1997), 55--78. The paper combines misorientation
% axes with boundary traces in geological microstructures.
% * D. J. Prior,
% <https://doi.org/10.1046/j.1365-2818.1999.00572.x Problems in Determining
% the Misorientation Axes, for Small Angular Misorientations, Using Electron
% Backscatter Diffraction in the SEM>, _Journal of Microscopy_ 195 (1999),
% 217--225. The paper quantifies the loss of axis precision at small angles.

%% Next
%
% <CSLBoundaries.html CSL Boundaries> is the next page in this chapter and
% classifies special high-angle relationships. For the statistical recovery
% of boundary planes from traces, continue with
% <BoundaryNormalDistribution.html Grain Boundary Normal Distribution>.

%#ok<*NOPTS>
