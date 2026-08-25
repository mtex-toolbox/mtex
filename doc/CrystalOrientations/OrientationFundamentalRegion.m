%% Fundamental Regions
%
%%
% Symmetry makes an orientation a set of equivalent rotations, see
% <OrientationSymmetry.html Symmetry>. A *fundamental region* is the part of
% rotation space that contains exactly one member of every such set. It is
% what makes a plot of orientations unambiguous, and it is the domain on
% which ODFs, axis distributions and angle distributions are computed.

plottingConvention.default('y↑→x');

%% The Space of All Rotations
%
% Without symmetry, rotation space is a ball of radius $180^\circ$: the
% direction of a point is the rotation axis, its distance from the centre
% the rotation angle.

% triclinic crystal symmetry
cs = crystalSymmetry('triclinic')

%%

% the corresponding orientation space
oR_all = fundamentalRegion(cs);

plot(oR_all)

%%
% Rotations placed into it: one by $180^\circ$ about the z axis, and two
% families about the x and y axes.

% rotation about the z-axis about 180 degree
rotZ = orientation.byAxisAngle(vector3d.Z,180*degree,cs);

hold on
plot(rotZ,'MarkerColor','b','MarkerSize',10)
hold off

%%

% rotations about the x- and y-axis about 30,60,90 ... degree
rotX = orientation.byAxisAngle(vector3d.X,(-180:30:180)*degree,cs);
rotY = orientation.byAxisAngle(vector3d.Y,(-180:30:180)*degree,cs);

hold on
plot(rotX,'MarkerColor','r','MarkerSize',10)
plot(rotY,'MarkerColor','g','MarkerSize',10)
hold off

%%
% Each family lies on a straight line through the centre, because all its
% rotations share an axis and differ only in angle. The $\pm180^\circ$ ends
% of a line are the same rotation, so the surface of the ball is glued to
% itself - which is why rotation space is not simply a ball.
%
% Sections of constant rotational angle are the flat way of looking at the
% same thing.

plotSection(rotZ,'MarkerColor','b','axisAngle',(30:30:180)*degree)
hold on
plot(rotX,'MarkerColor','g','add2all')
plot(rotY,'MarkerColor','r','add2all')
hold off

%% What Crystal Symmetry Does
%
% Each proper symmetry operation folds the ball onto itself, so a group with
% $n$ proper elements cuts it into $n$ equal pieces. Orthorhombic symmetry
% has four, and the region MTEX picks is the central one.

cs = crystalSymmetry('222')

%%

oR = fundamentalRegion(cs);

close all
plot(oR_all)
axis off
hold on
plot(oR,'color','r')
hold off

%% Real Data Lands Inside It
%
% Measured orientations are drawn in the fundamental region without being
% asked to.

mtexdata forsterite

%%

plot(ebsd('Fo').orientations,'axisAngle')

%%
% Nothing sticks out of the region, because every orientation was replaced
% by its equivalent inside. Doing that explicitly, rather than only for the
% plot, is
% <orientation.project2FundamentalRegion.html |project2FundamentalRegion|>.

ori = ebsd('Fo').orientations.project2FundamentalRegion

%% Recentring the Region
%
% The region need not sit at the origin. Centred on the mean orientation of
% a grain, it is the natural frame for looking at the spread within that
% grain - orientations that would otherwise be split across the boundary of
% the region stay together.

% segment data into grains
[grains,ebsd] = calcGrains(ebsd);

% take the orientations of the largest one
[~,id] = max(grains.area);
largeGrain = grains(id)

%%

ori = ebsd(largeGrain).orientations;

% recenter the fundamental zone to the mean orientation
center = largeGrain.meanOrientation;

ori = ori.project2FundamentalRegion(center)

%%

plot(ori,'axisAngle')
hold on
plot(center,'MarkerFaceColor','r','MarkerSize',20)
hold off

%%
% The cloud is a small blob around the red marker - no orientation in this
% grain is more than about $6^\circ$ from the mean - rather than a set of
% points spread over the whole region.

%% Fundamental Regions of Misorientations
%
% A misorientation carries two symmetries, one from each crystal, so its
% region is cut by both and is correspondingly smaller.

oR = fundamentalRegion(ebsd('Fo').CS,ebsd('En').CS);

plot(oR)

%%
% Boundary misorientations between the two phases, drawn in it:

plot(grains.boundary('Fo','En').misorientation)

%% Antipodal Symmetry Between Grains of One Phase
%
% Between two grains of the *same* phase there is no way to say which grain
% is first, so a misorientation and its inverse are indistinguishable. In
% axis-angle terms the inverse has the same angle and the opposite axis,
% which is the |'antipodal'| flag of
% <VectorsAxes.html Axes and Antipodal Symmetry> applied to orientation
% space.

oR = fundamentalRegion(ebsd('Fo').CS,ebsd('Fo').CS,'antipodal');

plot(oR)

%%
% Half the size of the region without the flag. MTEX sets the flag on
% same-phase boundary misorientations by itself.

mori = grains.boundary('Fo','Fo').misorientation

%%

plot(mori)

%%
% Removing it draws the same data in the larger region, with each
% misorientation and its inverse now counted as different.

mori.antipodal = false;

plot(mori)

%% Axis Angle Sections
%
% As for the full ball, sections of constant rotational angle flatten the
% region.

plotSection(mori,'axisAngle')

%%
% With antipodal symmetry, each pair of opposite axes collapses onto one
% point and the sections shrink accordingly.

plotSection(mori,'axisAngle','antipodal')

%% Next
%
% The counterpart for directions rather than orientations is the
% <FundamentalSector.html Fundamental Sector>. What misorientations are, and
% how they are analysed, is <Misorientations.html Misorientations>.

%#ok<*NASGU>
%#ok<*NOPTS>
