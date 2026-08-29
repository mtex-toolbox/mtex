%% Plotting
%
%%
% Nearly everything in texture analysis lives in three dimensions or more,
% while a page has two. In that broad sense, every figure in MTEX is a
% projection, and every projection gives up some information. Reading a plot
% starts with knowing what it preserves and what it hides.
%
% The practical side is easier than that sounds. Apply |plot| to almost any
% MTEX variable and it chooses a sensible representation. This works for
% directions, Miller indices, orientations, pole figures, ODFs, maps, grains,
% and tensors. This chapter addresses the decisions that follow: plot type,
% projection, screen alignment, colour, composition, and export.
%
%% One pole figure, two projections
% A spherical projection maps directions on a sphere to points in a plane.
% The example below draws the same pole density in two projections. Both
% panels use the same colour range, so their colours remain comparable.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('432');
odf = unimodalODF(...
  orientation.byEuler(30*degree,50*degree,10*degree,cs),...
  'halfwidth',15*degree);
h = Miller(1,0,0,cs);

newMtexFigure('layout',[1,2],'figSize','small')

% equal area: areas are preserved, so densities can be compared by eye
plotPDF(odf,h,'contourf','projection','earea')
mtexTitle('equal area')

nextAxis

% stereographic, also called equal angle: angles are preserved, areas are not
plotPDF(odf,h,'contourf','projection','stereo')
mtexTitle('stereographic')

setColorRange('equal')
mtexColorbar

%%
% The panels show the same function, yet the peak has a different size and
% position on the page. Neither picture is wrong. Only the equal-area panel
% lets you judge how much material a peak represents from its plotted area.
% Stereographic areas become increasingly misleading towards the rim.
% Equal area is therefore the MTEX default and the usual texture convention.
%
%% Colour is a choice, not a measurement
%
% A colour bar exposes a numerical colour mapping, while an orientation map
% can hide that a mapping was chosen. Turning a three-parameter orientation
% into a colour requires a *colour key*. Different keys give visibly
% different maps of identical data. Orientation colours alone do not provide
% a quantitative orientation value.
%
% The related trap is comparison. Two maps or pole figures with independently
% chosen colour ranges cannot be compared by eye. The same colour can mean a
% different number in each plot. Whenever figures belong in one comparison,
% fix a common range explicitly. The call to |setColorRange('equal')| above
% applies one range to both projection panels.
%
%% Figures are built up, not produced whole
%
% MTEX figures are assembled one layer at a time. Draw one object, hold the
% axes, draw the next object on top, and release the axes. Boundaries over a
% map, crystal directions over an inverse pole figure, and a fitted fibre over
% its data all follow the same pattern.
%
%   plot(ebsd,ebsd.orientations)
%   hold on
%   plot(grains.boundary)
%   hold off
%
% Plot order matters because each new layer can cover the previous layer.
% <TransparencyDemo.html Transparency> shows how alpha values reveal both
% layers when an opaque overlay would hide the background.
%
% MTEX manages layout, colour bars, and annotations across all axes in a
% figure. A pole-figure command that produces seven subplots therefore still
% arranges them as one figure.
%
%% Follow the chapter workflow
%
% Start with <PlotTypes.html Plot Types>. It compares scatter plots, contour
% lines, filled contours, smooth shading, and line plots. Raw measurements
% usually need a scatter or smooth plot, while a density usually needs
% contours.
%
% Next, <AxesAlignment.html Axes Alignment> decides which specimen direction
% points where on the page. This session-wide setting affects every figure.
% Check it first when a plot is mirrored or rotated unexpectedly.
%
% <CombinedPlots.html Combined Plots> and <Multiplot.html Multiplot> show more
% than one object. The first overlays objects in one axes, while the second
% places related axes side by side. <Annotations.html Annotations> then adds
% colour bars, labels, and marked directions.
%
% <PlottingExport.html Export> writes the finished figure. Vector formats keep
% text and lines sharp. A map of a million pixels is usually better exported
% as an image, and the page explains where that boundary lies.
%
% <SphericalProjections.html Spherical Projections> develops the comparison
% above. It covers equal-area, equal-angle, equal-distance, plain, and
% three-dimensional views. <Legends.html Legends> identifies phases and
% marker series.
%
% <ColorMaps.html Color Maps> develops colour coding and consistent ranges.
% <ContourPlots.html Contour Plots> then shows how to choose, overlay, and
% label contour levels. Finally, <TransparencyDemo.html Transparency> uses
% alpha values for overlapping markers, superposed maps, boundaries, and
% three-dimensional surfaces.

%% Plot the object you are analysing
%
% The chapter for each object explains what its plots mean. Continue with
% <EBSDAnalysis.html EBSD>, <Grains.html Grains>, <ODFAnalysis.html ODF>, or
% <PoleFigureAnalysis.html Pole Figures> when that is the object being
% analysed. <EBSDIPFMap.html IPF Maps> develops the orientation colour keys
% introduced above.

%% References
%
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, English ed.,
% 1982, develops pole figures and the projections used in texture analysis.
% * S. R. Midway,
% <https://doi.org/10.1016/j.patter.2020.100141 Principles of Effective Data
% Visualization>, _Patterns_ 1 (2020), 100141, explains how visual encodings
% and common scales support honest comparisons.

%% Next
%
% Continue with <PlotTypes.html Plot Types> to choose marks that match
% sampled data, continuous functions, and the comparison you need to make.
%
