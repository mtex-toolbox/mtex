%% Plot Types
%
%% A Sample ODFs
%
% Let us first define a model ODF to be plotted later on.

cs = crystalSymmetry('-3m');
odf = fibreODF(Miller(1,1,0,cs),zvector)
pf = calcPoleFigure(odf,Miller(1,0,0,cs),equispacedS2Grid('antipodal'));

%%
% and simulate some EBSD data
ori = calcOrientations(odf,100)

%% Scatter Plots
% In a scatter plots individual points are plotted. This plot is usually
% applied when individual orientations or pole figure measurements are
% visualized.
%%
% 

close all
scatter(ori)

%%
% Three-dimensional vectors, Miller indices, spherical grids are plotted as
% single markers in a spherical projection. The shape, size, and color of
% the markers can be adjusted using the following parameters (see also
% <matlab:doc('scattergroupproperties') scattergroup_properties>)
%
% |Marker|, |MarkerSize|, |MarkerFaceColor|, |MarkerEdgeColor|

plot(zvector,'Marker','p','MarkerSize',15,'MarkerFaceColor','red','MarkerEdgeColor','black')

%%
% One can also assign a label to a marker. The main options controlling the label
% are (see <matlab:doc('text_props') text_properties>)
%
% |Label|, |Color|, |BackgroundColor|, |FontSize|

plot([Miller(1,1,1,cs),Miller(-1,1,1,cs)],...
  'label',{'X','Y'},...
  'Color','blue','BackgroundColor','yellow','FontSize',20,'grid')

%%
% A scatter plot is also used to draw raw pole figure data. In this case,
% each datapoint is represented by a single dot colored accordingly to the intensity.

plot(pf)


%% Contour Plots
%
% Contour plots are plots consisting only of contour lines and are mainly
% used for pole figure and ODF plots. The number or exact location of the
% contour levels can be specified as an option. See
% <https://de.mathworks.com/help/matlab/ref/matlab.graphics.chart.primitive.contour-properties.html contourgroup properties> for more
% options!

plotPDF(odf,Miller(1,0,0,cs),'contour',0:0.5:4,'antipodal')


%%  Filled Contour Plots
%
% Filled contour plots are obtained by the option *contourf*. Again you may
% pass as an option the number of contour lines or its exact location.

plotPDF(odf,Miller(1,0,0,cs),'contourf','antipodal')


%% Smooth Interpolated Plots
%
% The default plotting style for pole figures and ODFs is *smooth*. Which
% results in a colored plot without contour lines. Here one can specify the
% resolution of the plot using the option |resolution|.

plotPDF(odf,Miller(1,0,0,cs),'antipodal','resolution',10*degree)


%% Line Plots
%
% Line plots are used by MTEX for one-dimensional ODF plots, plots of Fourier
% coefficients and plots of kernel functions.
% They can be customized by the standard MATLAB linespec
% options. See <matlab:doc('linespec') linespec>!

f = fibre(Miller(1,0,0,cs),xvector);

plot(odf,f,'linewidth',2,'linestyle','-.')
