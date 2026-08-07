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
% The command <grainBoundary.calcGBND.html |calcGBND|> computes three
% closely related distributions, distinguished by what is passed to it
%
% * the *specimen GBND* - the distribution of the boundary normals in
% specimen coordinates. It answers whether the boundaries prefer a
% direction in the sample.
% * the *crystal GBND* - the distribution of the boundary normals in
% crystal coordinates. It answers which lattice planes the boundaries
% prefer, i.e. the habit planes.
% * the *GBCD* - the grain boundary character distribution, i.e. the
% crystal GBND restricted to those boundaries that have one fixed
% misorientation.
%
% From two dimensional data only the crystal GBND and the GBCD are
% accessible, since a planar section reveals the boundary traces but not
% the inclination of the boundary planes. The specimen GBND requires three
% dimensional data and is discussed at the end of this section.
%
%% The crystal GBND from two dimensional EBSD data
%
% We start by importing some Magnesium data and reconstructing the grain
% structure. Magnesium deforms by tension twinning on the $\{10\bar{1}2\}$
% plane, which makes it a good example here - the twin boundaries are
% coherent, i.e. they actually lie on that plane.

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
% Passing the grain boundaries together with the EBSD data to
% <grainBoundary.calcGBND.html |calcGBND|> gives the crystal GBND, i.e. the
% distribution of the boundary normals in crystal coordinates.
%
% Recovering a three dimensional distribution from planar sections is a
% deconvolution, and without any constraint the result rings, i.e. it
% oscillates around the true distribution and may even become negative.
% The option |nonneg| enforces a nonnegative result, which is what we want
% for a density.

gbnd1 = calcGBND(gB(cond),ebsd,'halfwidth',5*degree,'nonneg')
gbnd2 = calcGBND(gB(~cond),ebsd,'halfwidth',5*degree,'nonneg')

% the twinning plane. These are plots of the full sphere, so we mark all
% symmetrically equivalent variants - marking only (10-12) would single out
% one of the six maxima for no reason
tp = Miller(1,0,-1,2,CS,'hkil');

% both are plotted with the same color range, otherwise the almost uniform
% distribution on the right hand side would be stretched to look structured
contourf(gbnd1,'colorrange',[0.5 1.5])
mtexTitle('GBND for $\omega > 80^{\circ}$')
mtexColorMap parula
annotate(symmetrise(tp),'label','$\{10\bar{1}2\}$','backgroundColor','w')
nextAxis
contourf(gbnd2,'colorrange',[0.5 1.5])
mtexTitle('GBND for $\omega < 80^{\circ}$')
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

%% The grain boundary character distribution (GBCD)
%
% Splitting the boundaries by misorientation angle as above is a crude
% selection. Passing a misorientation as a third argument restricts the
% computation to those boundaries whose misorientation is close to it and
% aligns them accordingly. The result is the GBCD for that misorientation.

% the ideal Magnesium tension twin
moriRef = orientation.byAxisAngle(Miller(1,1,-2,0,CS,'uvtw'),86.3*degree,CS,CS);

gbcd = calcGBND(gB,grains,moriRef,'halfwidth',5*degree,'nonneg')

plot(gbcd,'contourf')
mtexTitle('GBCD for the tension twin')
mtexColorMap parula
annotate(symmetrise(tp),'label','$\{10\bar{1}2\}$','backgroundColor','w')
mtexColorbar

%%
% Two of the six $\{10\bar{1}2\}$ variants carry the maxima - the specimen
% was deformed, so not every twin variant is equally active. Accordingly
% the maximum sits right on a twinning plane

[value,pos] = max(gbcd);
[value, min(angle(pos,symmetrise(tp)))./degree]

%% Three dimensional data
%
% For three dimensional grains the boundary normals are known directly, so
% no stereological reconstruction is required and all three distributions
% become accessible. We use the Dream3d data set that is also discussed in
% <Grains3D.html Three dimensional grains>.

grains3 = grain3d.load(fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d'));

% the faces at the surface of the measured volume belong to one grain only
gB3 = grains3.boundary;
gB3 = gB3(all(gB3.grainId > 0,2))

%%
% Note that we have removed the faces at the surface of the specimen. Those
% are not grain boundaries at all, but the six sides of the measured box.
% They make up almost a quarter of the total face area and, being flat and
% axis aligned, they would dominate the specimen GBND computed below.

%% The specimen GBND
%
% Called with the boundary alone, |calcGBND| gives the distribution of the
% boundary normals in specimen coordinates.

gbndSpecimen = calcGBND(gB3)

plot(gbndSpecimen,'contourf','upper')
mtexTitle('specimen GBND')
mtexColorMap parula
mtexColorbar

%% The crystal GBND
%
% Passing the grains in addition rotates every normal into the coordinate
% system of its grain, which gives the crystal GBND.

gbndCrystal = calcGBND(gB3,grains3)

plot(gbndCrystal,'contourf')
mtexTitle('crystal GBND')
mtexColorMap parula
mtexColorbar

%%
% For this data set the crystal GBND is almost uniform, i.e. taken over all
% grain boundaries there is no preferred habit plane

[min(gbndCrystal),max(gbndCrystal)]

%% The GBCD in three dimensions
%
% This changes as soon as we restrict to a single misorientation. About a
% quarter of the inner faces of this data set are $\Sigma 3$ twin
% boundaries, and for those the boundary plane is a $\{111\}$ plane.

cs3 = grains3.CSList(2);
sigma3 = orientation.byAxisAngle(Miller(1,1,1,cs3),60*degree,cs3,cs3);

gbcd3 = calcGBND(gB3,grains3,sigma3)

plot(gbcd3,'contourf')
mtexTitle('GBCD for $\Sigma 3$')
mtexColorMap parula
annotate(symmetrise(Miller(1,1,1,cs3)),'label','$\{111\}$','backgroundColor','w')
mtexColorbar

%%
% Of the four $\{111\}$ variants only one is populated, namely the one that
% is the rotational axis of the $\Sigma 3$ misorientation. These twins are
% coherent, and the maximum coincides with that plane

[value,pos] = max(gbcd3);
[value, min(angle(pos,symmetrise(Miller(1,1,1,cs3))))./degree]

%#ok<*NOPTS>
