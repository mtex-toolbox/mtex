%% Combinded Plots
%
% Sometimes it is usefull to combine several plots, e.g. plotting on the
% top of an inverse pole figure some important crystall directions. This
% can be performed by the command <a href="matlab:doc hold">hold all</a>,
% which preserfes MATLAB from replacing the old plot by the new one.
%


%% Combine Different EBSD Data
% First we want to superpose the above EBSD pole figure with another EBSD
% pole figure.

%%
% some simualted EBSD data
cs = symmetry('-3m'); ss = symmetry('triclinic');
odf = unimodalODF(idquaternion,cs,ss);
ebsd = simulateEBSD(odf,100);
ebsd_rotated = simulateEBSD(rotate(odf,euler2quat(60*degree,60*degree,0*degree)),100);

%%
% Plot a superpostion of pole figures of both EBSD data sets.

h = [Miller(0,0,0,1,cs),Miller(1,0,-1,0,cs)];
plotpdf(ebsd,h,'reduced','diameter',0.05)
hold all % keep plot
plotpdf(ebsd_rotated,h,'diameter',0.05);
hold off % next plot command deletes all plots

%% Combine Smooth Pole Figure Plots with EBSD Data
% Combining a contour plot of a model ODF with a scatter plot of single
% orientations.

plotpdf(odf,h,'reduced','contourf','gray','grid')
hold all
plotpdf(ebsd,h,'reduced','diameter',0.05,'bulletcolor','b')
hold all
plotpdf(ebsd_rotated,h,'diameter',0.05,'bulletcolor','r');
hold off

%% Add Miller Indece to a Inverse Pole Figure Plot
% Next we are going to add some Miller indece to an inverse pole figure
% plot.

close all;
plotipdf(odf,xvector);

hold all % keep plot
plot(Miller(1,1,-2,0,cs),'all')
plot(Miller(0,1,-1,0,cs),'all')
plot(Miller(1,1,-2,1,cs),'all')
hold off % next plot command deletes all plots
set(gcf,'position',[100,100,300,220]);
