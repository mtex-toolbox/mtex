%% Ellipse Based Shape Parameters
%
%%
% Fitting an ellipse to a grain replaces an outline of hundreds of vertices
% by four ingredients: where the grain sits, how long and wide it is, and
% which way it points. These quantities underpin many descriptions of grain
% shape fabric. This page explains how to compute and interpret them, and
% where an ellipse stops being an adequate description.
%
% The page assumes that the grains have been
% <GrainReconstruction.html reconstructed> and that selecting complete
% grains is familiar from <SelectingGrains.html Selecting Grains>.
% <GrainSmoothing.html Grain Smoothing> explains why an outline reconstructed
% from a pixel grid should be smoothed before its shape is measured.
%
% The command is <grain2d.fitEllipse.html |[c,a,b] = grains.fitEllipse|>.
% It returns the centroid |c| and the long and short half axes |a| and |b| as
% vectors. The axis lengths are |norm(a)| and |norm(b)|, and their ratio is
% the <grain2d.aspectRatio.html |aspectRatio|>.
%
% All measurements on this page describe grain sections in the map plane.
% They are not the dimensions or orientations of the full three-dimensional
% grains. A stereological model is needed to infer those quantities.

% load sample EBSD data set
plottingConvention.default('y↑→x');
mtexdata forsterite silent

% reconstruct grains and smooth them
[grains, ebsd] = calcGrains(ebsd,'angle',5*degree,'minPixel',10);

% a grain cut off by the edge of the map has no shape of its own
grains(grains.isBoundary) = [];

grains = smoothBoundary(grains('indexed'),10,'moveTriplePoints');

% plot the grains
plot(grains,'lineWidth',2)

%%
% The map now contains only indexed grains with complete outlines.
% Excluding grains at the map edge prevents truncated sections from being
% mistaken for strongly elongated grains. Smoothing removes most of the
% horizontal and vertical staircase inherited from the measurement grid.
% It does not recover sub-pixel boundary detail.

%% Fitting ellipses
%
% Here are the fitted ellipses of the larger grains, drawn on top of the map.

[c,a,b] = grains(grains.numPixel>200).fitEllipse;

plotEllipse(c,a,b,'lineColor','w','linewidth',2)

%%
% The white ellipses follow the position, elongation, and direction of their
% grains, but not the smaller turns of the outlines. Each ellipse has
% exactly the area of its grain. Its axes come from a principal component
% analysis of the boundary vertices, each weighted by the segments meeting
% there, so they follow how the outline is spread out rather than how the
% enclosed area is.
%
% The fit ignores enclosure loops when finding the principal directions.
% It also says nothing about lobes and inlets: fit an ellipse to a clover
% leaf and the result can be a circle. The option |'boundary'| retains the
% principal directions but scales the ellipse to the grain perimeter
% instead of its area.

%% Long and short axes
%
% The directions alone are available as
% <grain2d.longAxis.html |grains.longAxis|> and
% <grain2d.shortAxis.html |grains.shortAxis|>. They are well defined only
% when the ellipse is far enough from a circle, and the aspect ratio is what
% says how far that is. It is 1 for a circle and grows without bound as the
% ellipse is drawn out.

% visualize the aspect ratio
plot(grains,grains.aspectRatio,'linewidth',2,'micronbar','off')
setColorRange([1,4])
mtexColorbar('title','aspect ratio')

% and on top the long axes
hold on
quiver(grains,grains.longAxis,'Color','white')
hold off

%%
% Every grain gets an axis, including the round grains whose direction means
% little. The arrows may look equally prominent, but |quiver| scales each one
% to the diameter of its own grain. Read the arrows together with the colour:
% the axes of the high-aspect-ratio yellow grains deserve the most weight.

%% Shape preferred orientation
%
% A crystal preferred orientation is an alignment of the lattices. A shape
% preferred orientation, or SPO, is an alignment of the grains as bodies,
% independent of what their lattices do. Both can occur without the other:
% a deformed rock usually has both, a sediment of flat mica flakes has a
% strong SPO and no CPO at all.
%
% A rose diagram asks whether the grain axes agree with one another. Here we
% also ask whether that preferred direction differs between two phases of
% the same rock. A long axis is an axis rather than a directed vector, so
% angles separated by 180 degrees represent the same alignment.

%% Long-axis distribution
%
% A histogram of the long axis directions, one per phase. Each grain is
% weighted by its area, so that large grains count for more than small ones,
% and by |aspectRatio - 1|. A grain whose long axis is barely defined
% therefore contributes almost nothing.

numBin = 50;

close all
subplot(1,2,1)
weights = grains('forsterite').area .* (grains('forsterite').aspectRatio-1);
histogram(grains('forsterite').longAxis,numBin, 'weights', weights)
title('Forsterite')

subplot(1,2,2)
weights = grains('enstatite').area .* (grains('enstatite').aspectRatio - 1);
histogram(grains('enstatite').longAxis,numBin,'weights',weights)
title('Enstatite')

%%
% Neither rose is uniform: both put most of their weight into a similar
% steep direction. Each panel is normalised separately, so this plot compares
% preferred directions and spread, not the total amount of either phase.
%
% A weight defines the question being asked. The area and elongation weights
% above emphasise how much elongated material has each direction. For the
% density estimate below, each grain is instead weighted by the length of
% its long half axis, which the |longAxis| property carries in its norm.
% <DensityEstimation.html Density Estimation> develops the consequences of
% weights and smoothing bandwidth.

tdfForsterite = calcDensity(grains('forsterite').longAxis,...
  'weights',norm(grains('forsterite').longAxis));

tdfEnstatite = calcDensity(grains('enstatite').longAxis,...
  'weights',norm(grains('enstatite').longAxis));

%%
% The input was a list of vectors, so the result is a function on the sphere,
% an |@S2FunHarmonic|. All long axes lie in the map plane, so we plot the
% section of the function through that plane.

close all
plotSection(tdfForsterite, vector3d.Z, 'linewidth', 3)
hold on
plotSection(tdfEnstatite, vector3d.Z, 'linewidth', 3)
hold off

%%
% Both sections concentrate density in the same part of the map plane.
% Since only one angle is in play, a function on the circle is the more
% direct representation. |calcDensity| returns an |@S1Fun| when given the
% angles |rho| and the option |'periodic'|. The option |'antipodal'| identifies
% directions separated by 180 degrees, and |'sigma'| sets the circular
% Gaussian smoothing scale.

tdfForsterite = calcDensity(grains('forsterite').longAxis.rho,...
  'weights',norm(grains('forsterite').longAxis), ...
  'periodic','antipodal','sigma',5*degree);

tdfEnstatite = calcDensity(grains('enstatite').longAxis.rho,...
  'weights',norm(grains('enstatite').longAxis), ...
  'periodic','antipodal','sigma',5*degree);

close all
plot(tdfForsterite, 'linewidth', 2)
hold on
plot(tdfEnstatite, 'linewidth', 2)
hold off
mtexTitle('long axes')
legend('Forsterite','Enstatite','Location','southoutside','numColumns',2)

% the plot has to be told which way the specimen is oriented
setView(ebsd.how2plot)

% report the preferred long-axis directions in the specimen frame
[~,longAxisPeakF] = max(tdfForsterite);
[~,longAxisPeakE] = max(tdfEnstatite);
longAxisPeakDegree = round(mod([longAxisPeakF longAxisPeakE],pi) ./ degree,1)

%%
% The printed maxima are 74.2 degrees for forsterite and 78.8 degrees for
% enstatite. As far as the long axes show, the two phases share one fabric
% rather than each having its own.

%% Shortest-caliper distribution
%
% The long axis of an ellipse is not the only way to say which way a grain
% points, and for some shapes it is a poor one: for aligned rectangles the
% long axis of the fitted ellipse jumps between the two diagonals. The
% direction in which a grain is thinnest is more stable. The
% <grain2d.caliper.html |caliper|>, or Feret diameter, is the width of a
% grain seen from a given direction, and the option |'shortestPerp'| returns
% the normal to the direction in which that width is smallest.

cPerpF = caliper(grains('fo'),'shortestPerp');
cPerpE = caliper(grains('en'),'shortestPerp');

S1F_fo = calcDensity(cPerpF.rho, 'weights',cPerpF.norm, ...
  'periodic','antipodal','sigma',5*degree);
S1F_en = calcDensity(cPerpE.rho, 'weights',cPerpE.norm,...
  'periodic','antipodal','sigma',5*degree);

plot(S1F_fo,'linewidth',2);
hold on
plot(S1F_en,'linewidth',2);
hold off
mtexTitle('perpendicular to short axes')
legend('Forsterite','Enstatite','Location','southoutside','numColumns',2)
setView(ebsd.how2plot)

% report the preferred directions normal to the shortest calipers
[~,caliperPeakF] = max(S1F_fo);
[~,caliperPeakE] = max(S1F_en);
caliperPeakDegree = round(mod([caliperPeakF caliperPeakE],pi) ./ degree,1)

%%
% The printed maximum is 74.3 degrees for forsterite and 82.0 degrees for
% enstatite. Two different definitions of which way a grain points agree on
% the fabric, which is the reassuring outcome.
%
% Both curves still carry the scatter of a finite grain population.
% Convolving with a kernel smooths them and makes the position of the
% maximum easier to read off.

psi = S1DeLaValleePoussinKernel('halfwidth',10*degree);

S1_fo_smooth = conv(S1F_fo,psi);
S1_en_smooth = conv(S1F_en,psi);

plot(S1_fo_smooth,'linewidth',2);
hold on
plot(S1_en_smooth,'linewidth',2);
hold off
mtexTitle('perpendicular to short axes')
legend('Forsterite','Enstatite','Location','southoutside','numColumns',2)
setView(ebsd.how2plot)

%%
% The 10-degree
% <S1DeLaValleePoussinKernel.html de la Vallée Poussin kernel> suppresses
% narrow fluctuations while retaining the broad preferred direction. A
% halfwidth is part of the analysis: increasing it can merge nearby peaks
% and move their apparent maxima.

%% SPO from boundary segments
%
% Both measures so far describe a grain by one direction, and both need
% whole grains. Asking instead which way the boundary segments run uses the
% entire outline, concave parts included, and works on any selection of
% boundaries - the boundaries between two particular phases, for instance.
% Each segment direction is weighted by its
% <grainBoundary.segLength.html |segLength|>. This is a boundary or surface
% fabric, not another estimate of the particle long-axis distribution.

gbfun_fofo = calcDensity(grains.boundary('fo','fo').direction.rho, ...
    'weights',grains.boundary('fo','fo').segLength,'periodic','antipodal');
gbfun_foen = calcDensity(grains.boundary('fo','en').direction.rho, ...
    'weights',grains.boundary('fo','en').segLength,'periodic','antipodal');
gbfun_enen = calcDensity(grains.boundary('en','en').direction.rho, ...
    'weights',grains.boundary('en','en').segLength,'periodic','antipodal');

plot(gbfun_fofo,'displayName','Forsterite-Forsterite','linewidth',2);
hold on
plot(gbfun_foen,'displayName','Forsterite-Enstatite','linewidth',2);
plot(gbfun_enen,'displayName','Enstatite-Enstatite','linewidth',2);
hold off

legend('Location','eastoutside','numColumns',1)

setView(ebsd.how2plot)

% report the main forsterite-forsterite direction and the grid-axis peak
[fofoPeakDensity,fofoPeakDirection] = max(gbfun_fofo);
fofoPeakDegree = round(mod(fofoPeakDirection,pi) ./ degree,1)
gridPeakRelativeHeight = round(...
  eval(gbfun_fofo,90*degree) ./ fofoPeakDensity,2)

%%
% The forsterite-forsterite curve peaks at 75 degrees, agreeing with the two
% measures before it. It then stays almost as high all the way to the grid
% axis at 90 degrees, where its density is still 0.97 of the maximum. The
% grid contributes to this broad shoulder: before smoothing, every segment
% between measurement points is horizontal or vertical. Ten smoothing
% iterations removed most of this artefact, but not all of it. Peaks at
% exactly 0 and 90 degrees are the features to distrust here.

%% Characteristic shape
%
% Laying all the boundary segments of a phase end to end, sorted by their
% direction, closes into a single polygon: the characteristic shape. It is
% an average outline in the precise sense of a length-weighted boundary
% direction distribution, not the arithmetic mean of registered grains.
% <grainBoundary.characteristicShape.html |characteristicShape|> takes a list
% of <BoundarySelect.html boundaries> rather than whole grains, and the
% result answers to |aspectRatio| and |longAxis| like a grain does.

cshapeF = characteristicShape(grains('F').boundary);
cshapeE = characteristicShape(grains('E').boundary);

close all
plot(cshapeF, 'linewidth',2);
hold on
plot(cshapeE, 'linewidth',2);
hold off
legend('Forsterite','Enstatite','Location','eastoutside')

%%
% The two outlines are elongated the same way, which is the same conclusion
% the rose diagrams reached, now expressed as a shape. Their aspect ratios
% are 1.3289 for forsterite and 1.3394 for enstatite, so the strengths are
% similar as well.

characteristicAspectRatio = ...
  [cshapeF.aspectRatio cshapeE.aspectRatio]

%%
% Whether a difference between two such shapes is more than noise is not
% something these numbers answer on their own. With one map per specimen
% there is one measurement of each, and the scatter to compare it against
% has to come from somewhere else - several maps, or a subdivision of the
% one map into regions.

%% Further reading
%
% * K. F. Mulchrone and K. R. Choudhury,
% <https://doi.org/10.1016/S0191-8141(03)00093-2 Fitting an ellipse to an
% arbitrary shape: implications for strain analysis>, _Journal of
% Structural Geology_ 26 (2004), 143-153. This is the ellipse-fitting method
% cited by <grain2d.fitEllipse.html |fitEllipse|>.
%
% * R. Panozzo,
% <https://doi.org/10.1016/0040-1951(83)90073-2 Two-dimensional analysis of
% shape-fabric using projections of digitized lines in a plane>,
% _Tectonophysics_ 95 (1983), 279-294. It introduces the projection approach
% developed further in <ProjectionBasedParameters.html Projection
% Parameters>.
%
% * R. Heilbronner and S. Barrett,
% <https://doi.org/10.1007/978-3-642-10343-8 Image Analysis in Earth
% Sciences: Microstructures and Textures of Earth Materials>, Springer,
% 2014. The chapters on particle and surface fabrics distinguish the two
% kinds of directional information compared here.
%
% * K. V. Mardia and P. E. Jupp,
% <https://doi.org/10.1002/9780470316979 Directional Statistics>, Wiley,
% 1999. This is a general reference for circular and axial statistics.
%
% * <https://www.iso.org/standard/74309.html ISO 13067:2020>, _Microbeam
% analysis - Electron backscatter diffraction - Measurement of average
% grain size_. The standard distinguishes measurements on two-dimensional
% sections from quantities inferred for three-dimensional grains.

%% Next
%
% <HullBasedParameters.html Convex Hull Parameters> isolates bays and inlets
% that an ellipse discards. <ProjectionBasedParameters.html Projection
% Parameters> develops calipers, PAROR, SURFOR, and characteristic shapes
% without reducing each grain to one ellipse. Continue to
% <GrainOrientationParameters.html Grain Orientation Parameters> to compare
% this shape fabric with orientation variation inside the grains, or to
% <GrainBoundaries.html Grain Boundaries> when the boundary segments
% themselves are the subject.
