%% Fundamental Regions
%
%%
% Symmetry makes one physical orientation a set of equivalent rotations,
% see <OrientationSymmetry.html Symmetry>. A *fundamental region* keeps one
% representative of each set so orientations can be plotted and analysed
% without symmetry-related copies.
%
% A fundamental region is not unique. MTEX normally chooses the compact
% region around the identity rotation. Points on its boundary can be tied
% between equivalent representatives, so "one representative" includes a
% consistent boundary convention.
%
% This page assumes the crystal-to-specimen map from
% <DefinitionAsCoordinateTransform.html Theory> and the axis--angle
% coordinates from <RotationRepresentations.html Rotation Representations>.
% These regions are also the domains used for ODFs, rotation-axis
% distributions and rotation-angle distributions.

plottingConvention.default('y↑→x');

%% The Space of All Rotations
%
% Without rotational symmetry, axis--angle space is a ball of radius
% $180^\circ$. The direction of a point is the rotation axis, and its
% distance from the centre is the rotation angle.

% triclinic crystal symmetry
cs = crystalSymmetry('triclinic');

% the corresponding orientation space
oR_all = fundamentalRegion(cs);

plot(oR_all)

%%
% Place one half turn about the z axis into the ball.

rotZ = orientation.byAxisAngle(vector3d.Z,180*degree,cs);

hold on
plot(rotZ,'MarkerColor','b','MarkerSize',10)
hold off

%%
% Add families about the x and y axes in steps of $30^\circ$.

rotX = orientation.byAxisAngle(vector3d.X,(-180:30:180)*degree,cs);
rotY = orientation.byAxisAngle(vector3d.Y,(-180:30:180)*degree,cs);

hold on
plot(rotX,'MarkerColor','r','MarkerSize',10)
plot(rotY,'MarkerColor','g','MarkerSize',10)
hold off

%%
% Each family lies on a straight line through the centre because its
% rotations share an axis and differ only in angle. The $-180^\circ$ and
% $180^\circ$ ends of a line are the same rotation. Opposite points on the
% surface are therefore identified, which is why rotation space is not an
% ordinary solid ball.
%
% Sections of constant rotation angle are a flat view of the same geometry.

plotSection(rotZ,'MarkerColor','b','axisAngle',(30:30:180)*degree)
hold on
plot(rotX,'MarkerColor','g','add2all')
plot(rotY,'MarkerColor','r','add2all')
hold off

%%
% Notice that each x- and y-axis family passes through the same point at
% zero angle. At $180^\circ$, its two opposite axis directions again
% describe one rotation.

%% What Crystal Symmetry Does
%
% Each proper symmetry operation folds the ball onto itself. A group with
% $n$ proper operations therefore cuts it into $n$ equal-volume regions.
% Orthorhombic |222| symmetry has four such operations.
%
% Crystal point groups can also contain reflections or inversion. Those
% improper operations do not create additional rotations, so
% <fundamentalRegion.html |fundamentalRegion|> uses the proper rotation
% group by default.

cs = crystalSymmetry('222');

oR = fundamentalRegion(cs);

close all
plot(oR_all)
axis off
hold on
plot(oR,'color','r')
hold off

%%
% The red region is one of four equivalent parts of the complete grey ball.
% MTEX chooses the central representative shown here.
%
% An orientation with specimen symmetry is reduced from the other side as
% well. Pass both symmetries as |fundamentalRegion(ori.CS,ori.SS)|; the role
% of the second group is developed in
% <SpecimenSymmetry.html Specimen Symmetry>.

%% Real Data Lands Inside It
%
% MTEX plots measured orientations in their fundamental region by default.

mtexdata forsterite silent

plot(ebsd('Fo').orientations,'axisAngle')

%%
% No point crosses the boundary because the plotting code selects an
% equivalent representative inside it. This selection does not change the
% orientations stored in |ebsd|.
% MTEX reports that it samples 2,000 points for this dense plot. The sample
% changes only the figure, not the data or the fundamental region.
%
% Apply the same selection explicitly with
% <orientation.project2FundamentalRegion.html
% |project2FundamentalRegion|>. The method returns a new orientation array.

ori = ebsd('Fo').orientations.project2FundamentalRegion;

%% Recentring the Region
%
% The region need not be centred on the identity rotation. Centring it on a
% grain mean keeps a tight orientation cloud together when the standard
% region would split equivalent representatives across a boundary.
%
% <GrainReconstruction.html Grain reconstruction> is only supporting setup
% here. It supplies the mean orientation of the largest grain.

[grains,ebsd] = calcGrains(ebsd);

[~,id] = max(grains.area);
largeGrain = grains(id);

% keep the indexed orientations inside the grain footprint
ori = ebsd(largeGrain).orientations;
ori = ori(~isnan(ori));

center = largeGrain.meanOrientation;

% select representatives nearest to the grain mean
ori = ori.project2FundamentalRegion(center);

% retain those explicit representatives when plotting
plot(ori,'axisAngle','ignoreFundamentalRegion','all')
hold on
plot(center,'MarkerFaceColor','r','MarkerSize',20)
hold off

% maximum angular distance from the mean, in degrees
maxSpread = max(angle(ori,center)) ./ degree

%%
% The points remain in a compact neighbourhood of the red mean orientation.
% The displayed maximum is just over $6^\circ$, rather than a spread over
% the whole region. The red marker need not be the Euclidean centre of the
% drawn coordinates; |angle| supplies the rotational distance.
%
% Recentring selected equivalent representatives. It did not rotate or
% otherwise change the measured orientations.

%% Fundamental Regions of Misorientations
%
% A <MisorientationTheory.html misorientation> carries one crystal symmetry
% from each crystal. Its fundamental region is reduced by both groups and
% is correspondingly smaller.

oR = fundamentalRegion(ebsd('Fo').CS,ebsd('En').CS);

plot(oR)

%%
% Boundary misorientations between forsterite and enstatite lie inside this
% two-symmetry region.

plot(grains.boundary('Fo','En').misorientation)

%%
% The points stay inside the outline even though the region is much smaller
% than the full ball. The phase order remains meaningful for a two-phase
% boundary, so MTEX does not identify these misorientations with their
% inverses.

%% Antipodal Symmetry Between Grains of One Phase
%
% Between two grains of the *same* phase there is no way to say which grain
% is first. A misorientation and its inverse are therefore indistinguishable.
% In axis--angle coordinates the inverse has the same angle and the opposite
% axis. MTEX records this grain-exchange symmetry with the |'antipodal'|
% flag described for directions in
% <VectorsAxes.html Axes and Antipodal Symmetry>.

oR = fundamentalRegion(ebsd('Fo').CS,ebsd('Fo').CS,'antipodal');

plot(oR)

%%
% The antipodal region has half the volume of the corresponding region
% without grain-exchange symmetry. MTEX sets the flag on same-phase boundary
% misorientations by itself, as the following object summary shows.

mori = grains.boundary('Fo','Fo').misorientation

%%

plot(mori)

%%
% Each boundary now contributes one representative from the pair consisting
% of a misorientation and its inverse. No point needs the other half of the
% non-antipodal region.
%
% Removing the flag from this local variable draws the same rotations in
% the larger region, where the two orders count as different.

mori.antipodal = false;

plot(mori)

%%
% The cloud now occupies the larger outline. These are not additional grain
% boundaries; only the choice of representative has changed.

%% Axis--Angle Sections
%
% Sections of constant rotation angle flatten the larger region. The panel
% outline at each angle shows which rotation axes are allowed there.

plotSection(mori,'axisAngle')

%%
% Opposite axes remain separate in these panels because |mori.antipodal| is
% currently false.
%
% Supplying |'antipodal'| to the plot identifies every pair of opposite axes.

plotSection(mori,'axisAngle','antipodal')

%%
% The second gallery contains the same boundary data in smaller panel
% outlines. Its paired axes have collapsed onto one representative.

%% How MTEX Chooses a Region
%
% MTEX chooses representatives by rotational distance. For a selected
% centre, it keeps the rotations that are at least as close to that centre
% as any of their symmetry equivalents. This nearest-representative cell is
% a Voronoi cell in rotation space.
%
% Midplanes between the centre and its symmetry equivalents bound the cell.
% A different centre gives a different, equally valid fundamental region.
% A point exactly on a midplane has two equally near representatives, which
% is the boundary tie noted at the start of the page.
%
% The figures on this page use axis--angle coordinates, where radial
% distance is the rotation angle. In Rodrigues--Frank coordinates the same
% bisectors are Euclidean planes, so fundamental regions appear as
% plane-faced polyhedra. <RotationRepresentations.html Rotation Representations>
% compares these coordinate choices.

%% References
%
% * A. Morawiec, <https://doi.org/10.1007/978-3-662-09156-2 Orientations
% and Rotations: Computations in Crystallographic Textures>, Springer,
% 2004, develops the geometry of rotation space, symmetry and
% misorientation distributions.
% * A. Morawiec and D. P. Field,
% <https://doi.org/10.1080/01418619608243708 Rodrigues Parameterization for
% Orientation and Misorientation Distributions>, _Philosophical Magazine A_
% 73 (1996), 1113-1130, derives asymmetric domains for all crystal
% symmetries in Rodrigues space.
% * R. Krakow _et al._,
% <https://doi.org/10.1098/rspa.2017.0274 On Three-Dimensional
% Misorientation Spaces>, _Proceedings of the Royal Society A_ 473 (2017),
% 20170274, gives a practical guide to symmetry-reduced axis--angle spaces
% for orientation-relationship analysis.

%% Next
%
% Continue with <SpecimenSymmetry.html Specimen Symmetry> for a second
% symmetry acting on orientations. The counterpart for directions is the
% <FundamentalSector.html Fundamental Sector>.
%
% The next chapter begins with <Misorientations.html Misorientations>.
% <MisorientationGrainExchangeSym.html Grain Exchange Symmetry> develops the
% same-phase distinction used above.

%#ok<*NASGU>
%#ok<*NOPTS>
