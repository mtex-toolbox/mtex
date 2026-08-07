%% Spherical Projections
%%
plottingConvention.default('y↑→x');
%%
% MTEX supports four types of spherical projection which are available for
% all spherical plot, e.g. <SO3Fun.plotPDF.html polefigure plots>,
% <SO3Fun.plotIPDF.html inverse polefigure plots> or <SO3Fun.plotSection.html
% ODF plots>. These are the equal area projection (Schmidt projection), the
% equal distance projection, the stereographic projection (equal angle
% projection), the three-dimensional projection and the flat projection.
%
% In order to demonstrate the different projections we start by defining a
% model ODF.

cs = crystalSymmetry('321');
odf = fibreODF(Miller(1,1,0,cs),zvector)

%% Alignment of the Hemispheres
%
% *Partial Spherical Plots*
%
% If an ODF has triclinic specimen symmetry its pole figures differs in
% general on the upper hemisphere and the lower hemisphere. By
% default MTEX plots, in this case, both hemispheres. The upper on the
% left-hand side and the lower on the right-hand side.

plotPDF(odf,Miller(1,1,0,cs),'minmax')

%%
%
% MTEX allows also to plot only the upper or the lower hemisphere by
% passing the options |'upper'| or |'lower'|.

plotPDF(odf,Miller(1,1,0,cs),'lower')
mtexColorbar

%%
% Due to Friedel's law measured pole figures are a superposition of the
% upper and the lower hemisphere (since antipodal directions are
% associated). In order to plot pole figures as a superposition of the
% upper and lower hemisphere one has to enforce <VectorsAxes.html
% antipodal symmetry>. This is done by the option |'antipodal'|.

plotPDF(odf,Miller(1,1,0,cs),'antipodal')
mtexColorbar

%% Alignment of the Coordinate Axes
%
% The alignment of the plot on the screen is controlled by the
% @plottingConvention. One can specify any vector to point out of the
% screen or east, north, west or south.

how2plot = plottingConvention;
how2plot.north = zvector;
how2plot.outOfScreen = xvector;

plotPDF(odf,Miller(1,0,0,cs),'antipodal',how2plot)

%% Equal Area Projection (Schmidt Projection)
%
% Equal area projection is defined by the characteristic that it preserves
% the spherical area. Since pole figures are defined as relative frequency
% by area, equal area projection is the default projection in MTEX. It can
% be set explicitly by the options |'earea'| or |'schmidt'|.

plotPDF(odf,Miller(1,0,0,cs),'antipodal','projection','earea')

%% Equal Distance Projection and Equal Angle (Stereographic) Projection 
%
% The equal distance projection differs from the equal area projection by
% the characteristic that it preserves the distances of points to the
% origin. Hence it might be a more intuitive projection if you look at
% crystal directions. 
% Another famous spherical projection is the
% stereographic projection which preserves the angle between arbitrary
% great circles. It can be chosen by setting the option |'stereo'| or
% |'eangle'|.

cs = crystalSymmetry('m-3m');
plotHKL(cs,'projection','earea','upper','grid_res',15*degree,'BackGroundColor','w')
mtexTitle('equal area')
nextAxis
plotHKL(cs,'projection','edist','upper','grid_res',15*degree,'BackGroundColor','w')
mtexTitle('equal distance')
nextAxis
plotHKL(cs,'projection','eangle','upper','grid_res',15*degree,'BackGroundColor','w')
mtexTitle('equal angle')

%% Plain Projection
%
% *Plain* means that the polar angles theta / rho are plotted in a simple
% rectangular plot. This projection is often chosen for ODF plots, e.g.

plot(SantaFe,'alpha','sections',18,...
  'projection','plain','contourf','FontSize',10,'silent')
mtexColorMap white2black


%% Three-dimensional Plots
%
% MTEX also offers a three-dimensional plot of pole figures which even
% might be rotated freely in space

howt2plot = plottingConvention;
howt2plot.north = zvector;
howt2plot.outOfScreen = vector3d(-2,-1,0);

close all
plotPDF(odf,Miller(1,1,0,odf.CS),'3d',howt2plot)
setCamera(howt2plot)
mtexColorMap parula
