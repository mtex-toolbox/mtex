%% Using fibers to evaluate grain dispersion axes
%
%%
% When a grain is bent, its orientations do not scatter in all directions at
% once. They rotate about an axis, and that axis - the crystal dispersion
% axis - is a fingerprint of the slip that produced the bending. This page
% is about seeing it in a single grain and checking whether the grain really
% has one. <GrainOrientationParameters.html Orientation Parameters> takes
% the same measurement over a whole map.

plottingConvention.default('y↑→x');
mtexdata forsterite silent
[grains,ebsd] = calcGrains(ebsd,'minPixel',5);

%%
% A first look at the map, with each measurement coloured by the axis of its
% misorientation to the mean orientation of its own grain. The reference
% orientation is set per pixel with |ck.oriRef|.

ck = axisAngleColorKey(ebsd('f').CS);
ck.oriRef = grains('id',ebsd('f').grainId).meanOrientation;
plot(ebsd('f'), ck.orientation2color(ebsd('f').orientations))

hold on
plot(grains.boundary,'lineWidth',2)
plot(grains({'En','Di'}),'FaceAlpha',0.7)
hold off

%%
% The hue is the axis of that misorientation and the saturation its angle,
% so a pale grain has hardly rotated at all and a grain of one strong hue
% has rotated about one axis throughout. Most grains here are pale, a few
% are strongly coloured, and several of those show bands of two or three
% hues - more than one axis at work in one grain.
%
% We continue with one of the large coloured ones.

grain_selected = grains(5095, 7803);
hold on
plot(grain_selected.boundary,'linewidth',3,'linecolor','w')
hold off

%% Seeing the dispersion in a pole figure
%
% Take a grid of crystal directions, send each of them through every
% orientation of the grain, and plot the results. Every grid direction
% becomes a small cloud of specimen directions, and the size of that cloud
% is how much this particular crystal direction is affected by the bending.

% Let's define a grid of directions
s2G = equispacedS2Grid('resolution',15*degree);
s2G = Miller(s2G,ebsd('f').CS)

% use the orientations of points belonging to the grain
o = ebsd(grain_selected).orientations;

% and compute the corresponding specimen directions
d = o .* s2G;

% and plot them
plot(d,'MarkerSize',3,'upper')

%%
% Some of the clouds are drawn out into streaks and others are compact.
% Colouring each cloud by its own mean angular deviation makes the pattern
% explicit.

vd = mean(angle(mean(d),d),'omitmissing');

plot(d,repmat(vd,length(o),1)/degree,'MarkerSize',3)
mtexColorbar('title','average pole dispersion')

%%
% The blue directions barely move. The one that moves least is the best
% guess at the dispersion axis, since a rotation leaves its own axis alone.

[~,id_min] = min(vd);
disp_ax_grid = grain_selected.meanOrientation .* s2G(id_min);
annotate(disp_ax_grid)
annotate(disp_ax_grid,'plane','linestyle','--','linewidth',2)

%%
% The dashed great circle is the plane normal to that axis; the streaks run
% along it, as they must. The estimate is limited by the grid, though - it
% can only ever return one of the 15 degree grid points.

%% Fitting a fibre instead
%
% Saying that the orientations of a grain rotate about one axis is saying
% that they lie on a <OrientationFibre.html fibre>, and
% <fibre.fit.html |fibre.fit|> finds the best fitting one without a grid.

fib = fibre.fit(o,'local')

%%
% The fitted fibre carries the axis in both frames: |fib.r| in specimen
% coordinates and |fib.h| in crystal coordinates.

fib.r
fib.h

annotate(fib.r,'MarkerFaceColor','r')
annotate(fib.r,'plane','linestyle','-.','linewidth',2,'lineColor','r')

%%
% The red axis lies 6 degrees from the black one, well within the 15 degree
% spacing of the grid: the two methods agree, and the fitted one is not tied
% to a grid point.

%% Does the grain have an axis at all
%
% |fibre.fit| returns two further outputs that say how well the assumption
% holds: the eigenvalues of the orientation tensor, in ascending order, and
% the mean angle between the orientations and the fitted fibre.

[fib,lambda,delta] = fibre.fit(o,'local');

lambda
delta./degree

%%
% The last eigenvalue is close to 1 - the orientations of a grain are always
% concentrated. What matters is the ratio of the two before it: the third
% counts the spread along the fibre, the second the scatter off it.

lambda(3)/lambda(2)

%%
% Here the spread along the fibre is 3.6 times the scatter off it, so the
% orientations really do form a line rather than a blob, and the axis is
% worth reporting. A ratio near 1 would mean the fit returned an axis for a
% cloud that has none.
%
% The same judgement per measurement rather than per grain: the angle
% between each orientation and the fibre, plotted in orientation space and
% back on the map.

fd = angle(fib,o)/degree;
plot(o,fd)
xlim([0 30]); ylim([20 70]); zlim([80 120])
grid minor
hold on
plot(fib,'linewidth',2)
hold off

nextAxis
plot(ebsd(grain_selected),fd)
mtexColorbar('title', 'distance from fibre')

%%
% In orientation space the points sit along the line rather than around it.
% On the map the distance stays below 1.5 degrees over most of the grain,
% rises to 3 along a band running across its middle, and reaches 4.5 in the
% tail at the bottom. Those are the parts of the grain that a single axis
% does not describe - a second rotation, or a subgrain boundary.

%% All the grains at once
%
% A fit per grain takes a loop, and the axes can then be plotted together.
% Only grains with enough measurements are worth fitting.

grainsLarge = grains('fo');
grainsLarge = grainsLarge(grainsLarge.numPixel > 100);

axCrystal = Miller.nan(length(grainsLarge),1,grainsLarge.CS);
axSpecimen = vector3d.nan(length(grainsLarge),1);
ratio = nan(length(grainsLarge),1);

for i = 1:length(grainsLarge)

  [fib,lambda] = fibre.fit(ebsd(grainsLarge(i)).orientations,'local');

  axCrystal(i) = fib.h;
  axSpecimen(i) = fib.r;
  ratio(i) = lambda(3)/lambda(2);

end

%%
% Of the 249 forsterite grains large enough to fit, 141 pass the same test
% the selected grain passed - orientations at least three times as spread
% along the fibre as off it. The rest have no axis to report and are left
% out.

isFibre = ratio > 3;

plot(axSpecimen(isFibre),'antipodal','upper','MarkerSize',4)
hold on
plot(axSpecimen(isFibre),'contourf','antipodal','upper',...
  'halfwidth',15*degree)
hold off
mtexColorbar

%%
% The density is mild, reaching 1.9, but it is not uniform: the axes avoid
% the centre of the projection, the normal to the section, and gather near
% its rim towards X. In other words they lie in the plane of the section and
% point roughly east-west, which is where a vorticity axis would be for a
% shear in that plane.
%
% And in crystal coordinates, in the fundamental sector of the forsterite
% point group.

plot(axCrystal(isFibre),'contourf','antipodal','fundamentalRegion',...
  'halfwidth',15*degree)
mtexColorbar

%%
% This one is clearer: a maximum of 2.8 at [010], falling away towards
% [100]. The grains of this rock are bent about their own [010] axis far
% more often than about anything else.
%
% The two figures answer different questions, and it is worth keeping them
% apart. A clustering in specimen coordinates points at a common kinematic
% frame - all the grains were bent by the same flow. A clustering in crystal
% coordinates points at a common slip system - they were all bent by the
% same mechanism. Here both are present, and only the second is strong.
