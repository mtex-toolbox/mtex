%% Ellipse Based Shape Parameters
%
%%
% Fitting an ellipse to a grain replaces an outline of hundreds of vertices
% by four numbers: where the grain sits, how long it is, how wide, and which
% way it points. Almost every statement about grain shape fabric is made in
% those terms, and this page is about how to compute them and what they do
% and do not capture.
%
% The command is <grain2d.fitEllipse.html |[c,a,b] = grains.fitEllipse|>,
% returning the centroid |c| and the long and short half axes |a| and |b| as
% vectors. Their quotient is the
% <grain2d.aspectRatio.html |aspectRatio|>.

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

%% Fitting ellipses
%
% Here are the fitted ellipses of the larger grains, drawn on top of the map.

[c,a,b] = grains(grains.numPixel>200).fitEllipse;

plotEllipse(c,a,b,'lineColor','w','linewidth',2)

%%
% Each ellipse has the same area as its grain and the same second moments,
% so it sits where the grain's mass sits and points the way the grain is
% drawn out. It says nothing about lobes and inlets - fit an ellipse to a
% clover leaf and you get a circle. Use |'boundary'| to scale the ellipse to
% the perimeter of the grain instead of its area.

%% Long and short axes
%
% The directions alone are available as
% <grain2d.longAxis.html |grains.longAxis|> and
% <grain2d.shortAxis.html |grains.shortAxis|>. They are well defined only
% when the ellipse is far enough from a circle, and the aspect ratio is what
% says how far that is: 1 for a circle, growing without bound as the ellipse
% is drawn out.

% visualize the aspect ratio
plot(grains,grains.aspectRatio,'linewidth',2,'micronbar','off')
setColorRange([0,4])
mtexColorbar('title','aspect ratio')

% and on top the long axes
hold on
quiver(grains,grains.longAxis,'Color','white')
hold off

%%
% Every grain gets an arrow of the same length, including the round ones
% whose direction means nothing. Reading the two together - only the arrows
% in the yellow grains - is what the weighting in the next section does
% arithmetically.

%% Shape preferred orientation
%
% A crystal preferred orientation is an alignment of the lattices. A shape
% preferred orientation, or SPO, is an alignment of the grains as bodies,
% independent of what their lattices do. Both can occur without the other:
% a deformed rock usually has both, a sediment of flat mica flakes has a
% strong SPO and no CPO at all.
%
% The question a rose diagram answers is whether the long axes of the grains
% agree with each other, and here whether the answer differs between two
% phases of the same rock.
%
% *Long axis distribution*
%
% A histogram of the long axis directions, one per phase. Each grain is
% weighted by its area, so that large grains count for more than small ones,
% and by |aspectRatio - 1|, so that a grain whose long axis is barely defined
% contributes almost nothing.

numBin = 50;

subplot(1,2,1)
weights = grains('forsterite').area .* (grains('forsterite').aspectRatio-1);
histogram(grains('forsterite').longAxis,numBin, 'weights', weights)
title('Forsterite')

subplot(1,2,2)
weights = grains('enstatite').area .* (grains('enstatite').aspectRatio - 1);
histogram(grains('enstatite').longAxis,numBin,'weights',weights)
title('Enstatite')

%%
% Instead of binning the directions we may fit a density to them with
% <calcDensity.html |calcDensity|>. Here the weight is the length of the
% long axis, which the |longAxis| property carries in its norm.

tdfForsterite = calcDensity(grains('forsterite').longAxis,...
  'weights',norm(grains('forsterite').longAxis));

tdfEnstatite = calcDensity(grains('enstatite').longAxis,...
  'weights',norm(grains('enstatite').longAxis));

%%
% The input was a list of vectors, so the result is a function on the sphere,
% an |@S2FunHarmonic|. The long axes all lie in the plane of the map, so the
% section through that plane is what we look at.

close all
plotSection(tdfForsterite, vector3d.Z, 'linewidth', 3)
hold on
plotSection(tdfEnstatite, vector3d.Z, 'linewidth', 3)
hold off

%%
% Since only one angle is in play, the honest object is a function on the
% circle rather than on the sphere. |calcDensity| returns an |@S1Fun| when
% given the angles |rho| and the option |'periodic'|.

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

%%
% Both curves have their maximum in the same place, at 74 degrees for
% forsterite and 79 for enstatite, so as far as the long axes go the two
% phases share one fabric rather than each having its own.
%
% *Shortest caliper distribution*
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

%%
% The maximum sits at 74 degrees for forsterite, exactly where the long axes
% put it, and at 82 for enstatite. Two different definitions of which way a
% grain points agree on the fabric, which is the reassuring outcome.
%
% The curve is rougher, because a caliper direction is decided by a few
% extreme points of the outline rather than by the whole of it. Convolving
% with a kernel smooths it.

psi = S1DeLaValleePoussinKernel('halfwidth',10*degree)

S1_fo_smooth = conv(S1F_fo,psi)
S1_en_smooth = conv(S1F_en,psi)

plot(S1_fo_smooth,'linewidth',2);
hold on
plot(S1_en_smooth,'linewidth',2);
hold off
mtexTitle('perpendicular to short axes')
legend('Forsterite','Enstatite','Location','southoutside','numColumns',2)
setView(ebsd.how2plot)

%%
% *SPO from the boundary segments*
%
% Both measures so far describe a grain by one direction, and both need
% whole grains. Asking instead which way the boundary segments run uses the
% entire outline, concave parts included, and works on any selection of
% boundaries - the boundaries between two particular phases, for instance.
% Each segment direction is weighted by its
% <grainBoundary.segLength.html |segLength|>.

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

%%
% The forsterite-forsterite curve peaks at 75 degrees, agreeing with the two
% measures before it, and then almost reaches the same value again at
% exactly 90 degrees. That second peak is the measurement grid showing
% through: a boundary segment runs between two measurement points, so before
% smoothing every segment is either horizontal or vertical. Ten smoothing
% iterations removed most of it and not all. Peaks at exactly 0 and 90
% degrees are the thing to distrust here.

%% Characteristic shape
%
% Laying all the boundary segments of a phase end to end, sorted by their
% direction, closes into a single polygon: the characteristic shape, an
% average grain outline for that phase.
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
% the rose diagrams reached, now in the shape of a grain.

[cshapeF.aspectRatio cshapeE.aspectRatio]

%%
% Whether a difference between two such shapes is more than noise is not
% something these numbers answer on their own. With one map per specimen
% there is one measurement of each, and the scatter to compare it against
% has to come from somewhere else - several maps, or a subdivision of the
% one map into regions.
