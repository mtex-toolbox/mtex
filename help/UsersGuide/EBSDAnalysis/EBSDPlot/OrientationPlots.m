%% Plotting Individual Orientations
% Basics to the plot types for individual orientations data
%
%% Open in Editor
%
%% 
% This sections gives you an overview over the functionality MTEX offers to
% visualize orientation data. Generally they are all
% [[PlotTypes_demo.html#5, Scatter plots]] of [[SphericalProjection_demo.html,spherical projections]]
%
%% Contents
%

%%
% Let us first import some EBSD data with a [[matlab:edit loadaachen.m, script file]]

loadaachen;

%%
% and take the individual orientation measurements (IOM) of one phase

o = get(ebsd,'orientations','phase',1)


%% Scatter Pole Figure Plot
% First we would like to plot a scatter plot of IOMs in an pole point figure. 
% This is done via the commands <orientation_plotpdf.html plotpdf>.

plotpdf(o,Miller(1,0,0))


%% Scatter (Inverse) Pole Figure Plot
% We also would like to plot a scatter plot IOMs in an (inverse)
% pole point figure. This is done via the command 
% <orientation_plotpdf.html plotipdf> respectively.

plotipdf(o,xvector)


%% Scatter Plot in ODF Sections
% In order to plot IOM data as a scatter plot in ODF sections one has to
% use the command <orientation_plotodf.html plotodf>. In above examples the number
% of plotted orientations was always automatically *antipodal* such that the
% plot does not become to full. The number of randomly chosen orientations
% can be explicetly specified by the option *points*.

close all;figure('position',[100 100 700 400])
plotodf(o,'points',1000,'antipodal')


%% Scatter Plot in Axis Angle or Rodrigues Space
% Another posibility is to plot the single orientations directly into the
% orientation space - either in axis/angle parameterization or in Rodrigues
% parameterization.
scatter(o,'phase 1','center',idquaternion)


%% Orientation plots for EBSD and grains
% Since EBSD and grain data involves single orientations above plotting
% commands are applicable onto those objects.

%%
% therefore let us first [[EBSD_segment2d.html,regionalize]] some EBSD Data

[grains ebsd] = segment2d(ebsd);

%%
% Since in generale EBSD data can have multiple *phases* (e.g. because of 
% different crystal symmetry), we specify the one we would like to plot
% explicitly. Furthermore we specify some additional plotting options

plotipdf(ebsd,xvector,'phase',1,'complete','antipodal','points',100, 'MarkerSize',3);

%%
% it also works for grains in the same way

plotipdf(grains,xvector,'phase',1,'complete','antipodal','points',100, 'MarkerSize',3);

%%
% also some [[EBSD_get.html,EBSD properties]] or [[grain_get.html,grain
% properties]] can be visualized

close all;
plotpdf(ebsd,[Miller(1,0,0),Miller(1,1,0)],'property','bc','phase',1,'antipodal','MarkerSize',3)

%%
% or some abitrary data vector

close all;figure('position',[100 100 500 500])
plotodf(grains,'property',shapefactor(grains),'phase',1,'antipodal','sections',9,'MarkerSize',3);

%% 
% However, one can supperpose two scatter plots using the commands *hold on*
% and *hold off*.

close all
plotipdf(ebsd,xvector,'MarkerSize',3,'phase',1,'complete','antipodal','points',100)
hold on
plotipdf(ebsd,xvector,'MarkerSize',3,'phase',2,'MarkerColor','r','complete','points',100)
hold off




