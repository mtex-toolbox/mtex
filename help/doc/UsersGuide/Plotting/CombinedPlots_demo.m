%% Combinded Plots
% Explains how to combine several plots, e.g. plotting on the
% top of an inverse pole figure some important crystal directions. 
%
%% Open in Editor
%
%% Contents
%

%% General Principle
% In order to tell MATLAB to plot one plot right on the top of an older
% plot one has to use the commands [[matlab:doc hold,hold all]] and
% [[matlab:doc hold,hold off]]. Let's demostrate this using a simple example.

plot([2 2])

hold all

plot([1 3])

hold off

%% Combine Different EBSD Data
% First we want to show up two different EBSD data sets in one plot

%%
% let's simulate some EBSD data
cs = symmetry('-3m'); ss = symmetry('triclinic');
odf = unimodalODF(orientation('euler',0,0,0,cs,ss));
ebsd = calcEBSD(odf,100);
ebsd_rotated = calcEBSD(rotate(odf,rotation('Euler',60*degree,60*degree,0*degree)),100);

%%
% plot them as a scatter plot in axis / angle parametrized orientation
% space

scatter(ebsd)
hold all
scatter(ebsd_rotated);
hold off


%%
% a second way would be to superpose the pole figures of both EBSD data sets.

h = [Miller(0,0,0,1,cs),Miller(1,0,-1,0,cs)];
plotpdf(ebsd,h,'antipodal','MarkerSize',4)
hold all % keep plot
plotpdf(ebsd_rotated,h,'MarkerSize',4);
hold off % next plot command deletes all plots


%% Combine countoured pole figures (smooth ODF plots) with EBSD Data Scatter Plots
% You can also combine a contour plot of a model ODF with a scatter plot of single
% orientations.

plotpdf(odf,h,'antipodal','contourf','grid')
mtexColorMap white2black
hold all
plotpdf(ebsd,h,'antipodal','MarkerSize',5,'MarkerColor','b','MarkerEdgeColor','w')
hold all
plotpdf(ebsd_rotated,h,'MarkerSize',5,'MarkerColor','r','MarkerEdgeColor','k');
hold off
hh = legend({'EBSD 1','EBSD 2'},'units','normalized','position',[0.022 0.9 0.1 0.08]);

%%
% and, of course, you can do the same with ODF plots:

plotodf(odf,'sections',8,'contourf','sigma')
mtexColorMap white2black
hold all
plotodf(ebsd,'MarkerSize',8,'MarkerColor','b','MarkerEdgeColor','w')
plotodf(ebsd_rotated,'MarkerSize',8,'MarkerColor','r','MarkerEdgeColor','k');
hold off


%% Add Miller Indices to an Inverse Pole Figure Plot
% Next we are going to add some Miller indices to an inverse pole figure
% plot.

plotipdf(odf,xvector);
mtexColorMap white2black

hold all % keep plot
plot(Miller(1,1,-2,0,cs),'symmetrised','labeled')
plot(Miller(0,1,-1,0,cs),'symmetrised','labeled')
plot(Miller(0,1,-1,1,cs),'symmetrised','labeled')
hold off % next plot command deletes all plots

%% Combining different plots in one figure
% The next example demonstrates how to arrange arbitary plots into one
% figure

% let us import some pole figure data
mtexdata dubna

%%
% next we compute an ODF out of them
odf = calcODF(pf)

%%
% now we want to plot the original data alongsite with the recalculated
% pole figures and with a difference plot
figure('position',[50 50 1200 500])

% set position 1 in a 1x3 matrix as the current plotting position
axesPos = subplot(1,3,1)

% plot pole figure 1 at this position
plot(axesPos,pf({1}))

% set position 2 in a 1x3 matrix as the current plotting position
axesPos = subplot(1,3,2)

% plot the recalculated pole figure at this position
plotpdf(axesPos,odf,h{1},'antipodal')

% set position 3 in a 1x3 matrix as the current plotting position
axesPos = subplot(1,3,3)

% plot the difference pole figure at this position
plotDiff(axesPos,odf,pf({1}))

