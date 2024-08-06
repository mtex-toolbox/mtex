%% Grain Boundary Normal Distribution
%
% In this section we discuss a stereographic approach of determining the
% grain boundary normal distribution from two dimensional EBSD data
% following the publications
%
% * D.M. Saylor, G.S. Rohrer:
% <https://doi.org/10.1111/J.1151-2916.2002.TB00531.X Determining crystal
% habits from observations of planar sections> in J. Am. Ceram. Soc.,
% 85(11):2799–2804, 2002.
%
% * R. Hielscher, R. Kilian, K. Marquardt, E. Wünsche: Efficient computation of the
% grain boundary normal distribution from two dimensional EBSD data, not
% yet published.
%
%%
% We start our demonstration by importing some EBSD data and reconstructing
% the grain structure.

mtexdata csl

[grains,ebsd.grainId] = calcGrains(ebsd);

grains = smooth(grains,10)

plot(ebsd,ebsd.orientations)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%% Misorientation angle at grain boundaries
% Next we separate the grain boundaries according to the misorientation
% angle. More precisely, we distinguish those grain boundaries with
% misorientation angle larger then 57 degree and those with a smaller
% misorientation angle.

gB = grains.boundary('indexed');
cond = gB.misorientation.angle > 57 * degree;

plot(ebsd,ebsd.orientations)
hold on
plot(grains.boundary,'lineWidth',2)
plot(gB(cond),'lineWidth',2,'lineColor','w')
hold off

%%
% Using the command <grainBoundary.calcGBPD.html |calcGBPD|> we can now
% compute the grain boundary plane distribution from a list of two
% dimensional traces.

gbnd1 = calcGBPD(gB(cond),ebsd)
gbnd2 = calcGBPD(gB(~cond),ebsd)

contourf(gbnd1,'colorrange',[0.8 1.5])
mtexTitle('GBPD for misorientation angle $> 57^{\circ}$')
mtexColorMap parula
nextAxis
contourf(gbnd2,'colorrange',[0.8 1.5])
mtexTitle('GBPD for misorientation angle $< 57^{\circ}$')
mtexColorMap parula
mtexColorbar 

%%
% We observe that for a twinning grain boundaries the boundary plane is
% mostly parallel to the (111) plane, while for all other grain boundaries
% no preferred boundary plane exists.
