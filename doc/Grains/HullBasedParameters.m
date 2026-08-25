%% Convex Hull Based Shape Parameters
%
%%
% Stretch a rubber band around a grain and let it snap tight: what you get
% is the convex hull. It has the same overall size and elongation as the
% grain but none of its bays and inlets, so comparing a grain with its own
% hull isolates exactly those - how lobate a grain is, independently of how
% large or how elongated it is.
%
% The shapes below are artificial, chosen so that each measure has something
% to react to.

% import the artificial grain shapes
plottingConvention.default("y↑→x");
mtexdata testgrains silent

% select and smooth a few interesting grains
grains = smoothBoundary(grains('id',[2 3 9 11 15 16 18 23 31 33 38 40]),3);

%%
% <grain2d.smoothBoundary.html Smoothing> is not optional here. On an
% unsmoothed square grid every boundary segment is horizontal or vertical,
% so a perimeter measures the cityblock distance and comes out too long,
% while the convex hull cuts the corners and does not. The difference
% between the two - which is what this page measures - would then be
% dominated by the grid. For very small grains even smoothing does not save
% it, and the numbers below should not be trusted.
%
% <grain2d.hull.html |hull|> returns the hulls as grains, so everything that
% works on grains works on them.

% compute convex hull grains
chGrains = grains.hull;

% plot the original grains
plot(grains,'micronbar','off'), legend off

% and on top of them the convex hull
hold on
plot(chGrains.boundary,'lineWidth',2,'lineColor','r')
hold off

%%
% Where a grain is convex the red line follows its outline; where it is
% indented the line cuts across. Two hulls may overlap each other even
% though the grains do not, so a hull boundary is no longer a boundary
% between two grains - the second phase of every hull boundary segment is
% set to |'notIndexed'|.

%% Four ways to measure an indentation
%
% The relative difference between the perimeter of the grain and that of its
% hull reacts most strongly to thin, narrow indentations - a crack that does
% not quite cut the grain in two adds a great deal of perimeter and almost
% no area.

deltaP = 100 * (grains.perimeter-chGrains.perimeter) ./ grains.perimeter;

%%
% <grain2d.paris.html |paris|>, the Percentile Average Relative Indented
% Surface, is the same comparison taken relative to the hull rather than to
% the grain, and doubled. It is the conventional name in the literature, and
% |grains.paris| computes it directly.

paris = 200 * (grains.perimeter - chGrains.perimeter) ./ chGrains.perimeter;

%%
% Comparing the areas instead of the perimeters reacts to broad, shallow
% lobes - a big bite out of a grain, which changes the area a lot and the
% perimeter hardly at all.

deltaA = 100 * (chGrains.area - grains.area) ./ chGrains.area;

%%
% Since the two react to different kinds of indentation, combining them
% gives a measure that responds to both.

radiusD = sqrt(deltaP.^2 + deltaA.^2);

%%
% Drawn side by side on the same shapes:

plot(grains,deltaP,'layout',[2 2],'micronbar','off')
mtexTitle('deltaP')

nextAxis
plot(grains,grains.paris,'micronbar','off')
mtexTitle('paris')

nextAxis
plot(grains,deltaA,'micronbar','off')
mtexTitle('deltaA')

nextAxis
plot(grains,radiusD,'micronbar','off')
mtexTitle('radiusD')
mtexColorbar

%%
% The first two maps rank the grains identically, as they must, being the
% same ratio written two ways - only the scale differs, |paris| running to
% 167 where |deltaP| stops at 46. The third map ranks them differently: the
% lobed grain scores 45 on |deltaP| against 9 on |deltaA|, all perimeter and
% almost no missing area, while the two discs with a hole score 1.6 on
% |deltaP| - as convex as the plain disc - and 16 and 32 on |deltaA|.
% |radiusD| puts both kinds high, which is what combining them is for.
%
% The discs with holes are worth a second look, because they show what these
% measures are and are not counting. An inclusion is not an indentation of
% the outline, so the perimeter based measures ignore it; |paris| explicitly
% removes inclusions before it measures. The area based one cannot ignore
% it, since the hull contains the hole and the grain does not. If a hole is
% not what you mean by lobateness, use |deltaP| or |paris|; if it is, use
% |deltaA|.
%
% Which measure to report otherwise depends on the process being described.
% A dissolution front eats broad bays and shows up in |deltaA|; a partly
% healed fracture is a thin slot and shows up in |deltaP|.
