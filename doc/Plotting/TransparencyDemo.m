%% Transparency
% How to superpose plots and how to visualize point densities by
% translucent markers
%
%%
% Transparency is a simple but powerful tool whenever a plot contains more
% information than can be displayed by opaque colors, e.g., when markers
% cover each other, or when two maps should be displayed on top of each
% other. In MTEX transparency is controlled by the options
%
% * |'MarkerAlpha'|, |'MarkerFaceAlpha'|, |'MarkerEdgeAlpha'| - for scatter
% plots, i.e., pole figures, inverse pole figures and ODF sections
% * |'faceAlpha'| - for EBSD maps, grain maps, crystal shapes and other
% surfaces
% * |'edgeAlpha'| - for grain boundaries and other line plots
%
% All of them take values between 0 (completely transparent) and 1
% (completely opaque). Transparency requires the renderer of the figure to
% be set to |'opengl'|, which is the Matlab default.

%% Transparent Markers
% Let us start with a set of orientations that is strongly concentrated
% around the identical orientation

cs = crystalSymmetry('m-3m');
odf = unimodalODF(orientation.id(cs),'halfwidth',10*degree);
ori = odf.discreteSample(2000);

h = Miller({1,0,0},{1,1,0},{1,1,1},cs);

%%
% Plotting these orientations in a pole figure the markers cover each other
% and the preferred orientations show up as solid, uniformly colored blobs.
% Neither the number of orientations nor the shape of the maxima is visible

plotPDF(ori,h,'MarkerSize',5,'all')

%%
% Making the markers almost transparent by the option |'MarkerAlpha'| the
% scatter plot becomes a density like plot. Positions where many markers
% overlap remain dark, while isolated orientations are barely visible

plotPDF(ori,h,'MarkerAlpha',0.05,'MarkerSize',5,'all')

%%
% Face and edge of the markers may be made transparent independently by the
% options |'MarkerFaceAlpha'| and |'MarkerEdgeAlpha'|. Since the edges of
% overlapping markers accumulate much faster than their faces it is often
% useful to keep the edges slightly more opaque than the faces

plotPDF(ori,h,'MarkerFaceAlpha',0.01,'MarkerEdgeAlpha',0.05,...
  'MarkerSize',10,'all')

%%
% It should be stressed that transparency is only a visual approximation to
% the point density. Whenever the density itself is of interest it should
% be computed by kernel density estimation as explained in
% <DensityEstimation.html Density Estimation>

plotPDF(ori,h,'contourf')
mtexColorbar

%% Superposing EBSD Maps
% The most common application of transparency are superposed EBSD maps.
% Here the band contrast is plotted as a gray scale background and the
% orientation map is plotted half transparent on top of it. This way the
% texture and the image quality of the measurement are visible at the same
% time

plottingConvention.default('y↑→x');
mtexdata forsterite silent

plot(ebsd,ebsd.bc)
mtexColorMap black2white

hold on
plot(ebsd('Forsterite'),ebsd('Forsterite').orientations,'faceAlpha',0.5)
hold off

%% Transparency Depending on a Property
% Instead of a single value the option |'faceAlpha'| also accepts a list of
% values - one for each pixel. This allows to fade out unreliable
% measurements, e.g., all pixels with a low band contrast. Since the
% transparency values have to be within the interval $[0,1]$ we normalize
% the band contrast by its mean value and cut off everything above 1

ebsdF = ebsd('Forsterite');

alpha = min(ebsdF.bc ./ mean(ebsdF.bc), 1);

plot(ebsdF,ebsdF.orientations,'faceAlpha',alpha,'figSize','large')

%%
% In the resulting map the pixels along the grain boundaries, where the
% Kikuchi patterns of two grains overlap and the band contrast is low, fade
% into the background. A second common choice for the transparency value is
% the local misorientation, see <EBSDGROD.html Grain Reference Orientation
% Deviation>.

%% Transparent Grains
% Grain maps are made transparent by the very same option |'faceAlpha'|.
% Note that for grains the transparency value is additionally weighted by
% the color of the grain, i.e., light colored grains become more
% transparent than dark colored ones. The option |'translucent'| is a
% synonym for |'faceAlpha'|.

grains = calcGrains(ebsd('indexed'),'angle',10*degree);
grains = smoothBoundary(grains,5);

plot(ebsd,ebsd.bc)
mtexColorMap black2white

hold on
plot(grains('Forsterite'),grains('Forsterite').meanOrientation,'faceAlpha',0.5)
hold off

%% Transparent Grain Boundaries
% Line plots as they are used for grain boundaries are made transparent by
% the option |'edgeAlpha'|. Similarly as |'faceAlpha'| it takes either a
% single value or one value for each boundary segment. In the following
% example the transparency is used to fade out low angle boundaries

gB = grains.boundary('Forsterite','Forsterite');

plot(grains,'translucent',0.5,'micronbar','off')
legend off

hold on
plot(gB,'edgeAlpha',gB.misorientation.angle ./ (30*degree),'lineWidth',3)
hold off

%% Transparent Surfaces
% Transparency is also the method of choice to look inside of three
% dimensional objects. Plotting a crystal shape with the option
% |'faceAlpha'| makes the back faces of the crystal visible

cS = crystalShape.olivine;

plot(cS,'faceAlpha',0.2)

%%
% This becomes even more important when additional objects are plotted
% inside the crystal, e.g., the slip systems

sS = slipSystem.fcc(crystalSymmetry('432'));
cSfcc = crystalShape.cube(crystalSymmetry('432'));

plot(cSfcc,'faceAlpha',0.2)
hold on
plot(cSfcc,sS(1),'faceColor','blue','faceAlpha',0.5)
hold off

%%
% Finally, three dimensional plots of orientation distribution functions
% make automatic use of transparency - the transparency of a contour level
% is proportional to its value such that the maxima of the ODF remain
% visible from outside. See <ODFPlot.html Visualizing ODFs> for more
% details.

plot3d(SantaFe)

%% Transparency and Export
% Transparency is a feature of the |'opengl'| renderer. Accordingly,
% figures containing transparent objects can not be exported as true vector
% graphics - when exporting to |pdf| or |eps| Matlab either rasterizes the
% figure or drops the transparency. It is therefore recommended to export
% such figures as bitmaps, e.g., by
%
%   saveFigure('transparency.png')
%
% See <PlottingExport.html Exporting Figures> for more details on
% exporting.
