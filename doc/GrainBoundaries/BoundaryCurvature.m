%% Boundary Curvature
%
%%
% The curvature of a curve is defined by fitting locally a circle and taking
% one over its radius. Hence, a straight line will have curvature 0 and a
% circle of radius $2$ will have constant curvature $1/2$ everywhere.
% Hence, the unit of the curvature computed in MTEX is one over the unit of
% the EBSD coordinates which is usually 1/µm. Let us demonstrate boundary
% curvature using some artificial grain shapes

% import the artificial grain shapes
mtexdata testgrains silent

% select and smooth a few interesting grains
grains = smoothBoundary(grains('id',[2 3 9 11 15 16 18 23 31 33 38 40]),10);

%%
% Therefore, we first extract all boundary segments and colorize them
% according to their <grainBoundary.curvature.html |curvature|>.

% extract boundary segments
gB = grains.boundary;

% plot some dark background
plot(gB,'linewidth',10,'micronbar','off');

% colorize boundaries by curvature
hold on
plot(gB,gB.curvature,'linewidth',6);
hold off

% set a specific colormap
mtexColorMap('blue2red')
setColorRange(0.25*[-1,1])
mtexColorbar

%% The Sign of the Curvature
%
% The curvature is signed, and the sign tells which of the two adjacent
% grains the boundary bulges into. Boundary segments are stored in walk
% order with the grain in the first column of |gB.grainId| lying to the left
% of the walk direction - see <BoundaryMisorientations.html boundary
% misorientations>. Accordingly a *positive* curvature means the boundary
% bulges into the grain in the *second* column, a negative one that it
% bulges into the grain in the *first* column.
%
% Every grain plotted above is an island inside one large surrounding grain,
% grain 44, and along their outer boundaries that surrounding grain is the
% one stored in the first column

grains('id',2).boundary.grainId(1:5,:)

%%
% Grain 2 is a convex blob, so its boundary bulges into grain 44 everywhere
% - into the *first* column - and its curvature is negative throughout.
% Across the whole map this is why the convex parts come out blue while only
% the notches and the enclosed grains come out red. The enclosed grains are
% stored the other way round, with the enclosed grain in the first column,
% and being convex they bulge into the ring shaped grains 23 and 31 that
% surround them.
%
% Which grain sits in which column is not a property of the boundary as a
% set of segments, it is a property of the direction each segment is walked
% in. The command <grainBoundary.flip.html |flip|> reverses that direction
% and swaps the two columns with it, so the curvature simply changes sign.
% Integrating it along a closed boundary gives the total turning of the
% curve, which is $\pm 2\pi$ depending on the direction it is walked in

gB2 = grains('id',2).boundary;
gB2flipped = flip(gB2);

[sum(gB2.curvature .* gB2.segLength), ...
  sum(gB2flipped.curvature .* gB2flipped.segLength)] ./ (2*pi)

%% Curvature With Respect to a Specific Grain
%
% Selecting a single grain does not change the storage order - the segments
% of |grains(k).boundary| come as they are stored, and the grain we asked for
% may sit in either column. In order to read the curvature as convex or
% concave with respect to one specific grain we flip exactly those segments
% that have it in the second column. Then that grain lies to the left
% everywhere, a positive curvature marks a convex piece of it and a negative
% one a notch.

for k = 1:length(grains)

  gB = grains(k).boundary;

  % put the grain itself into the first column
  gB = flip(gB, gB.grainId(:,2) == grains(k).id);

  plot(gB,'linewidth',10,'micronbar','off');
  hold on
  plot(gB,gB.curvature,'linewidth',6);

end
hold off

mtexColorMap('blue2red')
setColorRange(0.25*[-1,1])
drawNow(gcm,'figSize',getMTEXpref('figSize'))

%%
% The outer boundaries are now predominantly red, i.e. convex with respect
% to the grain they belong to, and the boundaries of the enclosed grains
% have turned blue - seen from the ring shaped grains 23 and 31 they are
% concave.

%% Undefined Segments and Smoothing
%
% The curvature of a segment is computed from the circle through its own
% midpoint and the midpoints of its two neighbours within the same chain.
% A segment at the end of an open chain has a neighbour on one side only and
% therefore no curvature - those segments come out |NaN|. All chains above
% are closed, so nothing is undefined there, but an arbitrary subset of
% segments is in general no longer closed

gB = grains.boundary;
sum(isnan(gB(1:100).curvature))

%%
% These raw values are then smoothed along the chain. The number of
% smoothing passes is the second argument and defaults to 50. Without any
% smoothing the curvature follows the individual segment midpoints and is
% correspondingly noisy

gB = grains('id',15).boundary;

plot(gB.arcLength,gB.curvature(0),'linewidth',1)
hold on
plot(gB.arcLength,gB.curvature,'linewidth',2)
hold off

legend('no smoothing','50 smoothing passes')
xlabel(['arc length in ' gB.scanUnit])
ylabel(['curvature in 1/' gB.scanUnit])

%% Curvature of a Real EBSD Map
%
% Finally we illustrate the usage of the <grainBoundary.curvature.html
% |curvature|> command at a real EBSD map.

% import data and reconstruct grains
mtexdata titanium silent
[grains,ebsd] = calcGrains(ebsd);
grains = smoothBoundary(grains,5);

% plot an ipf map
plot(ebsd('indexed'),ebsd('indexed').orientations)

hold on

% plot grain boundaries
plot(grains.boundary,'linewidth',4)

% colorize the grain boundary of the grain at position 596,466 according to
% curvature, with the grain itself on the left so that convex is positive
grain = grains(596,466);
gB = flip(grain.boundary, grain.boundary.grainId(:,2) == grain.id);

plot(gB,gB.curvature(5),'linewidth',6)
hold off

mtexColorMap('blue2red')
setColorRange(0.05*[-1,1])
mtexColorbar
