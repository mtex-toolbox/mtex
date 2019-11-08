%% Plotting Individual Orientations
% Basics of the plot types for individual orientations data
%
%% 
% This section gives an overview over the possibilities that MTEX offers to
% visualize orientation data. Let us first load a sample EBSD data set

mtexdata forsterite

%%
% and select all individual orientations of the Iron phase

ebsd('Fo').orientations


%% Scatter Pole Figure Plot
% A pole figure showing scattered points of these data figure can be
% produced by the command <orientation.plotPDF.html plotPDF>.

plotPDF(ebsd('Fo').orientations,Miller(1,0,0,ebsd('Fo').CS))


%% Scatter (Inverse) Pole Figure Plot
% Accordingly, scatter points in inverse pole figures are produced by the
% command  <orientation.plotIPDF.html plotIPDF>.

plotIPDF(ebsd('Fo').orientations,xvector)


%% Scatter Plot in ODF Sections
% The plotting of scatter points in sections of the orientation space is carried out by the
% command <orientation.plotSection.html plotSection>. In the above examples, the number
% of plotted orientations was chosen automatically such that the
% plots not to become too crowded with points. The number of randomly chosen orientations
% can be specified by the option *points*.

plotSection(ebsd('Fo').orientations,'points',1000,'sigma','sections',9)


%% Scatter Plot in Axis Angle or Rodrigues Space
% Another possibility is to plot the single orientations directly into the
% orientation space, i.e., either in axis/angle parameterization or in Rodrigues
% parameterization.

scatter(ebsd('Fo').orientations)

%%
% Here, the optional option 'center' specifies the center of the unique
% region in the orientation space.


%% Orientation plots for EBSD and grains
% Since EBSD and grain data involves single orientations, the above plotting
% commands are also applicable for those objects.

%%
% Let us consider some grains <EBSD.calcGrains.html reconstructed> from the
% EBSD data

grains = calcGrains(ebsd);

%%
% Then the scatter plot of the individual orientations of the Iron phase in
% the inverse pole figure is achieved by

plotIPDF(ebsd('Fo').orientations,xvector,'points',1000, 'MarkerSize',3);

%%
% In the same way, the mean orientations of grains can be visualized

hold all
plotIPDF(grains('Fo').meanOrientation,xvector,'points',500, 'MarkerSize',3);
hold off

%%
% One can also use different colors on the scatter points

h = [Miller(1,0,0,ebsd('Fo').CS),Miller(1,1,0,ebsd('Fo').CS)];
plotPDF(ebsd('Fo').orientations,ebsd('Fo').mad,h,'antipodal','MarkerSize',4)

%%
% or some arbitrary data vector

plotSection(grains('Fo').meanOrientation,log(grains('Fo').area),...
  'sigma','sections',9,'MarkerSize',10);
  
%%
% See also <PlotTypes_demo.html#5, Scatter plots> for more information
% about scatter plot and <SphericalProjection_demo.html,spherical
% projections>  for more information on spherical projections.
