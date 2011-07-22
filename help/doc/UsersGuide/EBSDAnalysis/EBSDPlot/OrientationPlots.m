%% Plotting Individual Orientations
% Basics to the plot types for individual orientations data
%
%% Open in Editor
%
%% 
% This sections gives an overview over the functionality MTEX offers to
% visualize orientation data.
%
%% Contents
%

%%
% Let us first import some EBSD data with a [[matlab:edit mtexdata, script file]]

mtexdata aachen

%%
% and select all individual orientations of the Iron phase

o = get(ebsd('Fe'),'orientations')


%% Scatter Pole Figure Plot
% A scatter plot of these data within a specific pole figure can be
% produced by the command <orientation.plotpdf.html plotpdf>.

plotpdf(o,Miller(1,0,0))


%% Scatter (Inverse) Pole Figure Plot
% Accordingly, scatter plots in inverse pole figures are produced by the
% command  <orientation.plotpdf.html plotipdf>.

plotipdf(o,xvector)


%% Scatter Plot in ODF Sections
% For a scatter plot in sections of the orientation space the resposible 
% command is <orientation.plotodf.html plotodf>. In above examples the number
% of plotted orientations was chosen automatically such that the
% plot does not become to full. This number of randomly chosen orientations
% can be specified by the option *points*.

close all;figure('position',[100 100 700 400])
plotodf(o,'points',1000)


%% Scatter Plot in Axis Angle or Rodrigues Space
% Another posibility is to plot the single orientations directly into the
% orientation space, i.e., either in axis/angle parameterization or in Rodrigues
% parameterization.

scatter(o,'center',idquaternion)

%%
% Here, the optional option 'center' speciefies the center of the unique
% region in the orientation space.


%% Orientation plots for EBSD and grains
% Since EBSD and grain data involves single orientations above plotting
% commands are applicable for those objects as well.

%%
% Let us consider some grains [[EBSD.calcGrains.html,detected]] from the
% EBSD data

[grains,ebsd] = calcGrains(ebsd);

%%
% Then the scatter plot of the individual orientations of the Iron phase in
% the inverse pole figure is achieved by

plotipdf(ebsd('Fe'),xvector,'points',100, 'MarkerSize',3);

%%
% In the same way the mean orientations of grains can be visualized

plotipdf(grains,xvector,'phase',1,'points',100, 'MarkerSize',3);

%%
% Once can also colorize the scatter points by certain [[EBSD.get.html,EBSD
% properties]] or [[grain.get.html,grain properties]]

close all;
plotpdf(ebsd('Fe'),[Miller(1,0,0),Miller(1,1,0)],'antipodal','MArkerSize',4,...
  'property','mad')

%%
% or some abitrary data vector

close all;figure('position',[100 100 500 500])
plotodf(grains,'phase',1,'antipodal','sections',9,'MarkerSize',3,...
  'property',shapefactor(grains));

%% 
% Superposition of two scatter plots is achieved by the commands *hold on*
% and *hold off*.

close all
plotipdf(ebsd('Fe'),xvector,'MarkerSize',3,'points',100)
hold on
plotipdf(ebsd('Mg'),xvector,'MarkerSize',3,'points',100,'MarkerColor','r')
hold off

%%
% See also <PlotTypes_demo.html#5, Scatter plots> for more information
% about scatter plot and <SphericalProjection_demo.html,spherical
% projections>  for more information on spherical projections.
