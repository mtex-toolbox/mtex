%% Figure Zoo
%
% One plot of every kind the published pages contain, on one page. The layout
% sizes an axes by what it is - a spherical plot by one height, a map, a curve
% and a 3d body by the box they have to fit into - so a change to it has to be
% looked at across all of them at once rather than one page at a time.
%
% Publish it with <publishFigureZoo.html |publishFigureZoo|>, which sets the
% preferences the website build uses and writes the page to a temporary folder.

plottingConvention.default('y↑→x');

sF = S2FunHarmonic.quadrature(@(v) exp(-3*angle(v,vector3d(1,2,3)).^2), ...
  'bandwidth',16);
cs = crystalSymmetry('-3m');
odf = 0.7*unimodalODF(orientation.byEuler(110*degree,30*degree,80*degree,cs)) ...
  + 0.3*unimodalODF(orientation.byEuler(310*degree,70*degree,40*degree,cs));
ori = discreteSample(odf,200);

mtexdata twins silent
grains = calcGrains(ebsd('indexed'),'threshold',5*degree);

%% One spherical plot

close all
plot(sF)
mtexColorbar

%% A row of three

plotPDF(odf,Miller({1,0,0},{1,1,1},{0,0,1},cs),'antipodal')
mtexColorbar

%% A grid of twelve

plot(odf,'sections',12,'contourf','sigma')
mtexColorMap white2black
mtexColorbar

%% An EBSD map

close all
plot(ebsd('indexed'),ebsd('indexed').orientations)

%% A wide map
%
% Wide enough that the width of the box binds rather than its height.

close all
plot(ebsd(ebsd.y < 30),ebsd(ebsd.y < 30).orientations)

%% A grain map with boundaries

close all
plot(grains,grains.meanOrientation)
hold on
plot(grains.boundary,'lineWidth',1.5)
hold off

%% A map asked for larger

close all
plot(grains,grains.meanOrientation,'figSize','large')

%% A curve

close all
plotAngleDistribution(crystalSymmetry('432'),'linewidth',2)

%% A curve with a legend

close all
plotSpektra(SO3FunHarmonic(odf,'bandwidth',32),'DisplayName','two components')
hold on
plotSpektra(SO3FunHarmonic(fibreODF(Miller(1,0,0,cs),zvector),'bandwidth',32), ...
  'DisplayName','fibre')
hold off
legend show

%% A sphere in 3d

close all
plot(sF,'3d')
mtexColorbar

%% A crystal shape

close all
plot(crystalShape.hex(crystalSymmetry('6/mmm',[3.2 3.2 5.2],'mineral','Mg')))

%% Orientations in axis angle space

close all
scatter(ori,'axisAngle')

%% An inverse pole figure with a legend

close all
plotIPDF(odf,[xvector,zvector],'antipodal')
mtexColorMap white2black
mtexColorbar
