%% Plot Types
%
% There are several ways in MTEX to plot spherical data. You can plot them
% as colored dots, as contour lines, as filled contour lines or as smoothly
% interpolated data. Another posibility is to plot one dimensional
% sections.
%
%% A Sample ODFs
%
% Let us first define a model ODF to be plotted later on.

cs = symmetry('-3m'); ss = symmetry('-1');
odf = fibreODF(Miller(1,1,0),zvector,cs,ss)
pf = simulatePoleFigure(odf,Miller(1,0,0),S2Grid('equispaced','reduced'));

%% Single Dots
% For raw pole figure data MTEX uses by default a plot where each datapoint
% is represented by a single dot colored accordingly to the intensity. You
% may addjust the size of the dots using the option *diameter*.

plot(pf)


%% Contour Plots
%
% Contour plots are plots consisting only of contour lines and mainly
% used for pole figure or ODF plots. The number or exact location of the
% contour levels can be specified as an option.

plotpdf(odf,Miller(1,0,0),'contour',0:0.5:4,'reduced')


%%  Filled Contour Plots
%
% Filled contour plots are obtained by the option *contourf*. Again you may
% pass as an option the number of contour lines or its exact location.

plotpdf(odf,Miller(1,0,0),'contourf','reduced')


%% Smooth Interpolated Plots
%
% The default plotting style for pole figures and ODFs is *smooth*. Which
% results in a colored plot without contour lines

plotpdf(odf,Miller(1,0,0),'reduced')


%% Line Plots
%
% Line plots are used by MTEX for one dimesional ODF plots, plots of Fourier
% coefficients and plots of kernel functions functions.
% They can be customized by the standard MATLAB linespec
% options. See [[MATLAB:doc linespec,linespec]]!

plotodf(odf,'radially','linewidth',2,'linestyle','-.')
