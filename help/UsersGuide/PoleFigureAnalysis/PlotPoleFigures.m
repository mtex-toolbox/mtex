%% Plotting of Pole Figures
% Described various possibilities to visualize pole figure data.
%
%% Contents
%
%% Open in Editor
%
%% Import of Pole Figures
%
% Let us start by importing some pole figures.

% crystal and specimen symmetry
CS = symmetry('mmm');
SS = symmetry('-1');

% file names
pname = [mtexDataPath '/ptx/'];
fname = {...
  [pname 'gt9104.ptx'], ...
  [pname 'gt9110.ptx'], ...
  [pname 'gt9202.ptx'], ...
  };

% create a Pole Figure variable containing the data
pf = loadPoleFigure(fname,CS,SS);

%% Visualize the Data
%
% By default MTEX plots pole figures by drawing a circly at every
% measurement position of a pole figure an coloring it corresponding to
% the measured intensity.

plot(pf,'position',[100 100 600 300])

%%
% MTEX tries to guess the right size of circle in order to produce a
% pleasing result. However, you can adjust this size using the option *MarkerSize*.

plot(pf,'MarkerSize',5)

%% Contour Plots
% Some people like to have there raw pole figures to be drawn as contour
% plots. This feature is not yet generally supported by MTEX. Note that
% measured pole figure may be given at a very irregular grid which would
% make it necessary to interpolate before drawing contours. In this case,
% however, it seems to be more reasonable to first compute an ODF and than
% to draw contour plots of the recalculated pole figures.
%
% Nevertheless, MTEX offers basic contour plots in the case of regular
% measurement grids.

plot(pf,'contourf')

%%
% Sometimes, it is desirable to draw all regions below or equal to zero
% white. This can be done using the command <setcolorrange.html setcolorrange>.

setcolorrange('zero2white');


%%
% When drawing a colorbar next to the pole figure plots it is necessary
% to have the same color coding in all plots. This can be done as following

setcolorrange('equal');
colorbar

%% Plotting Recalculated Pole Figures
%
% In order to draw recalculated one first needs to compute an ODF.

odf = calcODF(pf,'silent')

%%
% Now smooth pole figures can be plotted for arbitrary crystallographic directions.

plotpdf(odf,get(pf,'Miller'),'antipodal')
