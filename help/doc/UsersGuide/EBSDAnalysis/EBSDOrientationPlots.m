%% Plotting Individual Orientations
% Basics to the plot types for individual orientations data
%
%% Open in Editor
%
%% 
% This sections gives an overview over the possibilities that MTEX offers to
% visualize orientation data.
%
%% Contents
%

%%
% Let us first import some EBSD data with a [[matlab:edit mtexdata, script file]]

mtexdata forsterite

%%
% and select all individual orientations of the Iron phase

ebsd('Fo').orientations


%% Scatter Pole Figure Plot
% A pole figure showing scattered points of these data figure can be
% produced by the command <orientation.plotpdf.html plotpdf>.

plotpdf(ebsd('Fo').orientations,Miller(1,0,0))


%% Scatter (Inverse) Pole Figure Plot
% Accordingly, scatter points in inverse pole figures are produced by the
% command  <EBSD.plotipdf.html plotipdf>.

plotipdf(ebsd('Fo'),xvector)


%% Scatter Plot in ODF Sections
% The plotting og scatter points in sections of the orientation space is carried out by the
% command <orientation.plotodf.html plotodf>. In the above examples the number
% of plotted orientations was chosen automatically such that the
% plots not to become too crowed with points. The number of randomly chosen orientations
% can be specified by the option *points*.

plotodf(ebsd('Fo'),'points',1000,'sigma')


%% Scatter Plot in Axis Angle or Rodrigues Space
% Another possibility is to plot the single orientations directly into the
% orientation space, i.e., either in axis/angle parameterization or in Rodrigues
% parameterization.

scatter(ebsd('Fo'),'center',idquaternion)

%%
% Here, the optional option 'center' specifies the center of the unique
% region in the orientation space.


%% Orientation plots for EBSD and grains
% Since EBSD and grain data involves single orientations, the above plotting
% commands are also applicable for those objects.

%%
% Let us consider some grains [[EBSD.calcGrains.html,detected]] from the
% EBSD data

grains = calcGrains(ebsd);

%%
% Then the scatter plot of the individual orientations of the Iron phase in
% the inverse pole figure is achieved by

plotipdf(ebsd('Fo'),xvector,'points',1000, 'MarkerSize',3);

%%
% In the same way the mean orientations of grains can be visualized

plotipdf(grains('Fo'),xvector,'points',500, 'MarkerSize',3);

%%
% Once can also use different colors on the scatter points by certain [[EBSD.get.html,EBSD
% properties]] or [[GrainSet.get.html,grain properties]]

plotpdf(ebsd('Fo'),[Miller(1,0,0),Miller(1,1,0)],'antipodal','MarkerSize',4,...
  'property','mad')

%%
% or some arbitrary data vector

plotodf(grains('Fo'),'antipodal','sections',9,'MarkerSize',3,...
  'property',shapefactor(grains('Fo')),'sigma');


%%
% See also <PlotTypes_demo.html#5, Scatter plots> for more information
% about scatter plot and <SphericalProjection_demo.html,spherical
% projections>  for more information on spherical projections.
