%% Crystal Shapes
%
%%
% A crystal shape is the outer form of a crystal - a solid bounded by
% lattice planes - and MTEX draws it as an object in its own right. It is
% the most direct way to show an orientation: instead of three angles, the
% crystal itself, sitting the way the data says it sits. Twinning
% relationships, slip systems and lattice planes are shown the same way.

plottingConvention.default('y↑→x');

%% Simple Crystal Shapes
%
% Cubic and hexagonal materials are usually drawn as a cube or a hexagonal
% prism, the faces being $\{100\}$ in the cubic case and $\{10\bar10\}$,
% $\{0001\}$ in the hexagonal one.

% import some hexagonal data
mtexdata titanium;

%%

% define a simple hexagonal crystal shape
cS = crystalShape.hex(ebsd.CS)

%%

close all
plot(cS,'faceAlpha',0.2,'figSize','small')
drawNow(gcm,'final')

%%
% Internally the shape is a list of faces, bounded by the vertices |cS.V|
% and the edges |cS.E|.

cS.V

%% Planes and Slip Systems Inside the Crystal
%
% <crystalShape.plotInnerFace.html |plotInnerFace|>,
% <crystalShape.plotInnerDirection.html |plotInnerDirection|>,
% <crystalShape.plotSlipSystem.html |plot(cS,sS)|> and
% <vector3d.arrow3d.html |arrow3d|> draw lattice planes, directions and slip
% systems inside the shape, which is what makes a slip system readable at
% all - a plane and a direction in it.

sS = [slipSystem.pyramidal2CA(ebsd.CS), ...
  slipSystem.pyramidalA(ebsd.CS)]

%%

plot(cS,'faceAlpha',0.2,'figSize','small')
hold on
plot(cS,sS(2),'faceColor','blue')
plot(cS,sS(1),'faceColor','red')
hold off
drawNow(gcm,'final')

%%
% Both slip planes are pyramidal, and the drawing shows how differently the
% two slip directions lie in them.

%% Calculating with Crystal Shapes
%
% A crystal shape is defined in crystal coordinates, so an
% <OrientationDefinition.html orientation> applied to it turns it into
% specimen coordinates - exactly as it does for a crystal direction. That is
% how a shape ends up on a map at the orientation the measurement found.

% plot an EBSD map
close all
plot(ebsd,ebsd.orientations)

hold on
scaling = 100; % scale the crystal shape to have a nice size

% plot at position (500,500) the orientation of the corresponding crystal.
% we have to choose z = -50 such that the crystal shape becomes visible
% above the map
plot(500,500,-50, ebsd('xy',500,500).orientations * cS * scaling,...
  'faceAlpha',0.5,'linewidth',2)
hold off
drawNow(gcm,'final')

%%
% Three operations are available, and each of them accepts lists:
%
% * |factor * cS| scales the shape
% * |ori * cS| rotates it into the given orientation
% * |[xy] + cS| or |[xyz] + cS| shifts it to the given position
%
% Because lists are allowed, a whole map of grains is drawn in one call -
% one shape per grain, oriented like the grain and scaled by its size.

% compute some grains
grains = calcGrains(ebsd);
grains = smoothBoundary(grains,5);

% and plot them
cKey = ipfColorKey(grains);
color = cKey.orientation2color(grains.meanOrientation);
plot(grains,color,'FaceAlpha',0.5,'linewidth',2)

% find the big ones
isBig = grains.numPixel>50;

% define a list of crystal shape that is oriented as the grain mean
% orientation and scaled according to the grain area
cSGrains = grains(isBig).meanOrientation * cS * 0.7 * sqrt(grains(isBig).area);

% now we can plot these crystal shapes at the grain centers
hold on
plot(grains(isBig).centroid + cSGrains,'FaceColor',color(isBig,:),'FaceAlpha',0.7)
hold off
drawNow(gcm,'final')

%%
% Neighbouring grains with a similar colour turn out to have their c-axes
% pointing the same way, which the map colour alone does not say.

%% The Direct Route
%
% Passing the grains and a shape to |plot| does the scaling and positioning
% by itself.

% plot a grain map
plot(grains,grains.meanOrientation,'figSize','large','faceAlpha',0.5,'linewidth',2)

% and on top for each large grain a crystal shape colored according to the
% grain orientation
hold on
plot(grains(isBig), 0.7*cS, 'FaceColor', color(isBig,:), ...
  'linewidth',2,'FaceAlpha',0.7 )
hold off
drawNow(gcm,'final')

%%
% The same works in a pole figure, where each shape sits at the pole of the
% orientation it belongs to.

plotPDF(grains(isBig).meanOrientation,Miller({1,0,-1,0},{0,0,0,1},ebsd.CS),'contour')
plot(grains(isBig).meanOrientation,0.002*cSGrains,'add2all')

%%
% and in ODF sections.

% compute the odf
odf = calcDensity(ebsd.orientations);

% plot the odf in sigma sections
plotSection(odf,'sigma','contour')

% and on top of it the crystal shapes
plot(grains(isBig).meanOrientation,0.002*cSGrains,'add2all')

%% Twinning Relationships
%
% Two crystals in a twin relationship share a lattice plane. Drawing the
% parent and the twin together makes the relationship visible in a way the
% misorientation angle does not.

% define some twinning misorientation
mori = orientation.byAxisAngle(Miller({1 0 -1 0},ebsd.CS),34.9*degree)

%%

% plot the crystal in ideal orientation
close all
plot(cS,'FaceAlpha',0.5)

% and on top of it in twinning orientation
hold on
plot(mori * cS *0.9,'FaceColor','orange')
hold off
view(45,20)
drawNow(gcm,'final')

%% Shapes That Look Like the Real Crystal
%
% Outside the cubic and hexagonal cases a cube or a prism is a poor likeness.
% A realistic shape needs more faces, and each face has to be placed at the
% right distance from the origin - a face far away never reaches the solid
% and leaves no trace on it.
%
% Quartz makes the point.

cs = loadCIF('quartz')

%%
% Its habit is bounded mainly by these faces.

m = Miller({1,0,-1,0},cs);  % hexagonal prism
r = Miller({1,0,-1,1},cs);  % positive rhombohedron, usually bigger than z
z = Miller({0,1,-1,1},cs);  % negative rhombohedron
s1 = Miller({2,-1,-1,1},cs);% left tridiagonal bipyramid
s2 = Miller({1,1,-2,1},cs); % right tridiagonal bipyramid
x1 = Miller({6,-1,-5,1},cs);% left positive trapezohedron
x2 = Miller({5,1,-6,1},cs); % right positive trapezohedron

%%
% Taking the first three gives

N = [m,r,z];
cS = crystalShape(N)

plot(cS,'figSize','small')

%%
% Only the two rhombohedra show. The six prism faces are in the list, but
% they are so far from the origin that they never cut the solid - the shape
% has the same eight vertices it would have without them. Multiplying a
% normal by a factor larger than one moves its face inwards.

N = [2*m,r,z];

cS = crystalShape(N);
plot(cS,'colored','figSize','small')

%%
% Now the prism is there. In a real quartz crystal the negative rhombohedron
% is somewhat smaller than the positive one, which is again a matter of
% distance.

% collect the face normal with the right scaling
N = [2*m,r,0.9*z];

cS = crystalShape(N);
plot(cS,'colored','figSize','small')

%%
% Adding the tridiagonal bipyramid and the positive trapezohedron gives the
% small slanted faces that make quartz recognisable, and that break its
% apparent hexagonal symmetry down to the trigonal one it really has.

% collect the face normal with the right scaling
N = [2*m,r,0.9*z,0.7*s1,0.3*x1];

cS = crystalShape(N);
plot(cS,'colored','figSize','small')

%% Habitus and Extension
%
% Placing every face by hand is tedious. The alternative is to model the
% distances by two parameters, following J. Enderlein,
% <https://library.wolfram.com/infocenter/Articles/3279 A package for
% displaying crystal morphology. Mathematica Journal, 7(1), 1997>. With both
% set to one, the faces are taken as they are.

% take the face normals unscaled
N = [m,r,z,s2,x2];

habitus = 1;
extension = [1 1 1];
cS = crystalShape(N,habitus,extension);
plot(cS,'colored','figSize','small')

%%
% *extension* is the inverse extent of the crystal along each axis, so
% raising the second and third entry makes the crystal longer and the
% negative rhombohedra smaller.

extension = [1 1.2 1.1];
cS = crystalShape(N,habitus,extension);
plot(cS,'colored','figSize','small')

%%
% *habitus* controls how close the faces with mixed indices come to the
% origin. Raising it lets the trapezohedron and the bipyramid grow at the
% expense of the prism.

habitus = 1.1;
cS = crystalShape(N,habitus,extension);
plot(cS,'colored','figSize','small'), snapnow

habitus = 1.2;
cS = crystalShape(N,habitus,extension);
plot(cS,'colored','figSize','small'), snapnow

habitus = 1.3;
cS = crystalShape(N,habitus,extension);
plot(cS,'colored','figSize','small')

%% Selecting a Face
%
% A single face is picked out by its normal, which is how one face is
% highlighted or measured.

plot(cS,'figSize','small')
hold on
plot(cS(Miller(0,-1,1,0,cs)),'FaceColor','DarkRed')
hold off

% zoom a bit out to fit the screen
camzoom(0.7)

%% A Gallery of Predefined Shapes
%
% Several minerals come ready made, with the face distances already tuned.

plot(crystalShape.olivine,'colored','figSize','small')

%%

plot(crystalShape.garnet,'colored','figSize','small')

%%

plot(crystalShape.topaz,'colored','figSize','small')

%%

plot(crystalShape.plagioclase,'colored','figSize','small')

%% Next
%
% Shapes taken from the crystallographic database of the Smorf project are
% <CrystalShapeSmorf.html Advanced Crystal Shapes>. The planes the faces
% stand for are <CrystalDirections.html Miller Indices>.

%#ok<*NOPTS>
