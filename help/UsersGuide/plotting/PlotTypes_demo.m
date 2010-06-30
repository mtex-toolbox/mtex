%% Plot Types
% Explains the different plot types, i.e., scatter plots, contour plots,
% and line plots.
%
%% Open in Editor
%
%% Abstract
% 
%
%% Contents
%
%% A Sample ODFs
%
% Let us first define a model ODF to be plotted later on.

cs = symmetry('-3m'); ss = symmetry('-1');
odf = fibreODF(Miller(1,1,0),zvector,cs,ss)
pf = simulatePoleFigure(odf,Miller(1,0,0),S2Grid('equispaced','antipodal'));

%% Scatter Plots
% Three dimensional vectors, Miller indices, spherical grids are plotted as
% single markers in a spherical projection. The shape, size and color of
% the markers can be adjusted using the following parameters (see also
% [[matlab:doc scattergroupproperties,scattergroup_properties]])
%
% |Marker|, |MarkerSize|, |MarkerFaceColor|, |MarkerEdgeColor|

close all; figure('position',[50 50 200 200])
plot(zvector,'Marker','p','MarkerSize',15,'MarkerFaceColor','red','MarkerEdgeColor','black')

%%
% One can also assign a label to a marker. The main options controling the label
% are (see [[matlab:doc text_props,text_properties]])
%
% |Label|, |Color|, |BackgroundColor|, |FontSize|

plot([Miller(1,1,1),Miller(-1,1,1)],...
  'label',{'X','Y'},...
  'Color','blue','BackgroundColor','yellow','FontSize',20,'grid')

%%
% A scatter plot is also used to draw raw pole figure data. In this case
% each datapoint is represented by a single dot colored accordingly to the intensity.

close all;figure('position',[50 50 250 250])
plot(pf)



%% Contour Plots
%
% Contour plots are plots consisting only of contour lines and are mainly
% used for pole figure and ODF plots. The number or exact location of the
% contour levels can be specified as an option. (See [[matlab:doc
% contourgroupproperties,contourgroup_properties]] for more options!)

plotpdf(odf,Miller(1,0,0),'contour',0:0.5:4,'antipodal')


%%  Filled Contour Plots
%
% Filled contour plots are obtained by the option *contourf*. Again you may
% pass as an option the number of contour lines or its exact location.

plotpdf(odf,Miller(1,0,0),'contourf','antipodal')


%% Smooth Interpolated Plots
%
% The default plotting style for pole figures and ODFs is *smooth*. Which
% results in a colored plot without contour lines. Here one can specify the
% resolution of the plot using the option |resolution|.

plotpdf(odf,Miller(1,0,0),'antipodal','resolution',10*degree)


%% Line Plots
%
% Line plots are used by MTEX for one dimesional ODF plots, plots of Fourier
% coefficients and plots of kernel functions functions.
% They can be customized by the standard MATLAB linespec
% options. See [[matlab:doc linespec,linespec]]!

plotodf(odf,'radially','linewidth',2,'linestyle','-.')
