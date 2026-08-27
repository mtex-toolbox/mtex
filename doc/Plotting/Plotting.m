%% Plotting
%
%%
% Nearly everything in texture analysis lives in three dimensions or more,
% and a page has two. Every figure in MTEX is therefore a projection, and
% every projection distorts something. Reading these plots well means
% knowing what each one has given up.
%
% The practical side is easier than that sounds. Apply |plot| to almost any
% MTEX variable and it will choose a sensible way to draw it - directions,
% Miller indices, orientations, pole figures, ODFs, maps, grains, tensors.
% This chapter is about the decisions that come after that: which
% projection, which plot type, which colours, and how to make several
% figures comparable with each other.
%
% Below is the same pole figure drawn in two different spherical
% projections.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('432');
odf = unimodalODF(orientation.byEuler(30*degree,50*degree,10*degree,cs),'halfwidth',15*degree);
h = Miller(1,0,0,cs);

% equal area: areas are preserved, so densities can be compared by eye
plotPDF(odf,h,'contourf','projection','earea','figSize','small')
mtexTitle('equal area')

%%

% stereographic, also called equal angle: angles are preserved, areas are not
plotPDF(odf,h,'contourf','projection','stereo','figSize','small')
mtexTitle('stereographic')

%%
% The same function, and the peak is a different size and in a different
% place on the page. Neither picture is wrong, but only one of them lets you
% judge how much material a peak represents: the equal area projection,
% because it is the one that preserves area. Densities plotted
% stereographically are systematically misleading towards the rim, which is
% why equal area is the default here and the convention in most of the
% texture literature.
%
%% Colour is a choice, not a measurement
%
% A colour bar makes this obvious and an orientation map hides it. Turning
% a three-parameter orientation into a colour requires a *colour key*, and
% different keys give visibly different maps of identical data. Nothing can
% be read quantitatively off orientation colours alone.
%
% The related trap is comparison. Two maps or two pole figures drawn with
% independently chosen colour ranges cannot be compared by eye, because the
% same colour means a different number in each. Whenever two figures are
% meant to be looked at together, fix the range explicitly rather than
% letting each choose its own.
%
%% Figures are built up, not produced whole
%
% MTEX figures are assembled: draw one thing, hold the axes, draw the next
% on top. Boundaries over a map, crystal directions over an inverse pole
% figure, a fitted fibre over the data it was fitted to - all follow the
% same pattern.
%
%   plot(ebsd,ebsd.orientations)
%   hold on
%   plot(grains.boundary)
%   hold off
%
% Layout, colour bars and annotations are managed for you across however
% many axes a figure ends up with, which is why a pole figure command that
% produces seven sub-plots still comes out arranged sensibly.
%
%% Where to start
%
% <PlotTypes.html Plot Types> covers the ways of drawing the same data -
% contour lines, filled contours, smooth shading, scatter, line plots - and
% when each is appropriate. Raw measurements usually want a scatter or a
% smooth plot; a density usually wants contours.
% <ContourPlots.html Contour Plots> goes further into the contour family.
%
% <SphericalProjections.html Spherical Projections> is the page behind the
% figures above, covering equal area, equal angle, equal distance, plain
% and three-dimensional views.
% <AxesAlignment.html Axes Alignment> decides which specimen direction
% points where on the page - a session-wide setting that silently affects
% every figure, and the first thing to check when a plot is mirrored or
% rotated from what you expected.
%
% <ColorMaps.html Color Maps> covers colour coding and the consistent-range
% problem raised above. <Annotations.html Annotations> adds colour bars,
% labels, and marked directions, and <Legends.html Legends> handles phase
% and marker legends.
%
% <CombinedPlots.html Combined Plots> and <Multiplot.html Multiplot> are the
% two ways of showing more than one thing: overlaid in one axes, or side by
% side in several. <TransparencyDemo.html Transparency> is useful when an
% overlay would otherwise hide what it sits on.
%
% <PlottingExport.html Export> writes figures out. Vector formats keep text
% and lines sharp; a map of a million pixels is usually better exported as
% an image, and the page explains where the boundary lies.
%
%% Next
%
% What is being plotted is described in its own chapter -
% <EBSDAnalysis.html EBSD>, <Grains.html Grains>,
% <ODFAnalysis.html ODF>, <PoleFigureAnalysis.html Pole Figures>. The
% orientation colour keys are treated in detail under
% <EBSDIPFMap.html IPF Maps>.
%
