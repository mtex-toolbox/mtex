%% Plotting EBSD Data
% This sections gives you an overview over the functionality MTEX offers to
% visualize EBSD data.
%
%
%% Import of EBSD Data
%
% Let us first import some EBSD data.

CS = [...
  symmetry('m-3m'),... % crystal symmetry phase 1
  symmetry('m-3m')];   % crystal symmetry phase 2
SS = symmetry('-1');   % specimen symmetry

% file name
fname = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];

% import ebsd data
ebsd = loadEBSD(fname,CS,SS,'interface','generic',...
  'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3' 'Mad' 'BC'},...
  'Columns', [2 3 4 5 6 7 8 9],...
  'ignorePhase', 0, 'Bunge');

%% Scatter (Inverse) Pole Figure Plot
% First we would like to plot a scatter plot of EBSD data in an (inverse) pole
% figure. This is done via the commands <ebsd_plotpdf.html plotpdf> and
% <ebsd_plotipdf.html plotipdf> respectively.

% A first try:
plotipdf(ebsd,xvector)

%% 
% We get the warning since in general it is not possible to plot multiple
% phases into one inverse pole figure (e.g. because they have different
% crystal symmetry). However, one can supperpose two inverse pole figure
% plots using the commands *hold on* and *hold off*. Morover, the phase to
% be plotted can be explicitely specified by the option *phase*:

plotipdf(ebsd,xvector,'MarkerSize',1,'phase',1,'complete','reduced')
hold on
plotipdf(ebsd,xvector,'MarkerSize',1,'phase',2,'MarkerColor','r','complete')
hold off

%% Scatter Plot in ODF Sections
% In order to plot EBSD data as a scatter plot in ODF sections one has to
% use the command <ebsd_plotodf.html plotodf>. In above examples the number
% of plotted orientations was allways automatically reduced such that the
% plot does not become to full. The number of randomly chosen orientations
% can be explicetly specified by the option *points*.

close all;figure('position',[100 100 500 300])
plotodf(ebsd,'phase',1,'points',10000)

%% Scatter Plot in Axis Angle or Rodriguez Space
% Another posibility is to plot the single orientations directly into the
% orientation space - either in axis/angle parameterization or in Rodriguez
% parameterization.

scatter(ebsd,'phase 1','center',idquaternion)

%% Spatial Single Orientation Plot
%
% If the EBSD data are provided with spatial coordinates, one can 
% asign a color to each orientation and plots a map of these colors.
% There are several options to specify the way the colors are assigned.


close all;figure('position',[100 100 600 300])
plot(ebsd,'reduced','phase',1)

%%
% In order to understand the colorcoding one can plot the coloring of the
% corresponding inverse pole figure via

colorbar
hold on
plotipdf(ebsd,'phase',1,'points',500,...
  'markerSize',3,'marker','o','markerfacecolor','none','markeredgecolor','k')
set(gcf,'renderer','opengl')
hold off

%% Spatial Plot of Other Properties
% Instead of the orientation one can also plot other properties of the
% meassured EBSD data, e.g. the phase, the error, ...

close all;figure('position',[100 100 600 300])
plot(ebsd,'colorcoding','phase')

%%

plot(ebsd,'colorcoding','MAD')

