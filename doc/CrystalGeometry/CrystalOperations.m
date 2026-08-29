%% Operations on Crystal Directions and Planes
%
%%
% A <Miller.Miller.html |Miller|> represents either a direct-lattice vector
% $[uvw]$ or a reciprocal-lattice normal $(hkl)$ in a crystal frame. It
% supports ordinary vector geometry, but comparisons have one extra input:
% crystal symmetry.
%
% By default, |angle|, |dot| and |eq| compare a vector with the symmetry
% orbit of the other vector. In contrast, constructions such as |cross| act
% on the indexed vectors actually supplied. This page shows when to keep the
% default and when to request |'noSymmetry'|.
%
% Read <CrystalDirections.html Miller Indices> and <LatticeMetric.html
% Lattice Metric and Plane Geometry> first if direct and reciprocal indices
% are new. <CrystalSymmetries.html Crystal Symmetries> introduces the point
% groups used here, while <VectorsAxes.html Axes and Antipodal Symmetry>
% explains when opposite vectors represent the same axis.

plottingConvention.default('y↑→x');

%% A Kikuchi Pattern as a Geometric Map
%
% A simulated spherical Kikuchi pattern of quartz makes the operations
% visible. This is a master pattern on the sphere, not a raw planar detector
% image. The left plot shows the pattern, and the right plot shows its
% <S2FunHarmonic.radon.html spherical Radon transform>.
%
% A band centre is a great circle on the pattern. The transform maps that
% great circle to the point representing its plane normal.

data = load([mtexDataPath filesep 'quartzPattern.mat']);
pattern = data.pattern;

[~,ax1] = plot(pattern,'resolution',0.25*degree,'complete','upper',...
  'UVTW','noLabel');
mtexColorMap black2white
nextAxis
[~,ax2] = plot(pattern.radon,'resolution',0.25*degree,'complete','upper',...
  'hkil','noLabel');
mtexColorMap black2white

%%
% The brightest bands belong to three strongly reflecting quartz forms: the
% hexagonal prism and the positive and negative rhombohedra. Each form is
% introduced below by one plane normal.

% extract the crystal symmetry
cs = pattern.CS;

m = Miller(-1,0,1,0,cs,'hkil'); % hexagonal prism
r = Miller(0,-1,1,1,cs,'hkil'); % positive rhombohedron
z = Miller(0,1,-1,1,cs,'hkil'); % negative rhombohedron

%%
% Drawn in both plots, a plane is a great circle on the left and a point on
% the right. The matching colours identify the same plane in the two
% representations.

hold on
circle(m,'parent',ax1,'color','lightBlue')
circle(r,'parent',ax1,'color','red')
circle(z,'parent',ax1,'color','yellow')

opt = {'marker','s','MarkerFaceColor','none','parent',ax2,...
  'labeled','backgroundColor','w','linewidth',2};
plot(m,opt{:},'markerEdgeColor','lightBlue')
plot(r,opt{:},'markerEdgeColor','red')
plot(z,opt{:},'markerEdgeColor','yellow')

%% Symmetrically Equivalent Planes and Directions
%
% A *symmetry orbit* contains the vectors obtained by applying every
% operation of the crystal point group. Its members are symmetrically
% equivalent because the crystal cannot distinguish the corresponding
% settings.
%
% The family of directions equivalent to $[uvw]$ is written
% $\langle uvw\rangle$. The family of planes equivalent to $(hkl)$ is written
% $\{hkl\}$. <Miller.symmetrise.html |symmetrise|> lists the orbit as directed
% vectors.

symmetrise(r)

%%
% Quartz point group |321| has six operations, and none repeats this normal.
% The output therefore contains six directed normals. For this rhombohedron
% they form three opposite pairs.
%
% A geometric plane is unchanged when its normal is reversed. Thus the six
% directed normals describe three distinct plane axes. Adding the symmetry
% orbits to the plots accounts for the corresponding bands.

hold on
circle(m.symmetrise,'parent',ax1,'color','lightBlue')
circle(r.symmetrise,'parent',ax1,'color','red')
circle(z.symmetrise,'parent',ax1,'color','yellow')

plot(m,opt{:},'markerEdgeColor','lightBlue','symmetrised')
plot(r,opt{:},'markerEdgeColor','red','symmetrised')
plot(z,opt{:},'markerEdgeColor','yellow','symmetrised')

%%
% The option |'symmetrised'| on |plot| performs the same expansion. A plain
% |symmetrise| call keeps one entry per symmetry operation and may contain
% repeated vectors. Use |'unique'| when the number of distinct members is
% the question.

directedNormalCount = length(symmetrise(r,'unique','noAntipodal'))

%%
% The first count keeps opposite normals distinct. The |'antipodal'| option
% instead treats a vector and its negative as the same axis.

planeAxisCount = length(symmetrise(r,'unique','antipodal'))

%%
% The two outputs are 6 directed normals and 3 plane axes. Point-group
% equivalence and antipodal equivalence are separate choices; select the one
% that matches the physical object being described.

%% Multiplicity
%
% The <Miller.multiplicity.html |multiplicity|> is the number of distinct
% directed vectors in a symmetry orbit. It is the count returned by
% |symmetrise(...,'unique','noAntipodal')|. A direction on a symmetry axis
% has lower multiplicity because some operations leave it fixed.
%
% For diffraction with Friedel equivalence, opposite reflection normals
% contribute together. Using a Laue group includes that equivalence in the
% conventional multiplicity factor for a powder reflection.

csCubic = crystalSymmetry('m-3m');
hCubic = Miller({1,0,0},{1,1,0},{1,1,1},csCubic);

multiplicity(hCubic)

%%
% The cubic $\{100\}$, $\{110\}$ and $\{111\}$ forms have multiplicities 6,
% 12 and 8. The order of the indices does not determine this count; the
% stabilising symmetry of the direction does.

%% Are Two Normals Equivalent?
%
% The two objects below are opposite directed normals. The operator |==|
% asks whether point group |321| maps one normal onto the other.

r1 = Miller(1,1,-2,0,cs,'hkil');
r2 = Miller(-1,-1,2,0,cs,'hkil');

r1 == r2

%%
% The result is false because no operation of |321| makes that mapping.
% Treating the normals as axes makes their signs irrelevant.

eq(r1,r2,'antipodal')

%%
% The second result is true. This distinction matters whenever directed
% crystal vectors, plane axes and Friedel-equivalent reflections appear in
% the same calculation.

%% Does a Direction Lie in a Plane?
%
% A direction $[uvw]$ lies in a plane $(hkl)$ when their scalar product is
% zero. In three-index notation this is the *zone law*
%
% $$hu+kv+lw=0.$$
%
% Incidence concerns the two indices that were written. Use |'noSymmetry'|
% so that |dot| does not substitute a symmetry-equivalent vector.

csOrtho = crystalSymmetry('mmm',[4 5 6]);
plane = Miller(1,1,0,csOrtho,'hkl');
directionInPlane = Miller(1,-1,0,csOrtho,'uvw');

dot(plane,directionInPlane,'noSymmetry')

%%
% Zero confirms that $[1\bar{1}0]$ lies in $(110)$. In contrast, the result
% for $[100]$ is 1, so that direction does not lie in the plane.

dot(plane,Miller(1,0,0,csOrtho,'uvw'),'noSymmetry')

%%
% This Cartesian dot-product test also works with four-index trigonal and
% hexagonal notation. There is no need to translate the indices manually.

%% Zone Axes and Spanned Planes
%
% Two lattice planes intersect along a lattice direction called a *zone
% axis*. Its direction is the cross product of their reciprocal normals.

d1 = round(cross(m,r))

plot(d1,'marker','s','parent',ax1,'MarkerFaceColor','lightgreen',...
  'labeled','backgroundColor','w')
circle(d1,'parent',ax2,'linecolor','lightgreen')

%%
% The output uses |UVTW| because a cross product of two reciprocal normals is
% a direct-lattice direction. <Miller.round.html |round|> rescales it to
% small integer indices.
%
% The green square lies where the two corresponding bands cross in the
% pattern. In the Radon plot, its green great circle passes through their two
% normal points.

d2 = Miller(-2,0,1,cs,'uvw')

plot(d2,'marker','s','parent',ax1,'MarkerFaceColor','Orange',...
  'labeled','backgroundColor','w')
circle(d2,'parent',ax2,'linecolor','orange')

%%
% Conversely, two direct-lattice directions span a plane. Their cross
% product is displayed in reciprocal |hkil| notation.

n = round(cross(d1,d2))

circle(n,'parent',ax1,'linecolor','white')
plot(n,opt{:},'MarkerEdgeColor','white')

%%
% The white band contains |d1| and |d2| in the pattern. In the Radon plot,
% the white normal lies where the green and orange great circles intersect.

%% Symmetry-Reduced and Geometric Angles
%
% By default, <vector3d.angle.html |angle|> returns the smallest angle between
% the first vector and the symmetry orbit of the second. The result is
% independent of which equivalent index triplet was supplied.

symmetryAngle = angle(r1,r2) / degree

%%
% The point-group-reduced angle is $60^\circ$. If the normals represent plane
% axes, include antipodal equivalence as well.

axisAngle = angle(r1,r2,'antipodal') / degree

%%
% The result is numerically close to zero. To compare only the two Cartesian
% vectors as written, ignore crystal symmetry.

geometricAngle = angle(r1,r2,'noSymmetry') / degree

%%
% The geometric angle is $180^\circ$ because the normals are exactly
% opposite. Thus the same two index sets give a $60^\circ$ point-group angle,
% a near-zero plane-axis angle and a $180^\circ$ geometric angle.
%
% The option |'noSymmetry'| is available to many commands that accept crystal
% directions or orientations. Use it when the indexed vectors themselves,
% rather than their symmetry classes, are the subject.

%% From the Crystal Frame into the Specimen Frame
%
% An <OrientationDefinition.html orientation> states how a crystal is placed
% in the specimen. It maps a direction from the Cartesian crystal frame into
% the specimen frame.

ori = orientation.byEuler(10*degree,20*degree,30*degree,'Bunge',cs);

close all
plot(ori * pattern,'resolution',0.25*degree,'complete','upper')
mtexColorMap black2white

%%
% The whole pattern has moved rigidly with the crystal. Multiplying the zone
% axis by the same orientation returns a specimen direction rather than a
% |Miller| object.

specimenDirection = ori * d1

hold on
plot(specimenDirection,'marker','s','MarkerFaceColor','lightgreen',...
  'label',char(d1,'latex'),'backgroundColor','w')
hold off

%%
% Applying the orientation to the full symmetry orbit marks every specimen
% direction in which this crystal family points.

hold on
plot(ori*d1.symmetrise,'marker','s','MarkerFaceColor','lightgreen',...
  'label',char(d1,'latex'),'backgroundColor','w')
hold off

%%
% That set is the <OrientationPoleFigure.html pole figure> of this one
% orientation for the family represented by |d1|.

%% Cartesian Components Without Crystal Metadata
%
% Casting a |Miller| to <vector3d.vector3d.html |vector3d|> copies its
% Cartesian components but drops the crystal symmetry and crystal frame. The
% result is *frame-free*: it has an empty frame and resolves against the
% session default when it is rendered.

cartesianDirection = vector3d(d1)

%%
% The frame name shown in the display is therefore the current session
% default, not a frame stored by the vector. The empty stored frame confirms
% that distinction.

isFrameFree = isempty(cartesianDirection.frame)

%%
% The result is true. This cast is not a frame change; it removes the
% information needed to interpret the components as lattice indices. A true
% frame change re-expresses the same physical object in a named frame and
% leaves the object itself untouched.
%
% The ordinary spherical coordinates remain available. Called without
% output arguments, |polar| prints the polar angle from +Z and the azimuth
% from +X in degrees.

polar(d1)

%% References
%
% * The International Union of Crystallography,
% <https://dictionary.iucr.org/Zone_axis Zone axis>, defines the zone axis
% and the Weiss zone law used for the incidence test.
% * U. Shmueli,
% <https://doi.org/10.1107/97809553602060000549 Reciprocal space in
% crystallography>, _International Tables for Crystallography B_, ch. 1.1,
% 2006, develops the direct and reciprocal geometry behind these operations.
% * A. Looijenga-Vos and M. J. Buerger,
% <https://doi.org/10.1107/97809553602060000506 Space-group determination and
% diffraction symbols>, _International Tables for Crystallography A_, ch.
% 3.1, 2006, explains Friedel equivalence and Laue symmetry in diffraction.
% * N. C. Krieger Lassen, D. Juul Jensen and K. Conradsen,
% <https://digitalcommons.usu.edu/microscopy/vol6/iss1/7/ Image Processing
% Procedures for Analysis of Electron Back Scattering Patterns>, _Scanning
% Microscopy_ 6, article 7, 1992, introduces transform-based localisation of
% Kikuchi bands for automated indexing.
% * A. Morawiec,
% <https://doi.org/10.1007/978-3-662-09156-2 Orientations and Rotations:
% Computations in Crystallographic Textures>, Springer, 2004, develops
% symmetry orbits and symmetry-reduced angles for texture analysis.

%% Next
%
% Continue in chapter order with <CrystalReferenceSystem.html Reference
% System>, which explains how the lattice basis is embedded in the Cartesian
% crystal frame. <FundamentalSector.html Fundamental Sector> later selects one
% representative from each symmetry-equivalent direction family.
%
% Continue with <OrientationDefinition.html Defining Orientations> to place a
% crystal in a specimen. <OrientationPoleFigure.html Pole Figures> then plots
% where selected crystal directions point in that specimen.

%#ok<*ASGLU>
%#ok<*VUNUS>
%#ok<*POLAR>
%#ok<*EQEFF>
