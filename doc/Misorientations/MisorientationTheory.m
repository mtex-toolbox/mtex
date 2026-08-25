%% Theory of Misorientations
%
%%
% An <OrientationDefinition.html orientation> says how one crystal sits in
% the specimen. A *misorientation* says how two crystals sit with respect to
% each other, and it is what the specimen frame drops out of: it is the
% coordinate transform from the frame of one crystal into the frame of the
% other.
%
% This is the quantity behind grain boundaries, twinning, phase
% transformations and the orientation gradients inside a deformed grain. The
% two crystals may be of the same phase or of different ones.

plottingConvention.default('y↑→x');

%% Two Grains to Work With
%
% A magnesium data set, segmented into grains.

mtexdata twins silent

% use only proper symmetry operations
ebsd('M').CS = ebsd('M').CS.properGroup;

% compute grains
grains = calcGrains(ebsd,'threshold',5*degree,'minPixel',5);
grains = smoothBoundary(grains,5);
CS = grains.CS; % extract crystal symmetry

%%
% Two neighbouring grains are marked 1 and 2, with the boundary between them
% drawn white.

plot(grains,grains.meanOrientation,'micronbar','off')

hold on
plot(grains([57,58]).boundary,'edgecolor','w','linewidth',2)
hold off

text(grains([57,58]),{'1','2'})

%%
% Their mean orientations:

ori1 = grains(57).meanOrientation;
ori2 = grains(58).meanOrientation;

%% The Misorientation Angle
%
% How far apart the two orientations are is one number.

angle(ori1, ori2) ./ degree

%%
% It is computed modulo crystal symmetry - the smallest angle over all
% symmetrically equivalent pairs - so replacing one orientation by any of
% its equivalents cannot change it.

max(angle(ori1, ori2.symmetrise)) ./ degree

%%
% Without symmetry the equivalents give many different angles, of which the
% one above is the smallest.

min(angle(ori1, ori2.symmetrise,'noSymmetry')) ./ degree

%% The Misorientation Itself
%
% Both |ori1| and |ori2| map crystal coordinates to specimen coordinates.
% Composing the inverse of the first with the second therefore maps crystal
% coordinates of grain 1 to crystal coordinates of grain 2 - the specimen
% frame cancels. That composition is the misorientation.

mori = inv(ori1) * ori2

%%
% So the plane of grain 2 that lies parallel to $\{11\bar20\}$ of grain 1 is

round(mori * Miller(1,1,-2,0,CS))

%%
% and the inverse misorientation goes the other way.

round(inv(mori) * Miller(2,-1,-1,0,CS))

%% Coincident Lattice Planes
%
% That two major lattice planes come out parallel is a hint that this is a
% twinning misorientation. Plotting the major planes of grain 1, mapped into
% the frame of grain 2, against the planes of grain 2 shows how many such
% coincidences there are.

m = Miller({1,-1,0,0},{1,1,-2,0},{-1,0,1,1},{0,0,0,1},CS);

% cycle through all major lattice planes
close all
for im = 1:length(m)
  % plot the lattice planes of grain 1 with respect to the
  % reference frame of grain 2
  plot(mori * m(im).symmetrise,'MarkerSize',10,...
    'DisplayName',char(m(im),'LaTex'),'figSize','large','noLabel','upper','textBelowMarker')
  hold on
end
hold off

% mark the corresponding lattice planes in the twin
mm = round(unique(mori*m.symmetrise,'noSymmetry'),'maxHKL',6);
annotate(mm,'labeled','MarkerSize',5,'figSize','large','textBelowMarker')

% show legend
legend({},'location','NorthEast','FontSize',13,'Interpreter','latex');

%%
% Two pairs sit almost exactly on top of each other, $\{11\bar20\}$ on
% $\{11\bar20\}$ and $\{\bar1011\}$ on $\{\bar1011\}$ - half a degree
% and a fifth of a degree apart.

angle(mori * Miller(1,1,-2,0,CS),Miller(1,1,-2,0,CS)) / degree

%%

angle(mori * Miller(-1,0,1,1,CS),Miller(-1,0,1,1,CS)) / degree

%%
% Two further pairs are close without being exact: the prism plane
% $\{1\bar100\}$ falls onto the basal plane $(0001)$, and the basal plane
% onto the prism plane.

angle(mori * Miller(1,-1,0,0,CS),Miller(0,0,0,1,CS)) / degree

%%

angle(mori * Miller(0,0,0,1,CS),Miller(1,-1,0,0,CS)) / degree

%%
% Both about $4.3^\circ$. A measured misorientation is never exactly the
% ideal one; the question is how far off it is.

%% The Ideal Twinning Misorientation
%
% The ideal relationship is the one that makes those coincidences exact -
% the misorientation taking $\{11\bar20\}$ to $\{2\bar1\bar10\}$ and the
% direction $[0001]$ to $[01\bar10]$.

mori = orientation.map(Miller(1,1,-2,0,CS),Miller(2,-1,-1,0,CS),...
  Miller(0,0,0,1,CS,'uvw'),Miller(0,1,-1,0,CS,'uvw'))

%%
% It is a rotation by exactly $90^\circ$ about a prism axis.

round(mori.axis)

%%

mori.angle / degree

%%
% The same plot with the ideal misorientation: now the pairs coincide.

% cycle through all major lattice planes
close all
for im = 1:length(m)
  % plot the lattice planes of grain 1 with respect to the
  % reference frame of grain 2
  plot(mori * m(im).symmetrise,'MarkerSize',10,...
    'DisplayName',char(m(im),'Latex'),'figSize','large','noLabel','upper')
  hold on
end
hold off

% mark the corresponding lattice planes in the twin
mm = round(unique(mori*m.symmetrise,'noSymmetry'),'maxHKL',6);
annotate(mm,'labeled','MarkerSize',5,'figSize','large')

% show legend
legend({},'location','NorthWest','FontSize',13,'Interpreter','LaTex');

%% Finding the Twin Boundaries
%
% Any boundary whose misorientation is close to this ideal one is a twin
% boundary, and "close" is a threshold the analyst chooses.

% consider only Magnesium to Magnesium grain boundaries
gB = grains.boundary('Mag','Mag');

% check for small deviation from the twinning misorientation
isTwinning = angle(gB.misorientation,mori) < 7.5*degree;

% plot the grains and highlight the twinning boundaries
plot(grains,grains.meanOrientation,'micronbar','off')
hold on
plot(gB(isTwinning),'edgecolor','w','linewidth',2)
hold off

%%
% Half the boundary length in this map is twin boundary.

sum(gB(isTwinning).segLength) ./ sum(gB.segLength)

%% Reading a Whole Population of Misorientations
%
% Rather than testing one relationship at a time, the misorientations of all
% boundaries are summarised by their angle distribution.

close all
plotAngleDistribution(gB.misorientation)

%%
% The peak just below $90^\circ$ is the twinning relationship found above.
% What the distribution would look like for randomly oriented grains, and
% how to read a deviation from it, is
% <AngleDistributionFunction.html Angle Distribution>.
%
% The same for the misorientation axes:

plotAxisDistribution(gB.misorientation,'contour')

%%
% The axes concentrate on $\left<\bar12\bar10\right>$, the prism axis the
% ideal twinning rotation turns about, see
% <AxisDistributionFunction.html Axis Distribution>.

%% Misorientations Between Two Phases
%
% Nothing above required the two crystals to be of the same phase. A phase
% transformation is a misorientation between different symmetries.

CS_Mag = loadCIF('Magnetite')

%%

CS_Hem = loadCIF('Hematite')

%%
% The transition from magnetite to hematite is reported in the literature as
% $\{111\}_m$ parallel to $\{0001\}_h$ and $\{\bar101\}_m$ parallel to
% $\{10\bar10\}_h$, which is exactly what
% <orientation.map.html |orientation.map|> takes.

Mag2Hem = orientation.map(...
  Miller(1,1,1,CS_Mag),Miller(0,0,0,1,CS_Hem),...
  Miller(-1,0,1,CS_Mag),Miller(1,0,-1,0,CS_Hem))

%%
% A magnetite grain in some orientation

ori_Mag = orientation.byEuler(0,0,0,CS_Mag)

%%
% may transform into any of the hematite orientations this relationship
% allows - one per symmetrically equivalent setting of the parent. These are
% the *variants* of the transformation.

symmetrise(ori_Mag) * inv(Mag2Hem)

%%
% The list has 48 entries, one per symmetry element of magnetite, but only 8
% of them are distinct: the relationship is symmetric under the operations
% that leave the $\{111\}$ axis in place.

length(unique(symmetrise(ori_Mag) * inv(Mag2Hem)))

%%
% In a pole figure the variants appear as a set of discrete orientations
% rather than a single one, which is why a transformed grain shows several
% child orientations at once.

plotPDF(symmetrise(ori_Mag) * inv(Mag2Hem),...
  Miller({1,0,-1,0},{1,1,-2,0},{0,0,0,1},CS_Hem))

%% Next
%
% A whole distribution of misorientations, as a density rather than a list,
% is the <MisorientationDistributionFunction.html Misorientation
% Distribution Function>. Recovering parent grains from the child
% orientations above is
% <MaParentGrainReconstruction.html Parent Grain Reconstruction>.

%#ok<*MINV>
%#ok<*NOPTS>
