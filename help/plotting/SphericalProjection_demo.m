%% Spherical Projections
%
% MTEX supports four type of spherical projection which are avaiable for
% all spherical plot, e.g. <ODF_plotpdf.html polefigure plots>,
% <ODF_plotipdf.html inverse polefigure plots> or <ODF_plotodf.html
% ODF plots>. These are the equal area projection (Schmidt projection), the
% equal distance projetion (equal angle projection), the three dimensional
% projection and the flat projection. 
%
% Beside these standard projections there are options to custumize
% the projection:
%
%  REDUCED - plot superposition of northern and southern hemisphere
%  NORTH   - plot only points of the northern hemisphere 
%  SOUTH   - plot only points of the southern hemisphere
%  ROTATE  - rotate plot about z-axis about a given angle
%  FLIPUD  - FLIP plot upside down
%  FLIPLR  - FLIP plot left to rigth
%
%
%% A Sample ODF
%
% Let us first define some model ODFs to be plotted later on.

cs = symmetry('-3m'); ss = symmetry('-1');
odf = fibreODF(Miller(1,1,0),zvector,cs,ss)


%% Partial Spherical Plots
%
% If an ODF has tricline specimen symmetry its pole figures differs in
% general on the northern hemisphere and the southern hemisphere. By
% default MTEX plots in this case both hemispheres. The northern on the
% left hand side and the southern on the right hand side.

plotpdf(odf,Miller(1,1,0))

%%
%
% MTEX allows also to plot only the northern or the southern by passing the
% options *north* or *south*.

plotpdf(odf,Miller(1,1,0),'south')

%%
%
% Due to Friedels law meassured pole figures are a superposition of the
% nothern and the southern hemisphere (since antipodal directions are
% associated). In order to plot pole figures as a superposition of the
% northern and southern hemisphere use the option *reduced*.

plotpdf(odf,Miller(1,1,0),'reduced')


%% Equal Area Projection (Schmidt Projection)
%
% Equal area projection is defined by the characteristic that it preserves
% the spherical area. Since pole figures are defined as relative frequency
% by area equal area projection is the default projection in MTEX.

plotpdf(odf,Miller(1,0,0),'reduced')


%% Equal Distance Projection (Equal Angle Projection)
%
% The equal distance projection differs from the equal area projection by
% the characteristic that it preserves angles. Hence it is the more
% intuitive projection if you look for angles between crystal directions. 

plot(cs,'projection','edist','reduced')


%% Plain Projection
%
% *Plain* means that the polar angles theta / rho are plotted in a simple
% rectangular plot. This projection is often chosen for ODF plots, e.g.

close; figure('position',[46 171 752 486]);
plotodf(santafee,'alpha','sections',18,'resolution',5*degree,...
  'projection','plain','gray','contourf','FontSize',10,'silent')


%% Three Dimensional Plots
%
% MTEX also offers a three dimensional plot of pole figures which even
% might be rotated freely in space

close all; 
plotpdf(odf,Miller(1,0,0),'3d')


%% Rotate and Flip Plots
%
% Sometimes it is more convenient to have the coordinate system rotated or
% flipped in some way. For this reason all plot commands in MTEX allows for
% the options *rotate*, *flipud* and *fliplr*.

plotpdf(odf,Miller(1,0,0),'reduced','rotate',90*degree)
plot2all([xvector,yvector,zvector],'data',{'X','Y','Z'},...
  'rotate',90*degree,'FontSize',16);
