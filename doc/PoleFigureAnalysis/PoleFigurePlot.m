%% Plotting of Pole Figures
%
%%
% A pole figure is measured, not computed: an intensity at each of a few
% thousand specimen directions. So a plot of one is a plot of those
% measurements and nothing more - a coloured dot per direction, on the
% sphere the specimen directions live on. Everything smooth comes later,
% from an ODF.

specimenFrame.rolling.makeDefault
mtexdata ptx

%%
% Plotted with no further argument, each measured direction becomes a circle
% coloured by its intensity.

plot(pf)
mtexColorbar

%%
% Three lattice planes were measured here - (104), (110) and (202) - so
% three pole figures are drawn side by side, each on a regular grid of 72 by
% 17 specimen directions. Note that each has its own colour range at this
% point, so the three are not yet comparable.
%
% MTEX guesses a marker size that fills the sphere without overlapping. When
% the guess is wrong, |'MarkerSize'| overrides it.

plot(pf,'MarkerSize',4)
mtexColorbar

%% Contour plots
%
% Contours need a function, and a pole figure is a set of points. MTEX can
% interpolate between them when the measurement grid is regular, which is
% enough for a quick look:

plot(pf,'contourf')
mtexColorbar
mtexColorMap parula

%%
% Treat such a plot with care. The contours between the measured directions
% are interpolation and not measurement, and on an irregular grid they can
% be badly misleading. When smooth pole figures are what is wanted, the
% honest route is to reconstruct an ODF and recalculate them from it, which
% is what the last section does.

%% One colour range for all
%
% Comparing pole figures by eye only works when they share a colour range.
% <setColorRange.html |setColorRange|> with |'equal'| gives all axes of the
% figure the range of the widest one, and a single colorbar then applies to
% all of them.

mtexColorbar % remove colorbars
setColorRange('equal');
mtexColorbar % add a single colorbar

%%
% Now the three can be read against each other. The (202) figure reaches
% 15.8 where (104) stops at 9.8, so the same texture shows up far more
% strongly in one lattice plane than in another - which is the reason
% several pole figures are measured in the first place.
%
% One thing this figure also shows is that some intensities are negative,
% down to -1.8. No diffracted intensity is negative; that is the background
% correction subtracting too much, and <PoleFigureCorrection.html Data
% Correction> is where such things are dealt with.

%% Recalculated pole figures
%
% An ODF describes the orientations of the whole specimen, so a pole figure
% can be computed from it for any lattice plane - including planes that were
% never measured. Reconstructing one from the data is the subject of
% <PoleFigure2ODF.html ODF Estimation>.

odf = calcODF(pf,'silent')

%%
% Plotted for the same three planes as the measurements:

plotPDF(odf,pf.h,'antipodal')
mtexColorMap parula

%%
% These are smooth because the ODF is, not because the data were. Comparing
% them with the measured figures above is the standard check on a
% reconstruction: the maxima should sit in the same places and reach
% comparable heights. Where they do not, either the reconstruction or the
% data has a problem - see <PoleFigureCorrection.html Data Correction>.
