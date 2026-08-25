%% Operations on Crystal Directions
%
%%
% Crystal directions support the same calculations as specimen directions
% - angles, cross products and means - with one addition that can change the
% answer: crystal symmetry. A |Miller| object denotes one indexed vector.
% Symmetry-aware comparisons such as |angle|, |dot| and |eq| search its
% equivalent vectors by default; constructions and geometric operations such
% as |cross| act on the vectors actually supplied.

plottingConvention.default('y↑→x');

%% A Kikuchi Pattern to Read Them In
%
% A simulated Kikuchi pattern of quartz makes the geometry visible. The left
% plot is the pattern itself, the right one its
% <S2FunHarmonic.radon.html Radon transform>, in which every band of the
% pattern becomes a spot.

data = load([mtexDataPath filesep 'quartzPattern.mat']);
pattern = data.pattern;

[~,ax1] = plot(pattern,'resolution',0.25*degree,'complete','upper',"UVTW",'noLabel');
mtexColorMap black2white
nextAxis
[~,ax2] = plot(pattern.radon,'resolution',0.25*degree,'complete','upper','hkil','noLabel');
mtexColorMap black2white

%%
% The brightest bands belong to the most reflective lattice planes of
% quartz: the hexagonal prism and the two rhombohedra.

% extract the crystal symmetry
cs = pattern.CS;

m = Miller(-1,0,1,0,cs,'hkil'); % hexagonal prism
r = Miller(0,-1,1,1,cs,'hkil'); % positive rhombohedron
z = Miller(0,1,-1,1,cs,'hkil'); % negative rhombohedron

%%
% Drawn into both plots, a plane is a great circle on the left - the band it
% produces - and a single point on the right.

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
% Only three planes are marked, but the pattern clearly has more bands of
% each kind. The missing ones are the symmetrically equivalent planes -
% those the symmetry operations of the crystal map the marked one onto. The
% class of all directions equivalent to $[uvw]$ is written
% $\langle uvw\rangle$, the
% class of all planes equivalent to $(hkl)$ is written $\{hkl\}$, and
% <Miller.symmetrise.html |symmetrise|> lists them.

symmetrise(r)

%%
% The output contains six directed plane normals, one for each operation of
% quartz point group 321. For this rhombohedral form they make three opposite
% pairs, because a plane and the negative of its normal describe the same
% unoriented plane. Adding the families to both plots covers the remaining
% bands.

hold on
circle(m.symmetrise,'parent',ax1,'color','lightBlue')
circle(r.symmetrise,'parent',ax1,'color','red')
circle(z.symmetrise,'parent',ax1,'color','yellow')

plot(m,opt{:},'markerEdgeColor','lightBlue','symmetrised')
plot(r,opt{:},'markerEdgeColor','red','symmetrised')
plot(z,opt{:},'markerEdgeColor','yellow','symmetrised')

%%
% The option |'symmetrised'| on |plot| does the same in one step. A plain
% |symmetrise| call returns operation-level entries and may contain repeated
% vectors or opposite normals. Use |'unique'| when a count is meant. Keeping
% the signs gives six directed normals here; treating them as
% <VectorsAxes.html axes> gives three distinct plane axes.

directedNormalCount = length(symmetrise(r,'unique','noAntipodal'))

%%

planeAxisCount = length(symmetrise(r,'unique','antipodal'))

%% Multiplicity
%
% The <Miller.multiplicity.html |multiplicity|> is the number of distinct
% directed vectors in a symmetry orbit. It is the size returned by
% |symmetrise(...,'unique','noAntipodal')|. For a Laue group, or when
% Friedel equivalence is assumed, this is the conventional multiplicity
% factor for equivalent reflections contributing to a powder peak.

csCubic = crystalSymmetry('m-3m');
hCubic = Miller({1,0,0},{1,1,0},{1,1,1},csCubic);

multiplicity(hCubic)

%%
% The cubic $\{100\}$, $\{110\}$ and $\{111\}$ forms have multiplicities
% 6, 12 and 8. A low-index direction is not necessarily the most numerous;
% multiplicity is set by how much symmetry leaves that direction fixed.

%% Are Two Directions the Same?
%
% Under symmetry the question has two answers. Here the two objects are
% opposite plane normals, and |==| asks whether the point group maps one
% directed normal onto the other.

r1 = Miller(1,1,-2,0,cs,'hkil');
r2 = Miller(-1,-1,2,0,cs,'hkil');

r1 == r2

%%
% Not equivalent - no operation of 321 maps one onto the other. As axes they
% are, because then the sign no longer matters.

eq(r1,r2,'antipodal')

%% Does a Direction Lie in a Plane?
%
% A direction $[uvw]$ lies in a plane $(hkl)$ when their scalar product is
% zero. In three-index notation this is the *zone law*
%
% $$hu+kv+lw=0.$$
%
% Use |'noSymmetry'| for this test: incidence concerns the two indices that
% were written, not the closest pair from their symmetry families.

csOrtho = crystalSymmetry('mmm',[4 5 6]);
plane = Miller(1,1,0,csOrtho);
directionInPlane = Miller(1,-1,0,csOrtho,'uvw');

dot(plane,directionInPlane,'noSymmetry')

%%
% Zero confirms that $[1\bar{1}0]$ lies in $(110)$. In contrast, $[100]$
% does not.

dot(plane,Miller(1,0,0,csOrtho,'uvw'),'noSymmetry')

%%
% The Cartesian dot-product test also works with four-index trigonal and
% hexagonal notation, without manually translating the zone law.

%% Zone Axes
%
% Two lattice planes intersect in a lattice direction, the *zone axis*,
% which is the cross product of their normals.

d1 = round(cross(m,r))

plot(d1,'marker','s','parent',ax1,'MarkerFaceColor','lightgreen','labeled','backgroundColor','w')
circle(d1,'parent',ax2,'linecolor','lightgreen')

%%
% MTEX switched from |hkil| to |UVTW| in the display, because the cross
% product of two plane normals is a direction and not a normal.
% <Miller.round.html |round|> is what turns the result into small integer
% indices. In the pattern the zone axis sits where the two bands cross; in
% the Radon plot it is the great circle through the two spots.
%
% Taking a second direction,

d2 = Miller(-2,0,1,cs,'uvw')

plot(d2,'marker','s','parent',ax1,'MarkerFaceColor','Orange','labeled','backgroundColor','w')
circle(d2,'parent',ax2,'linecolor','orange')

%%
% the same cross product gives the plane the two directions span.

n = round(cross(d1,d2))

circle(n,'parent',ax1,'linecolor','white')
plot(n,opt{:},'MarkerEdgeColor','white')

%%
% The white band connects |d1| and |d2| in the pattern, and in the Radon
% plot the white spot is where the two great circles of |d1| and |d2| meet.

%% Angles
%
% The angle between two crystal directions is the smallest angle between the
% first and *any* direction equivalent to the second - anything else would
% depend on which of the equivalent descriptions happened to be written
% down.

symmetryAngle = angle(r1,r2) / degree

%%
% Read as axes, the two are the same direction, and the angle is zero up to
% rounding.

axisAngle = angle(r1,r2,'antipodal') / degree

%%
% The plain geometric angle, symmetry ignored, is what |'noSymmetry'|
% returns - the two vectors do point exactly opposite ways.

geometricAngle = angle(r1,r2,'noSymmetry') / degree

%%
% $60^\circ$, $0^\circ$ and $180^\circ$ for one and the same pair of index
% triples. |'noSymmetry'| is available for most commands that take crystal
% directions or orientations, and it is the option to reach for when a
% number looks smaller than it should.

%% From the Crystal into the Specimen
%
% An <OrientationDefinition.html orientation> says how the lattice sits in
% the specimen, so it converts a crystal direction into a specimen
% direction.

ori = orientation.byEuler(10*degree,20*degree,30*degree,'Bunge',cs)

close all
plot(ori * pattern,'resolution',0.25*degree,'complete','upper')
mtexColorMap black2white

%%
% The pattern above is the same one as before, turned by |ori|. The zone
% axis moves with it.

ori * d1

hold on
plot(ori*d1,'marker','s','MarkerFaceColor','lightgreen','label',char(d1,'latex'),'backgroundColor','w')
hold off

%%
% Applying the orientation to all equivalent directions instead marks every
% place in the specimen where that crystal direction points.

hold on
plot(ori*d1.symmetrise,'marker','s','MarkerFaceColor','lightgreen','label',char(d1,'latex'),'backgroundColor','w')
hold off

%%
% That set of points is precisely a pole figure of the orientation, see
% <OrientationPoleFigure.html Pole Figures>.

%% Dropping the Crystal Frame
%
% A |Miller| is a <vector3d.vector3d.html |@vector3d|> underneath, and the
% conversion returns the same direction without the lattice attached, in
% Cartesian coordinates.

vector3d(d1)

%%
% From there the spherical angles are available as usual.

[theta,rho] = polar(d1)

%% Next
%
% The patch of the sphere that holds exactly one of each set of equivalent
% directions is the <FundamentalSector.html Fundamental Sector>. Physical
% lengths and plane spacings are <LatticeMetric.html Lattice Metric and
% Plane Geometry>. How the crystal axes relate to the Cartesian frame the
% numbers above are given in is
% <CrystalReferenceSystem.html Reference System>.

%#ok<*ASGLU>
%#ok<*VUNUS>
%#ok<*POLAR>
