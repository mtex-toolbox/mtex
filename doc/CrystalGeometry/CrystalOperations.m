%% Operations on Crystal Directions
%
%%
% Crystal directions are calculated with exactly as specimen directions are
% - angles, cross products, means - with one difference that changes every
% answer: crystal symmetry. A direction stands for all the directions
% symmetry cannot distinguish it from, and MTEX takes that into account
% unless told not to.

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
r = Miller(0,-1,1,1,cs,'hkil'); % positive rhomboedron
z = Miller(0,1,-1,1,cs,'hkil'); % negative rhomboedron

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
% class of all directions equivalent to $[uvw]$ is written $<uvw>$, the
% class of all planes equivalent to $(hkl)$ is written $\{hkl\}$, and
% <Miller.symmetrise.html |symmetrise|> lists them.

symmetrise(r)

%%
% Six planes for quartz, whose point group 321 has six operations. Adding
% them to both plots covers the remaining bands.

hold on
circle(m.symmetrise,'parent',ax1,'color','lightBlue')
circle(r.symmetrise,'parent',ax1,'color','red')
circle(z.symmetrise,'parent',ax1,'color','yellow')

plot(m,opt{:},'markerEdgeColor','lightBlue','symmetrised')
plot(r,opt{:},'markerEdgeColor','red','symmetrised')
plot(z,opt{:},'markerEdgeColor','yellow','symmetrised')

%%
% The option |'symmetrised'| on |plot| does the same in one step. Treating
% the planes as <VectorsAxes.html axes> doubles the count, since 321
% contains no inversion and each plane normal then stands for its opposite
% as well.

length(symmetrise(r,'antipodal'))

%% Are Two Directions the Same?
%
% Under symmetry the question has two answers, and |==| gives the one that
% respects the crystal.

Miller(1,1,-2,0,cs) == Miller(-1,-1,2,0,cs)

%%
% Not equivalent - no operation of 321 maps one onto the other. As axes they
% are, because then the sign no longer matters.

eq(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs),'antipodal')

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

angle(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs)) / degree

%%
% Read as axes, the two are the same direction, and the angle is zero up to
% rounding.

angle(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs),'antipodal') / degree

%%
% The plain geometric angle, symmetry ignored, is what |'noSymmetry'|
% returns - the two vectors do point exactly opposite ways.

angle(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs),'noSymmetry') / degree

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

ori = orientation.byEuler(10*degree,20*degree,30*degree,cs)

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
% directions is the <FundamentalSector.html Fundamental Sector>. How the
% crystal axes relate to the Cartesian frame the numbers above are given in
% is <CrystalReferenceSystem.html Reference System>.

%#ok<*ASGLU>
%#ok<*VUNUS>
%#ok<*POLAR>
