%% Generating Plots
%
% MTEX makes it easy to generate publication ready plots of pole figures,
% inverse pole figures, ODFs, single orientations, etc. This plot might be
% exported in various formats, e.g. pdf, jpg, eps, png, adobe
% illustrator and much more. There is a large list of options which can
% be passed to the MTEX plot command to customize the plot.
%
%
%% Some sample ODFs
%
% Let us first define some model ODFs to be plotted later on.

cs = symmetry('-3m'); ss = symmetry('-1');
odf = fibreODF(Miller(1,1,0),zvector,cs,ss)
pf = simulatePoleFigure(odf,Miller(1,0,0),S2Grid('equispaced','reduced'));


%% Plot Types
%
% In general MTEX knows the following plot types
%
% * contour plots 
% * filled contour plots 
% * smoots plots
% * dots 
% * line plots

%%
% Contour plots are plots consisting only of contour lines and mainly
% used for pole figure or ODF plots. The number of contour levels can be
% specified as an option.

plotpdf(odf,Miller(1,0,0),'contour','reduced')

%% 
% Alternatively, the exact position of the contour lines may be
% specified.

plotpdf(odf,Miller(1,0,0),'contour',0:1:4,'reduced')

%%
% Filled contour plots are obtained by the option *contourf*.
plotpdf(odf,Miller(1,0,0),'contourf','reduced')

%%
% The default plotting style for pole figures and ODFs is *smooth*. Which
% results in a colored plot without contour lines
plotpdf(odf,Miller(1,0,0),'reduced')

%%
% For raw pole figure data MTEX uses by default a plot where each datapoint
% is represented by a single dot colored accordingly to the intensity.
plot(pf)

%%
% The diameter of the dots is adjusted automatically by MTEX. However in
% case you want to customize it my hand you can use the option
% *diameter*.
plot(pf,'diameter',0.02)

%%
% Line plots are used by MTEX for one dimesional ODF plots, plots of Fourier
% coefficients and plots of kernel functions functions
close all
plotodf(odf,'radially')

%%
% One dimensional plots can be customized by the standard MATLAB linespec
% options. See [[MATLAB:doc linespec,linespec]]!
plotodf(odf,'radially','linewidth',2)

%% Spherical Projections
%
% MTEX supports four type of spherical projection, these are
%
% * Schmidt / equal area projection
% * equal distance / angle projection
% * plain
% * three dimensional projection 
%
% Beside these standard projections there are some options to custumize
% the projection:
%
%  REDUCED - plot superposition of northern and southern hemisphere
%  NORTH   - plot only points of the northern hemisphere 
%  SOUTH   - plot only points of the southern hemisphere
%  ROTATE  - rotate plot about z-axis about a given angle
%  FLIPUD  - FLIP plot upside down
%  FLIPLR  - FLIP plot left to rigth
%

%%
% Equal area projection is defined by the characteristic that it preserves
% the spherical area. Since pole figures are defined as relative frequency
% by area equal area projection is the default projection in MTEX.
plotpdf(odf,Miller(1,0,0),'reduced')

%%
% The equal distance projection differs from the equal area projection by
% the characteristic that it preserves angles. Hence it is the more
% intuitive projection if you look for angles between crystal directions. 
plot(cs,'projection','edist','reduced')

%%
% *Plain* means that the polar angles theta / rho are plotted in a simple
% rectangular plot. This projection is often chosen for ODF plots, e.g.
close; figure('position',[46 171 752 486]);
plotodf(santafee,'alpha','sections',18,'resolution',5*degree,...
  'projection','plain','gray','contourf','FontSize',10,'silent')


%%
% MTEX also offers a three dimensional plot of pole figures which even
% might be rotated freely in space
close all; 
plotpdf(odf,Miller(1,0,0),'3d')

%% Color Coding
%
% A central issue when interpreting plots is to have a consistent color
% coding among all plots. In MTEX this can be achieved in two ways. If the 
% the minimum and maximum value is known then one can use one of the
% following syntaxes to have a consistent color coding.
%
%%
close all
plotpdf(odf,[Miller(1,0,0),Miller(1,1,1)],'contourf',0:0.5:5,'reduced')
figure
plotpdf(.5*odf+.5*uniformODF(cs,ss),[Miller(1,0,0),Miller(1,1,1)],...
  'colorrange',[0 5],'reduced');

%% 
% The color range can be adjusted afterwards by
setcolorrange([0.38,3.9],'all')


%% 
% If the minimum and maximum value is unknown one can use the option
% *equal* to obtain consistent plots. Compare the following two command
% sequences!

figure(1)
plotpdf(odf,[Miller(1,0,0),Miller(1,1,1)],'colorrange','equal','reduced')
figure(2)
plotpdf(.5*odf+.5*uniformODF(cs,ss),[Miller(1,0,0),Miller(1,1,1)],...
  'colorrange','equal','reduced');

%%
figure(1)
plotpdf(odf,[Miller(1,0,0),Miller(1,1,1)],'reduced')
figure(2)
plotpdf(.5*odf+.5*uniformODF(cs,ss),[Miller(1,0,0),Miller(1,1,1)],'reduced');
setcolorrange('equal','all')


%% 
% Sometimes logarithmic sclaed plots are of intersted. For this case all
% plots in MTEX understand the option *logarithmic*, e.g.
close all;
plotpdf(odf,[Miller(1,0,0),Miller(1,1,1)],'reduced','logarithmic')

%% 
% Monochrome plots are obtained by the option *gray*.
plotpdf(odf,[Miller(1,0,0),Miller(1,1,1)],'reduced','gray')

%% Plot Annotations
%
% After generating a plot with MTEX it is possible to modify it
% interactivly using the MATLAB plotting tools in the plotting figure. This
% includes
%
% * adding a colorbar
% * adding a legend
% * adding annotations
% * resizing / shifting parts of the plot

%% 
% If you which to have a colorbar right to the plots you first have to
% ensure that the color coding is equal in each subplot (see the techniques
% above). Then you can press the colorbar button in the plotting window and
% resize and move the colorbar such that it fits nicely. If you want to add
% a colorbar automaticaly then you have to resize the figure first be the
% command *set(gcf,'position',[x0 y0 dx dy])* and use the command
% *colorbar* to add a colorbar to the free space.
%

plotpdf(odf,[Miller(1,0,0),Miller(1,1,1)],'reduced','gray')
colorbar
plot2all([xvector,yvector,zvector],'data',{'X','Y','Z'});

%%
plotpdf(odf,[Miller(1,0,0),Miller(1,1,1)],'reduced')
colorbar('south')

%% Exporting Plots
%
% Plots generated by MTEX can be exported to a wide range of formats using
% the MATLAB function *save as* in the figure menu or using the command
% [[savefigure.html,savefigure]]


%% Changing the Default Plotting Options
%
% If you want to change the default plotting options, e.g. set color coding
% to *equal* in each plot or allways use the option *reduced*. Then the
% desired options can be added in the start up file 
% [[matlab: edit mtex_settings.m,mtex_settings]] to the option
% *default_plot_options*.
%
