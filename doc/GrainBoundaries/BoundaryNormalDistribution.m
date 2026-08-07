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
% We start our demonstration by importing some Magnesium data and
% reconstructing the grain structure. Magnesium deforms by tension twinning
% on the $\{10\bar{1}2\}$ plane, which makes it a good example here - the
% twin boundaries are coherent, i.e. they actually lie on that plane.

mtexdata twins

[grains,ebsd] = calcGrains(ebsd,'angle',5*degree,'minPixel',3);

grains = smooth(grains,10)

CS = grains.CS;

plot(ebsd,ebsd.orientations)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%% Misorientation angle at grain boundaries
% Next we separate the grain boundaries according to the misorientation
% angle. The tension twins of Magnesium show up as a sharp peak at 86.3
% degree, so we distinguish those grain boundaries with a misorientation
% angle larger then 80 degree and those with a smaller misorientation
% angle.

gB = grains.boundary('indexed');
cond = gB.misorientation.angle > 80 * degree;

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

% the twinning plane, marked in the plot below
tp = Miller(1,0,-1,2,CS,'hkil');

% both are plotted with the same color range, otherwise the almost uniform
% distribution on the right hand side would be stretched to look structured
contourf(gbnd1,'colorrange',[0.5 1.5])
mtexTitle('GBPD for $\omega > 80^{\circ}$')
mtexColorMap parula
annotate(tp,'label','$\{10\bar{1}2\}$','backgroundColor','w')
nextAxis
contourf(gbnd2,'colorrange',[0.5 1.5])
mtexTitle('GBPD for $\omega < 80^{\circ}$')
mtexColorMap parula
mtexColorbar

%%
% We observe that for the twinning grain boundaries the boundary plane is
% mostly parallel to the $\{10\bar{1}2\}$ twinning plane, while for all
% other grain boundaries no preferred boundary plane exists. Indeed, the
% maximum of the left hand side distribution is only a few degrees away
% from $\{10\bar{1}2\}$

[value,pos] = max(gbnd1);
[value, min(angle(pos,symmetrise(tp)))./degree]

%%
% while the distribution of all remaining boundaries stays close to one
% everywhere

[min(gbnd2),max(gbnd2)]
