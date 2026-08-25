%% Boundary Plots
%
%%
% A boundary segment is a short line, and drawing it in a colour is how
% anything measured on it is shown. What the colour stands for is the whole
% question: the angle of the misorientation is one number and fits a
% colorbar, its axis is a direction and needs a direction key, and the
% misorientation as a whole is three numbers and needs a key built for the
% purpose.
%
% <BoundarySelect.html Select Grain Boundaries> covers which segments to
% draw; this page is about what to colour them by.

close all;

% import the data
plottingConvention.default('y↑→x');
mtexdata forsterite silent

% restrict it to a sub-region of interest.
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% reconstruct grains
[grains,ebsd] = calcGrains(ebsd,'minPixel',5,'alpha',10);

% smooth the grains a bit - ebsdId is read per segment further down, so keep
% every segment between the pair of pixels it was measured from
grains = smoothBoundary(grains,4,'noSimplify','noRefine')

%%
% Plain, with no second argument, |plot| draws the segments in one colour on
% top of the map.

gB = grains.boundary

plot(ebsd)
hold on
plot(gB,'lineWidth',2)
hold off

%% The misorientation angle
%
% The most common thing to colour a boundary by is the angle of its
% misorientation, the one number that says how differently the two crystals
% sit. It separates the low angle boundaries inside deformed grains from the
% high angle boundaries between grains.

close all
gB_Fo = grains.boundary('Fo','Fo');
plot(grains,'translucent',1,'micronbar','off')
legend off
hold on
plot(gB_Fo,gB_Fo.misorientation.angle./degree,'linewidth',4)
hold off
mtexColorbar('title','misorientation angle')

%%
% The angles run from 15.9 to 108.8 degrees with a median of 56. Nothing
% below 15 degrees appears, and it cannot: that is the threshold this
% reconstruction used, so every segment here is a high angle boundary by
% construction. Where the low angle boundaries went, and how to keep them,
% is the subject of <SubGrainBoundaries.html Subgrain Boundaries>.

%% The misorientation axis in crystal coordinates
%
% The axis of the misorientation is a direction rather than a number, so it
% needs a colour key rather than a colorbar. The first decision is which
% frame the axis is expressed in, and the crystal frame is the one that says
% something about the lattices.

% the axes in crystal coordinates
axes = gB_Fo.misorientation.axis

% define a color key
colorKey = HSVDirectionKey(axes);

% compute colors
color = colorKey.direction2color(axes);

hold on
plot(gB_Fo,'lineColor','black','linewidth',6) % some black background for contrast
plot(gB_Fo,color,'linewidth',4)
hold off
mtexColorbar('visible','off')

%%
% A colorbar would be meaningless here, so the key itself is plotted
% instead, with the axes drawn into it - which shows at the same time which
% part of the key the data actually uses.

figure(2)
plot(colorKey)
hold on
plot(axes,'MarkerFaceAlpha',0.1,'MarkerEdgeAlpha',0.3,'MarkerColor','black')
hold off

%% The misorientation axis in specimen coordinates
%
% The same axis can be expressed in the frame of the specimen, where it says
% how the two crystals are related in space rather than in the lattice. It
% takes a little more work, because the misorientation stored on a segment
% is a crystal to crystal rotation and has forgotten the specimen. The two
% orientations either side are needed, and |ebsdId| is what leads back to
% them.

figure(1)

% first we reduce the number of boundary segments a bit
% in order to avoid that the plot becomes to messy
gB_red = reduce(gB_Fo,5)

% next we extract for every boundary segment the two orientations at both
% sides
ori = ebsd('id',gB_red.ebsdId).orientations

% the two orientations we use to compute the misorientation axis in
% specimen coordinates
axes = axis(ori(:,1),ori(:,2))

% plot the projection of the misorientation axis on the measurement surface
hold on
quiver(gB_red,axes,'autoScaleFactor',0.4,'color','black')
hold off

%%
% Only every fifth segment is drawn, or the arrows would cover the map. As
% with any arrow on a map, what is drawn is the projection into the plane of
% the section, so a short arrow is an axis pointing steeply out of it.

%% Colouring the whole misorientation
%
% Angle and axis together are three numbers, and a colour key that maps all
% three at once has to be built for the purpose. MTEX implements the one of
% S. Patala, J. K. Mason, and C. A. Schuh, |Improved representations of
% misorientation information for grain boundary|, Prog. Mater. Sci., vol.
% 57, no. 8, pp. 1383-1425, 2012.

% plot the grains
close all
plot(grains,'micronbar','off')
legend off

% define the color key
colorKey = PatalaColorKey(gB_Fo);

hold on
plot(gB_Fo,'linewidth',7)
color = colorKey.orientation2color(gB_Fo.misorientation);
plot(gB_Fo,squeeze(color),'linewidth',4)
hold off

%%
% Two segments of the same colour now have the same misorientation, axis and
% angle alike, and not merely the same angle. The key is a colouring of the
% whole misorientation space, so it can only be displayed section by
% section - here as axis angle sections, with the measured misorientations
% drawn in.

figure(2)
plot(colorKey,'layout',[3,4])

% and plot the misorientations on top
plot(gB_Fo.misorientation,...
  'MarkerFacecolor','none','add2all','MarkerSize',4)

%%
% The misorientations of this rock fill the sections at large angles and
% leave the small angle ones nearly empty. A material with a preferred
% boundary character would show the opposite: the points gathered in one
% place, and the map coloured accordingly.
%
% An iron sample makes that comparison.

% import the data
plottingConvention.default("y↓→x");
mtexdata csl silent

% grain segmentation and smoothing
[grains,ebsd] = calcGrains(ebsd);
grains = smoothBoundary(grains,2);
gB = grains.boundary('iron','iron');

% and plot image quality + orientation
close all
plot(ebsd,log(ebsd.prop.iq),'figSize','large')
mtexColorMap black2white
setColorRange([.5,5])
hold on
plot(grains,grains.meanOrientation,'FaceAlpha',0.4)

% define the color key and colorize the grain boundaries
colorKey = PatalaColorKey(gB)
color = colorKey.orientation2color(gB.misorientation);
hold on
plot(gB,squeeze(color),'linewidth',4,'smooth')
hold off

%%
% Whole boundaries come out in one colour here rather than changing along
% their length, and one of those colours, the dark blue, recurs all over the
% map. Many boundaries of this material share one misorientation, in other
% words - they are special boundaries, and
% <CSLBoundaries.html CSL Boundaries> identifies them by name.

plot(colorKey,'axisAngle',(5:5:60)*degree,'layout',[3,4])

plot(gB.misorientation,'points',300,'add2all',...
  'MarkerFaceColor','none','MarkerEdgeColor','w')

%%
% The sections confirm it: the misorientations cluster instead of filling
% the space. Note that a misorientation and its inverse are drawn at the
% same place in these sections, since they describe the same boundary seen
% from its two sides.
