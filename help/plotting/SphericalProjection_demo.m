%% Spherical Plots
%
%% Open in Editor
%
%% Abstract
% MTEX supports four type of spherical projection which are avaiable for
% all spherical plot, e.g. <ODF_plotpdf.html polefigure plots>,
% <ODF_plotipdf.html inverse polefigure plots> or <ODF_plotodf.html
% ODF plots>. These are the equal area projection (Schmidt projection), the
% equal distance projetion, the stereographic projection (equal angle
% projection), the three dimensional projection and the flat projection.
%
%% Contents
%
%
%% Spherical Projections
%
% *A Sample ODF*
%
% Let us first define some model ODFs to be plotted later on.

cs = symmetry('-3m'); ss = symmetry('-1');
odf = fibreODF(Miller(1,1,0),zvector,cs,ss)

%%
% *Equal Area Projection (Schmidt Projection)*
%
% Equal area projection is defined by the characteristic that it preserves
% the spherical area. Since pole figures are defined as relative frequency
% by area equal area projection is the default projection in MTEX. In can
% be set explicetly by the flags *earea* or *schmidt*.

plotpdf(odf,Miller(1,0,0),'antipodal')


%%
% *Equal Distance Projection*
%
% The equal distance projection differs from the equal area projection by
% the characteristic that it preserves the distances of points to the
% origin. Hence it might be a more intuitive projection if you look at
% crystal directions.

cs = symmetry('m-3m');
plot(cs,'projection','edist','grid_res',15*degree,'antipodal')


%%
% *Stereographic Projection (Equal Angle Projection)*
%
% Another famouse spherical projection is the stereographic projection
% which preserves the angle between arbitrary great circles. It
% can be chosen by setting the option *stereo* or *eangle*.

plot(cs,'projection','eangle','antipodal','grid_res',15*degree)


%%
% *Plain Projection*
%
% *Plain* means that the polar angles theta / rho are plotted in a simple
% rectangular plot. This projection is often chosen for ODF plots, e.g.

close; figure('position',[46 171 752 486]);
plotodf(santafee,'alpha','sections',18,'resolution',5*degree,...
  'projection','plain','gray','contourf','FontSize',10,'silent')


%%
% *Three Dimensional Plots*
%
% MTEX also offers a three dimensional plot of pole figures which even
% might be rotated freely in space

close all;
plotpdf(odf,Miller(1,0,0),'3d')



%% Hemishpheres
%
% *Partial Spherical Plots*
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
% Due to Friedels law meassured pole figures are a superposition of the
% nothern and the southern hemisphere (since antipodal directions are
% associated). In order to plot pole figures as a superposition of the
% northern and southern hemisphere one has to enforce <AxialDirectional.html
% axial symmetry>. This is done by the option *antipodal*.

plotpdf(odf,Miller(1,1,0),'antipodal')


%% Alignment of the Plot
%
% *Rotate and Flip Plots*
%
% Sometimes it is more convenient to have the coordinate system rotated or
% flipped in some way. For this reason all plot commands in MTEX allows for
% the options *rotate*, *flipud* and *fliplr*. A more direct way for
% changing the orientation of the plot is to specify the direction of the
% x-axis by the commands <plotx2east.html plotx2east>, <plotx2north.html
% plotx2north>, <plotx2west.html plotx2west>, <plotx2south.html
% plotx2south>.

plotx2north

plotpdf(odf,Miller(1,0,0),'antipodal')
annotate([xvector,yvector,zvector],'data',{'X','Y','Z'},'backgroundcolor','w');

%%
plotx2east

plotpdf(odf,Miller(1,0,0),'antipodal')
annotate([xvector,yvector,zvector],'data',{'X','Y','Z'},'backgroundcolor','w');


