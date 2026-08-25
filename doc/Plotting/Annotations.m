%% Annotations
%
%%
% A pole figure without a colorbar cannot be read, and one without marked
% directions can only be read by somebody who already knows what is in it.
% This page collects what is added to a figure after the data: colorbars,
% marked directions and orientations, legends and grids.

plottingConvention.default('y↑→x');

%% Colorbars
%
% <mtexColorbar.html |mtexColorbar|> differs from MATLAB's |colorbar| in
% that it addresses the whole figure - every axis of a multi-plot gets one.

% this defines some model ODFs
cs = crystalSymmetry('-3m');

mod1 = orientation.byEuler(110*degree,30*degree,80*degree,cs);
mod2 = orientation.byEuler(310*degree,70*degree,40*degree,cs);
odf = 0.7*unimodalODF(mod1) + 0.3*unimodalODF(mod2);

% plot some pole figures
plotPDF(odf,Miller({1,0,0},{1,1,1},cs))

% and add a colorbar to each pole figure
mtexColorbar

%%
% Two colorbars, and their ranges differ - the two pole figures are not on a
% common scale. Calling the command again removes them; |'location'| puts
% them elsewhere and |'title'| names the unit, which for a pole density is
% multiples of a random distribution.

% delete vertical colorbar
mtexColorbar

% add horizontal colorbars
mtexColorbar('location','southOutSide','title','mrd')

%%
% Once all axes share one colour range there is nothing left to distinguish,
% so a single colorbar is drawn for the figure - see
% <ColorMaps.html Color Coding>.

mtexColorbar       % delete colorbar
setColorRange('equal'); % set equal color range to all plots
mtexColorbar       % create a new colorbar

%% Marking directions and orientations
%
% <annotate.html |annotate|> adds to an existing figure without disturbing
% it - no |hold on| needed and no effect on the colour range. A specimen
% direction on the pole figures above:

annotate(vector3d(1,1,1),'label',{'(111)'},'BackgroundColor','w')

%%
% In an inverse pole figure the natural annotation is a crystal direction.
% |'all'| draws every symmetrically equivalent one and |'labeled'| writes
% the indices beside them.

plotIPDF(odf,[xvector,zvector],'antipodal','marginx',10)
mtexColorMap white2black

annotate(Miller({2,-1,-1,0},{2,-1,-1,1},cs), ...
  'all','labeled','BackgroundColor','yellow')

%%
% Whole orientations can be marked as well, and are then drawn wherever that
% orientation appears - one marker per pole in every axis of the figure.
% Here the two components the model ODF was built from:

plotIPDF(odf,[xvector,zvector],'antipodal')
mtexColorMap white2black
annotate(mod1,...
    'marker','s','MarkerSize',6,'MarkerFaceColor','r',...
    'label','A','color','w')

annotate(mod2,...
    'marker','s','MarkerSize',6,'MarkerFaceColor','g',...
    'label','B')

drawNow(gcm,'figSize','normal')

%%
% The red squares sit on the maxima and the green ones on the weaker
% component, which is how one checks that a plot shows what it is supposed
% to show.
%
% The same annotation works on ODF sections, where an orientation is a
% single point rather than a set of poles:

plot(odf,'sigma')
mtexColorMap white2black
annotate(mod1,'label','A','textColor','r',...
    'MarkerSize',15,'MarkerEdgeColor','r','MarkerFaceColor','none')

annotate(mod2,'label','B','textColor','b',...
  'MarkerSize',15,'MarkerEdgeColor','b','MarkerFaceColor','none')

%%
% and on scatter plots of individual orientations, where it shows what the
% cloud is scattered about:

ori = odf.discreteSample(200);
scatter(ori);
annotate(mod1,...
  'MarkerSize',10,'MarkerEdgeColor','r','MarkerFaceColor','r')
annotate(mod2,...
  'MarkerSize',10,'MarkerEdgeColor','g','MarkerFaceColor','g')

%% Legends
%
% Anything plotted with a |'DisplayName'| enters the legend, everything else
% stays out of it - see <Legends.html Legends>. In a multi-plot figure this
% combines with |'add2all'|:

plotPDF(odf,Miller({1,0,0},{1,1,1},cs))
plot(ori,'MarkerFaceColor','k','MarkerEdgeColor','black','add2all',...
  'DisplayName','randomSample')

f = fibre(Miller({1,1,-2,1},cs),vector3d.Y);
plot(f,'color','red','linewidth',2,'add2all','DisplayName','fibre')

legend show

%%
% The same in a line plot, where the legend is what makes two curves
% comparable at all - the harmonic coefficients of the two component ODF
% against those of a fibre ODF:

close all
plotSpektra(FourierODF(odf,32),'DisplayName','Unimodal ODF')
hold on
fodf = fibreODF(Miller(1,0,0,cs),zvector);
plotSpektra(FourierODF(fodf,32),'DisplayName','Fibre ODF');
hold off
legend show

%%
% The fibre ODF decays faster, as a function with a rotational symmetry
% must: it has fewer degrees of freedom to spend at each harmonic degree.

%% A spherical grid
%
% A grid of latitude and longitude lines makes the projection legible and
% lets angles be read off the figure. |'grid'| switches it on and
% |'grid_res'| sets the spacing.

plotPDF(odf,[Miller(1,0,0,cs),Miller(0,0,1,cs)],'grid','grid_res',15*degree,'antipodal');
mtexColorMap white2black

%%
% At 15 degrees the lines are close enough to measure with and far enough
% apart not to compete with the data.
