%% Fundamental Sector
%
% Crystal symmetry makes many crystal directions equivalent. A
% *fundamental sector* is a patch of the unit sphere that contains a
% representative of every symmetry-equivalent family. Its interior contains
% exactly one representative from each general family; directions on the
% boundary need a qualification discussed below.
%
% This page assumes the Miller notation from <CrystalDirections.html Miller
% Indices> and the equivalent-direction families from
% <CrystalOperations.html Operations>. The sector is the domain of an
% <OrientationInversePoleFigure.html inverse pole figure>. It is also the
% region into which |project2FundamentalRegion| maps crystal directions.

%% A Cubic Example
%
% For the cubic Laue group |m-3m|, the sector is the familiar spherical
% triangle with corners at $[001]$, $[101]$, and $[111]$.

cs = crystalSymmetry('m-3m');
corners = Miller({0,0,1},{1,0,1},{1,1,1},cs,'uvw');

plot(cs)
hold on
plot(cs.fundamentalSector,'color','red')
plot(corners,'labeled','MarkerFaceColor','white','backgroundColor','w')
hold off

%%
% The black symbols and lines show the symmetry elements. The red boundary
% encloses the sector, and the three labelled directions identify its
% corners.

%% How MTEX Stores the Sector
%
% <sphericalRegion.sphericalRegion.html |@sphericalRegion|> represents the
% sector as an intersection of spherical half-spaces.

sR = cs.fundamentalSector

%%
% The summary reports three edge normals, one for each side of the cubic
% triangle. They are stored in |sR.N|.

sR.N

%%
% For this sector, a direction $\mathbf{v}$ lies inside when every normal
% $\mathbf{n}_i$ satisfies
% $\mathbf{n}_i \cdot \mathbf{v} \geq 0$. The rows printed above are those
% inward-pointing unit normals in the crystal reference frame.

%% Testing and Projecting
%
% Consider the Miller direction $(231)$.

v = Miller(2,3,1,cs);

%%
% <sphericalRegion.checkInside.html |checkInside|> tests it against all
% three half-spaces.

isInside = sR.checkInside(v)

%%
% The false result means that $(231)$ is outside the chosen sector. It does
% not mean that its symmetry-equivalent family is absent.
%
% <Miller.project2FundamentalRegion.html |project2FundamentalRegion|>
% selects an equivalent representative inside the sector.

vFundamental = v.project2FundamentalRegion

%%
% The result is $(213)$, a symmetry-equivalent permutation of the indices.
% Both directions belong to the same $\{123\}$ form; the sector selects one
% representative from that family.

%%

hold on
plot(v)
plot(vFundamental,'MarkerFaceColor','red')
hold off

%%
% The original marker lies outside the red triangle, while the filled red
% marker lies inside it. Their different positions do not make them
% crystallographically distinct.

%% Other Laue Groups
%
% The exact point group determines the shape of the sector. Lower symmetry
% means fewer equivalent copies and therefore a larger sector. Only point
% group |1| leaves the whole sphere. The triclinic Laue group $\bar{1}$
% already halves it because inversion identifies every direction with its
% opposite. The other ten Laue groups are shown below.

mtexFig = newMtexFigure('layout',[2 5],'figSize','medium');
for lId = 2:11
  ax = mtexFig.nextAxis(lId-1);
  cs = crystalSymmetry('LaueId',lId);
  plot(cs,'parent',ax,'doNotDraw')
  hold(ax,'on')
  plot(cs.fundamentalSector,'parent',ax,'color','red',...
    'doNotDraw','LineWidth',3)
  hold(ax,'off')
  mtexTitle(ax,cs.LaueName,'doNotDraw')
end
mtexFig.drawNow;

%%
% Each panel shows the symmetry elements of one Laue group and outlines its
% sector in red. Within this gallery, the sector area is inversely
% proportional to the number of symmetry operations. Moving from |6/mmm|
% to |2/m| enlarges the red patch by exactly the factor by which the number
% of symmetry operations falls.

%% Point Groups, Laue Groups, and Boundaries
%
% A fundamental sector follows the point group supplied to MTEX. Adding the
% |'antipodal'| option identifies $\mathbf{v}$ with $-\mathbf{v}$ and is
% equivalent to using the corresponding Laue group. This distinction
% matters for a non-centrosymmetric crystal: its point-group sector may be
% larger than its Laue-group sector.
%
% The gallery uses Laue groups because conventional diffraction commonly
% identifies Friedel pairs. MTEX does not impose that antipodal
% identification when a point group is used without |'antipodal'|.
%
% For a point group $G$, a general direction has $\mathrm{ord}(G)$
% symmetry-equivalent copies. The sector therefore covers the fraction
% $1/\mathrm{ord}(G)$ of the sphere, or spherical area
% $4\pi/\mathrm{ord}(G)$. A direction fixed by a nonidentity operation has
% fewer distinct copies and often lies on an edge or vertex.
%
% Not every edge is a symmetry element. A closed sector can contain two
% equivalent representatives on paired seam edges. Consequently, projection
% is unique in the interior but a boundary tie may be resolved by either
% representative. Both answers are crystallographically equivalent.

%% References
%
% * Th. Hahn, H. Klapper, U. Müller, and M. I. Aroyo,
% <https://doi.org/10.1107/97809553602060000930 Point groups and crystal
% classes>, _International Tables for Crystallography A_, ch. 3.2, 2016,
% tabulates point-group stereograms, general orbits, and special directions.
% * D. Chateigner, L. Lutterotti, and M. Morales,
% <https://onlinelibrary.wiley.com/iucr/itc/Ha/ch5o3v0001/ Quantitative
% texture analysis and combined analysis>, _International Tables for
% Crystallography H_, ch. 5.3, shows the nonredundant inverse-pole-figure
% sectors for the crystal systems.
% * A. Morawiec,
% <https://doi.org/10.1007/978-3-662-09156-2 Orientations and Rotations:
% Computations in Crystallographic Textures>, Springer, 2004, develops
% symmetry reduction for directions and orientations.
% * G. Nolze and R. Hielscher,
% <https://doi.org/10.1107/S1600576716012942 Orientations - perfectly
% colored>, _Journal of Applied Crystallography_ 49, 1786-1802, 2016,
% explains how fundamental-sector topology constrains inverse-pole-figure
% colour keys.

%% Next
%
% A sector is a purely geometric object and carries no orientation
% information. Its counterpart for orientations is the
% <OrientationFundamentalRegion.html Fundamental Region>, represented by an
% <orientationRegion.orientationRegion.html |@orientationRegion|>. The
% sector is also what an
% <OrientationInversePoleFigure.html inverse pole figure> is drawn on.
%
% Continue in this chapter with <QuasiCrystals.html Quasi Symmetries>, where
% the same construction reduces directions under non-crystallographic point
% groups.

%#ok<*NOPTS>
