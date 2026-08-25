%% Spherical Projections
%
%%
% A sphere cannot be flattened without distorting something, and which
% something is given up decides what a figure may be used for. MTEX offers
% four projections plus a three dimensional view, and they are available on
% every spherical plot - <SO3Fun.plotPDF.html pole figures>,
% <SO3Fun.plotIPDF.html inverse pole figures>,
% <SO3Fun.plotSection.html ODF sections>.
%
% Before the projection there are two other decisions: which hemisphere is
% drawn, and how the axes are aligned on screen.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('321');
odf = fibreODF(Miller(1,1,0,cs),zvector)

%% Which hemisphere
%
% With triclinic specimen symmetry the two hemispheres of a pole figure
% differ, so both are drawn: the upper on the left, the lower on the right.

plotPDF(odf,Miller(1,1,0,cs),'minmax')

%%
% |'upper'| and |'lower'| ask for one of them alone.

plotPDF(odf,Miller(1,1,0,cs),'lower')
mtexColorbar

%%
% A measured pole figure is neither. Friedel's law makes diffraction blind
% to the difference between a direction and its opposite, so a measurement
% is the superposition of the two hemispheres - which is what |'antipodal'|
% produces, and what any figure compared with measured data has to use.

plotPDF(odf,Miller(1,1,0,cs),'antipodal')
mtexColorbar

%% Alignment on screen
%
% Which specimen direction points where is a property of the reference frame
% rather than of the plot - <AxesAlignment.html Axes Alignment> covers this
% in full. For one figure the convention may be passed directly.

how2plot = plottingConvention('z↑→y')

plotPDF(odf,Miller(1,0,0,cs),'antipodal',how2plot)

%% Equal area, the default
%
% The equal area or Schmidt projection preserves area. A pole figure is a
% density per unit area, so this is the projection in which the eye's
% impression of how much of the sphere something covers is not misleading -
% which is why it is the default. |'earea'| or |'schmidt'| ask for it
% explicitly.

plotPDF(odf,Miller(1,0,0,cs),'antipodal','projection','earea')

%% Equal distance and equal angle
%
% The equal distance projection preserves the distance of a point from the
% centre, so an angle from the pole can be read off with a ruler. The
% stereographic or equal angle projection preserves angles between great
% circles, which is what makes crystallographic constructions work on it.
%
% The three side by side, on the crystal directions of a cubic symmetry:

cs = crystalSymmetry('m-3m');
plotHKL(cs,'projection','earea','upper','grid_res',15*degree,'BackGroundColor','w')
mtexTitle('equal area')
nextAxis
plotHKL(cs,'projection','edist','upper','grid_res',15*degree,'BackGroundColor','w')
mtexTitle('equal distance')
nextAxis
plotHKL(cs,'projection','eangle','upper','grid_res',15*degree,'BackGroundColor','w')
mtexTitle('equal angle')

%%
% The same directions in all three, in visibly different places. Compare the
% spacing of the grid circles from the centre outwards: equal distance keeps
% it constant, equal area crowds it towards the rim, and equal angle spreads
% it. A figure without its projection named is therefore not fully specified,
% and mixing two of them in one comparison is a mistake that is hard to see.

%% Plain projection
%
% |'plain'| is not a spherical projection at all: it plots the polar angles
% theta and rho as rectangular coordinates. Angles are then easy to read off
% and areas are meaningless - the poles of the sphere are stretched into
% whole edges. It is the traditional presentation for ODF sections.

plot(SantaFe,'alpha','sections',18,...
  'projection','plain','contourf','FontSize',10,'silent')
mtexColorMap white2black

%% Three dimensions
%
% The alternative to projecting is not to. A three dimensional plot shows
% the sphere as a sphere and can be rotated freely, at the price that half
% the data is behind the other half at any moment. |'grid'| lays a spherical
% grid over it and |'grid_res'| sets the spacing.

how2plot = plottingConvention;
how2plot.east = vector3d(9,3,3);
how2plot.outOfScreen = vector3d(6,10,9);

close all
plotPDF(odf,Miller(1,1,0,odf.CS),'3d',how2plot,'grid','grid_res',10*degree,'noTitle')
mtexColorMap LaboTeX

%%
% This is the plot to reach for when the question is where something is on
% the sphere, and the one to avoid when the question is how much of it there
% is - nothing about a perspective view preserves area.
