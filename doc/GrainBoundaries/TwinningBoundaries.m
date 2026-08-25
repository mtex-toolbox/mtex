%% Twinning Analysis
%
%%
% A twin is a part of a crystal that has taken up a mirrored orientation
% relative to the rest, along a plane the lattice allows. Twins form in
% magnesium and other hexagonal metals whenever the load cannot be
% accommodated by slip alone, so counting them is one way of reading what
% happened to a specimen.
%
% This page finds the twin relationship in a map rather than assuming it,
% then uses it to pick out the twin boundaries.

% load some example data
plottingConvention.default('y↑→x');
mtexdata twins silent

% segment grains
[grains,ebsd] = calcGrains(ebsd,'angle',5*degree,'minPixel',3);

% smooth them
grains = grains.smoothBoundary(5);

% visualize the grains
plot(grains,grains.meanOrientation)

% store crystal symmetry of Magnesium
CS = grains.CS;

%%
% The lamellae crossing the larger grains are the twins - the map shows them
% before any analysis. What follows puts a number on the relationship they
% have to their host.

gB = grains.boundary

%%
% Of these segments, some are boundaries against the edge of the scan, where
% a grain is cut off and has no neighbour. Only the magnesium to magnesium
% segments carry a misorientation.

gB_MgMg = gB('Magnesium','Magnesium')

%% The misorientation angles
%
% Colouring the boundaries by their misorientation angle already separates
% two populations.

plot(gB_MgMg,gB_MgMg.misorientation.angle./degree,'linewidth',2)
mtexColorbar

%%
% A histogram makes the split explicit.

close all
histogram(gB_MgMg.misorientation.angle./degree,40)
xlabel('misorientation angle (degree)')

%%
% One sharp peak just below 90 degrees holds a third of the segments between
% 85 and 87 degrees alone, and the rest are spread thinly over everything
% else. A peak that sharp is not
% something a random distribution produces: it is one orientation
% relationship, repeated across the map.

%% Identifying the relationship
%
% Take the misorientations in the peak and ask what they are.

ind = gB_MgMg.misorientation.angle>85*degree & gB_MgMg.misorientation.angle<87*degree;
mori = gB_MgMg.misorientation(ind);

%%
% In the axis angle domain they form a tight cluster in one corner, rather
% than a spread - one relationship, not a family of them.

scatter(mori)

%%
% The centre of that cluster is a single misorientation, and
% <orientation.round2Miller.html |round2Miller|> reports which crystal
% directions it maps onto each other.

% determine the mean of the cluster
mori_mean = mean(mori,'robust')

% determine the closest special orientation relation ship
round2Miller(mori_mean)

%%
% Those indices define the relationship exactly, without the rounding the
% measured mean carries.

twinning = orientation.map(Miller(1,-1,0,1,CS),Miller(1,0,-1,-1,CS),...
  Miller(0,1,-1,1,CS,'uvw'),Miller(1,-1,0,1,CS,'uvw'))

%%
% As an axis and an angle it is 86.3 degrees about the (11-20) axis.

% the rotational axis
round(twinning.axis)

% the rotational angle
twinning.angle / degree

%%
% That is the disorientation, the representative with the smallest angle.
% But a twin is a rotation by 180 degrees about the twin axis, and that
% description is among the symmetrically equivalent ones. Asking for the
% equivalent with the *largest* angle brings it out.

angle(twinning,'max')/degree

%%
% And its axis is the twin axis:

v = round(Miller(axis(twinning,'max'),'UVTW'))

%%
% Both descriptions are the same misorientation. Which one appears depends
% only on which representative is chosen, and it is worth knowing that the
% 86.3 degrees a program reports and the 180 degrees a textbook quotes are
% not in conflict.

%% Selecting the twin boundaries
%
% With the relationship in hand, every segment can be tested against it.

% restrict to twinnings with threshold 5 degree
isTwinning = angle(gB_MgMg.misorientation,twinning) < 5*degree;
twinBoundary = gB_MgMg(isTwinning)

% plot the twinning boundaries
plot(grains,grains.meanOrientation)
hold on
plot(twinBoundary,'linecolor','w','linewidth',4,'displayName','twin boundary')
hold off

%%
% 1406 of the 2696 magnesium to magnesium segments pass the test, and the
% white lines fall exactly on the lamellae the first figure showed -
% which is the check that the relationship found from the data is the one
% actually present.
%
% The next step is usually to put the parent grains back together by merging
% across these boundaries, which is described in
% <GrainMerge.html Merging Grains>.
