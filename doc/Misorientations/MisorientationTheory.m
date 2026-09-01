%% Theory of Misorientations
%
%%
% An <OrientationDefinition.html orientation> says how one crystal sits in
% the specimen. A *misorientation* says how two crystals sit relative to each
% other. It is a coordinate transform from one crystal frame into the other,
% so the specimen frame drops out.
%
% Misorientations describe grain boundaries, twins, phase transformations,
% and orientation gradients inside a deformed grain. The two crystals may
% belong to the same phase or to different phases.
%
% This page assumes that orientations map crystal coordinates to specimen
% coordinates. Review <DefinitionAsCoordinateTransform.html Orientations as
% Coordinate Transforms> if the order of composed transforms is unfamiliar.

plottingConvention.default('y↑→x');

%% Two Grains to Work With
%
% The example is an EBSD map of magnesium containing extension twins. The
% map first has to be divided into <GrainReconstruction.html grains>.

mtexdata twins silent

% use only proper symmetry operations, which are rotations
ebsd('M').CS = ebsd('M').CS.properGroup;

% compute and smooth the grains
grains = calcGrains(ebsd,'threshold',5*degree,'minPixel',5);
grains = smoothBoundary(grains,5);
CS = grains.CS;

%%
% The two labelled grains share the white boundary. Their adjacency makes
% the relative orientation a grain-boundary misorientation.

plot(grains,grains.meanOrientation,'ipfDirection',zvector,'micronbar','off')

hold on
plot(grains([57,58]).boundary,'edgecolor','w','linewidth',2)
hold off

text(grains([57,58]),{'1','2'})

%%
% Their mean orientations are the two inputs used below.

ori1 = grains(57).meanOrientation;
ori2 = grains(58).meanOrientation;

%% Misorientation Angle and Disorientation
%
% The smallest rotation angle separating the two crystal orientations is

disorientationAngle = angle(ori1,ori2) ./ degree

%%
% A crystal orientation has many symmetrically equivalent descriptions.
% MTEX compares all proper-symmetry pairs and returns the smallest angle.
% This minimum is the *disorientation angle*.

ori2Equivalent = ori2.symmetrise('proper');
symmetryAwareRange = [min(angle(ori1,ori2Equivalent)),...
  max(angle(ori1,ori2Equivalent))] ./ degree

%%
% Every symmetry-aware comparison therefore returns the same value. If
% symmetry is ignored, the same representatives span many rotation angles.

rawAngleRange = [min(angle(ori1,ori2Equivalent,'noSymmetry')),...
  max(angle(ori1,ori2Equivalent,'noSymmetry'))] ./ degree

%% The Directed Misorientation
%
% A full misorientation contains an axis as well as an angle, and it has a
% direction. Since |ori1| and |ori2| both map crystal coordinates to specimen
% coordinates, the product below maps coordinates of grain 2 into grain 1.

mori = inv(ori1) * ori2

%%
% The displayed object is one representative of all equivalent rotations.
% Its raw angle is not necessarily the disorientation angle.

rawRepresentativeAngle = angle(mori,'noSymmetry') ./ degree

%%
% <orientation.project2FundamentalRegion.html
% |project2FundamentalRegion|> chooses the representative in the
% fundamental region, where each physical relationship appears once.

disori = project2FundamentalRegion(mori);
fundamentalRegionAngle = angle(disori,'noSymmetry') ./ degree

%%
% The raw representative is about $107.9^\circ$, whereas the representative
% in the fundamental region has the $85.7^\circ$ disorientation angle.
%
% Applying |mori| to a plane normal expressed in grain 2 returns that normal
% expressed in grain 1. Here $\{11\bar20\}$ of grain 2 is parallel to
% $\{2\bar1\bar10\}$ of grain 1.

round(mori * Miller(1,1,-2,0,CS))

%%
% The inverse misorientation maps from grain 1 back into grain 2.

round(inv(mori) * Miller(2,-1,-1,0,CS))

%% Coincident Lattice Planes
%
% The relationship lies near several coincidences between major lattice
% planes. The large markers are planes of grain 2 mapped into grain 1. The
% small labelled markers are planes already expressed in grain 1.

m = Miller({1,-1,0,0},{1,1,-2,0},{-1,0,1,1},{0,0,0,1},CS);

% plot the major planes of grain 2 in the frame of grain 1
close all
for im = 1:length(m)
  plot(mori * m(im).symmetrise,'MarkerSize',10,...
    'DisplayName',char(m(im),'LaTex'),'noLabel',...
    'upper','textBelowMarker')
  hold on
end
hold off

% label the corresponding planes of grain 1
mm = round(unique(mori*m.symmetrise,'noSymmetry'),'maxHKL',6);
annotate(mm,'labeled','MarkerSize',5,'textBelowMarker')

legend({},'location','southoutside','FontSize',13,'Interpreter','latex','numColumns',4);

%%
% Two pairs lie almost on top of each other: $\{11\bar20\}$ on
% $\{11\bar20\}$ and $\{\bar1011\}$ on $\{\bar1011\}$. Their angular
% separations are about half a degree and a fifth of a degree.

nearCoincidenceError = [...
  angle(mori*Miller(1,1,-2,0,CS),Miller(1,1,-2,0,CS));...
  angle(mori*Miller(-1,0,1,1,CS),Miller(-1,0,1,1,CS))] ./ degree

%%
% Two further pairs are close without coinciding. The prism plane
% $\{1\bar100\}$ maps near the basal plane $(0001)$, and the basal plane
% maps near the prism plane. Both separations are about $4.3^\circ$.

crossPlaneError = [...
  angle(mori*Miller(1,-1,0,0,CS),Miller(0,0,0,1,CS));...
  angle(mori*Miller(0,0,0,1,CS),Miller(1,-1,0,0,CS))] ./ degree

%% A Useful 90 Degree Approximation
%
% The exact relationship that forces the first two chosen correspondences
% is the transform taking $\{11\bar20\}$ to $\{2\bar1\bar10\}$ and
% $[0001]$ to $[01\bar10]$.

coincidenceMori = orientation.map(...
  Miller(1,1,-2,0,CS),Miller(2,-1,-1,0,CS),...
  Miller(0,0,0,1,CS,'uvw'),Miller(0,1,-1,0,CS,'uvw'))

%%
% It is a rotation by exactly $90^\circ$ about a prism axis.

round(coincidenceMori.axis)

%%

coincidenceAngle = coincidenceMori.angle ./ degree

%%
% In the corresponding plot, the pairs forced by the construction now
% coincide exactly. This is a useful geometric approximation, but it is not
% the ideal magnesium extension-twin relationship.

% plot the approximation in place of the measured misorientation
close all
for im = 1:length(m)
  plot(coincidenceMori * m(im).symmetrise,'MarkerSize',10,...
    'DisplayName',char(m(im),'LaTex'),'noLabel','upper')
  hold on
end
hold off

% label the corresponding planes in the other crystal
mm = round(unique(coincidenceMori*m.symmetrise,'noSymmetry'),'maxHKL',6);
annotate(mm,'labeled','MarkerSize',5)

legend({},'location','southoutside','FontSize',13,'Interpreter','latex','numColumns',4);

%% The Magnesium Extension Twin
%
% The physical twin relationship is defined by a twin plane and an in-plane
% direction. Its disorientation is $86.3^\circ$ about a prism axis.

twinning = orientation.map(...
  Miller(1,-1,0,1,CS),Miller(1,0,-1,-1,CS),...
  Miller(0,1,-1,1,CS,'uvw'),Miller(1,-1,0,1,CS,'uvw'))

%%

twinAxis = round(twinning.axis)

%%

twinAngle = twinning.angle ./ degree

%%
% A textbook may instead describe this twin as a $180^\circ$ rotation about
% the twin axis. That is a symmetrically equivalent representative of the
% same misorientation, obtained by asking for the largest rotation angle.

twinMaximumAngle = angle(twinning,'max') ./ degree

%%
% The measured grain pair is $0.7^\circ$ from the ideal twin. The 90 degree
% coincidence approximation is $3.7^\circ$ from it.

twinDeviation = [angle(mori,twinning),...
  angle(coincidenceMori,twinning)] ./ degree

%% Finding the Twin Boundaries
%
% A boundary close to the ideal relationship is a candidate twin boundary.
% The threshold is an analyst choice and compares the complete
% misorientation, including its axis, rather than the angle alone.

% select only magnesium to magnesium grain boundaries
gB = grains.boundary('Magnesium','Magnesium');

% test the complete misorientation against the ideal twin
isTwinning = angle(gB.misorientation,twinning) < 5*degree;

% plot the grains and highlight candidate twin boundaries
plot(grains,grains.meanOrientation,'ipfDirection',zvector,'micronbar','off')
hold on
plot(gB(isTwinning),'edgecolor','w','linewidth',2)
hold off

%%
% The white traces follow the thin lamellae visible in the orientation map.
% This spatial agreement supports the crystallographic classification, but
% a threshold match alone does not prove the deformation mechanism.
% <TwinningBoundaries.html Twinning Analysis> shows how to infer the ideal
% relationship from a boundary population instead of assuming it.
%
% Segment counts depend on how a boundary was sampled, so the fraction is
% weighted by trace length. Candidate twins make up about half the boundary
% length in this map.

twinLengthFraction = sum(gB(isTwinning).segLength) ./ sum(gB.segLength)

%% Reading a Population of Misorientations
%
% The misorientations of all boundary segments can be reduced to an angle
% distribution. The sharp peak just below $90^\circ$ is the twin population
% found above.

close all
plotAngleDistribution(gB.misorientation,'figSize','small')

%%
% This boundary distribution is correlated because only neighbouring grains
% are paired. <AngleDistributionFunction.html Angle Distribution> compares
% it with the uncorrelated distribution from the texture and with the
% distribution expected for uniformly random orientations.
%
% The same population can instead be reduced to its axes.

plotAxisDistribution(gB.misorientation,'contourf')

%%
% The axes concentrate on $\left<\bar12\bar10\right>$, the prism-axis family
% of the ideal twin. These axes are expressed in crystal coordinates;
% <AxisDistributionFunction.html Axis Distribution> also explains axes in
% specimen coordinates and the random reference distribution.

%% Misorientations Between Two Phases
%
% A phase transformation relates crystals with different symmetries. The
% first symmetry of the misorientation belongs to the parent phase and the
% second belongs to the child phase.

CS_Mag = loadCIF('Magnetite');
CS_Hem = loadCIF('Hematite');

%%
% A reported magnetite-to-hematite relationship has
% $\{111\}_{m} \parallel \{0001\}_{h}$ and
% $\{\bar101\}_{m} \parallel \{10\bar10\}_{h}$. These two parallelisms are
% exactly the input expected by <orientation.map.html |orientation.map|>.

Mag2Hem = orientation.map(...
  Miller(1,1,1,CS_Mag),Miller(0,0,0,1,CS_Hem),...
  Miller(-1,0,1,CS_Mag),Miller(1,0,-1,0,CS_Hem))

%%
% Consider one magnetite parent orientation.

ori_Mag = orientation.byEuler(0,0,0,CS_Mag);

%%
% Applying every symmetrically equivalent parent description creates 48
% child descriptions, but only 8 child orientations are distinct. The
% duplicates come from symmetry operations that leave the $\{111\}$ axis in
% place and therefore do not create a new child orientation.

allChildDescriptions = symmetrise(ori_Mag) * inv(Mag2Hem);
variantCounts = [length(allChildDescriptions),...
  length(unique(allChildDescriptions))]

%%
% A *variant* is one crystallographically equivalent child orientation
% predicted from a single parent orientation through a known orientation
% relationship. <orientation.variants.html |variants|> removes duplicate
% descriptions directly.

childVariants = variants(Mag2Hem,ori_Mag)

%%
% The pole figure contains eight discrete child orientations rather than one.
% A transformed parent grain may therefore contain several child
% orientations related by the same parent-to-child relationship.

plotPDF(childVariants,...
  Miller({1,0,-1,0},{1,1,-2,0},{0,0,0,1},CS_Hem))

%% The Maths Behind the Transform
%
% Let $\mathbf{G}_1$ and $\mathbf{G}_2$ be the matrices of |ori1| and |ori2|.
% A direction with crystal-2 components $\mathbf{h}_2$ has specimen
% components $\mathbf{r}=\mathbf{G}_2\mathbf{h}_2$. Its components in the
% frame of crystal 1 are therefore
%
% $$ \mathbf{h}_1 = \mathbf{G}_1^{-1}\mathbf{r}
%    = \mathbf{G}_1^{-1}\mathbf{G}_2\mathbf{h}_2. $$
%
% This is why |inv(ori1) * ori2| maps crystal 2 into crystal 1. Reversing the
% order gives the inverse map.
%
% Proper symmetry operations may multiply this transform from both sides
% without changing the physical crystal relationship. The fundamental
% region retains one representative from that equivalent set. For a
% same-phase grain boundary, swapping the two grains also replaces the
% transform by its inverse; <MisorientationGrainExchangeSym.html grain
% exchange symmetry> develops that additional equivalence.

%% References
%
% * A. Morawiec, <https://doi.org/10.1007/978-3-662-09156-2 Orientations
% and Rotations: Computations in Crystallographic Textures>, Springer, 2004,
% develops rotation space, symmetry, and misorientation angle and axis
% distributions.
% * J.K. Mackenzie, <https://doi.org/10.1093/biomet/45.1-2.229 Second paper
% on statistics associated with the random disorientation of cubes>,
% _Biometrika_ 45 (1958), 229-240, derives the cubic random-disorientation
% angle distribution.
% * J.W. Christian and S. Mahajan,
% <https://doi.org/10.1016/0079-6425(94)00007-7 Deformation twinning>,
% _Progress in Materials Science_ 39 (1995), 1-157, reviews twin modes and
% their crystallography.
% * L.A. Bursill and R.L. Withers,
% <https://doi.org/10.1107/S0021889879012486 On the multiple orientation
% relationships between hematite and magnetite>, _Journal of Applied
% Crystallography_ 12 (1979), 287-294, reports the iron-oxide orientation
% relationships used above.
% * <https://www.iso.org/standard/82749.html ISO 24173:2024>, _Microbeam
% analysis -- Guidelines for orientation measurement using electron
% backscatter diffraction_, gives guidance for reproducible EBSD orientation
% measurements.

%% Next
%
% The next page explains <MisorientationGrainExchangeSym.html Grain Exchange
% Symmetry>. A whole distribution of misorientations, represented as a
% density rather than a list, is the
% <MisorientationDistributionFunction.html Misorientation Distribution
% Function>. Applying a parent-to-child relationship throughout a map leads
% to <MaParentGrainReconstruction.html Parent Grain Reconstruction>.

%#ok<*MINV>
%#ok<*NOPTS>
