%% ODF Tutorial
%
%%
% An orientation distribution function is what a texture is, once it has
% been separated from the particular crystals that were measured. It gives,
% for every orientation, how much of the specimen sits in it:
%
% $$\mathrm{odf}(g) = \frac{1}{V} \frac{\mathrm{d}V(g)}{\mathrm{d}g}.$$
%
% In MTEX its values are multiples of a random distribution, mrd - a random
% texture is 1 everywhere, and a value of 10 means ten times as much
% material in that orientation as chance would give.
%
% There are two ways to get one: estimate it from individual orientations,
% or reconstruct it from pole figures. This tutorial does both, and then
% builds one from nothing.

%% From individual orientations
%
% EBSD, ACOM in a TEM and three dimensional X-ray imaging all measure
% orientations one at a time, as do simulations like VPSC. Here a titanium
% alloy, measured on a hexagonal rather than the more common square grid:

% import the titanium data
mtexdata titanium

% plot an orientation map
plot(ebsd, ebsd.orientations)

%%
% The 8148 measured orientations are a sample, not a function. Turning them
% into one is <DensityEstimation.html kernel density estimation>: put a
% small bump on each measured orientation and add them up.

% extract the orientations
ori = ebsd.orientations;

% compute the ODF
odf = calcDensity(ori)

%%
% The result reaches 9 mrd, so this specimen has nine times as much material
% in its preferred orientation as a random one would.
%
% An ODF lives in three dimensions, so every way of drawing it is a
% compromise: <EulerAngleSections.html Euler> or
% <SigmaSections.html sigma sections>,
% <ODFPlot.html three dimensional plots>, <ODFPoleFigure.html pole figures>,
% <ODFInversePoleFigure.html inverse pole figures>. The default is sections
% through the third Euler angle, which is the most common choice and not the
% best one - sigma sections distort less.

plot(odf)

%% From pole figures
%
% X-ray, neutron and synchrotron diffraction measure something else: for
% each of a handful of lattice planes, the intensity diffracted from a grid
% of specimen directions. Each dot below is one such measurement.

% import pole figure data
plottingConvention.default('y↑→x');
mtexdata ptx

% plot the data
plot(pf)

% show the colour bar - note that the maximum intensity is different for
% each pole figure
mtexColorbar

%%
% Reconstructing an ODF from these is an
% <PoleFigure2ODF.html ill posed inverse problem>: several different ODFs
% <PoleFigure2ODFAmbiguity.html produce the same pole figures>, and no
% algorithm can tell which was the specimen. MTEX
% <PoleFigure2ODFGhostCorrection.html picks among them> by preferring the
% one with the largest uniform portion, which is the physically sensible
% choice rather than a mathematical one.

% compute an ODF with default settings
odf = calcODF(pf)

%%
% This one reaches 17.8 mrd - a considerably sharper texture than the
% titanium above.
%
% The first thing to do with a reconstruction is to recalculate the pole
% figures that were measured and compare them with the data:

% plot the recalculated pole figures
plotPDF(odf,pf.h)

%%
% The maxima are in the same places and of similar height, which is what one
% wants. They are smooth where the measurements were speckled, because the
% noise of the measurement did not enter the ODF.

%% Model ODFs
%
% An ODF need not come from data at all. MTEX builds them from components -
% <RadialODFs.html#2 unimodal>, <FibreODFs.html fibre>,
% <BinghamODFs.html Bingham> and <ODFModeling.html any combination> - which
% is how one states a texture to compare a measurement against, or generates
% orientations for a simulation.

% define a gamma fibre ODF
odf = fibreODF(fibre.gamma(odf.CS))

% plot it in sigma sections
plot(odf,'sigma')

%%
% The gamma fibre is a standard rolling texture component, and here it is as
% an exact function rather than as an approximation from data: a ridge of
% constant value running through the sections, with nothing anywhere else.
