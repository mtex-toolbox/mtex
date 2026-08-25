%% Fundamental Sector
%
%%
% Crystal symmetry makes many directions equivalent. The *fundamental
% sector* is a choice of one representative for each class of symmetrically
% equivalent directions - a patch of the sphere that tiles the whole sphere
% when the symmetry elements are applied to it. It is what an inverse pole
% figure is plotted on, and it is the region in which
% <VectorsAxes.html directions> are placed by |project2FundamentalRegion|.
%
% For cubic symmetry it is the familiar triangle spanned by the
% $\left<100\right>$, $\left<110\right>$ and $\left<111\right>$ poles.


cs = crystalSymmetry('432')

plot(cs)
hold on
plot(cs.fundamentalSector,'color','Red')
hold off

%%
% The sector itself is a <sphericalRegion.sphericalRegion.html
% sphericalRegion>

sR = cs.fundamentalSector

%%
% It is stored as an intersection of half spaces - a direction belongs to
% the sector if it has a non negative inner product with each of the normal
% vectors |sR.N|. For the cubic group there are three of them, one per edge
% of the triangle.

sR.N

%% Testing and Projecting
%
% Take an arbitrary crystal direction.

v = Miller(2,3,1,cs)

%%
% <sphericalRegion.checkInside.html |checkInside|> answers whether it is
% inside the sector.

sR.checkInside(v)

%%
% It is not.

%%
% The equivalent direction that is inside comes from
% <Miller.project2FundamentalRegion.html |project2FundamentalRegion|>.

v.project2FundamentalRegion

%%
% $(123)$ - the same three indices, sorted. For the cubic group that is
% exactly what the sector selects, which is why $\left<123\right>$ and
% $(231)$ are the same family of directions.

%%

hold on
plot(v)
plot(v.project2FundamentalRegion,'MarkerFaceColor','Red')
hold off

%% Other Symmetries
%
% The shape of the sector follows from the point group, and the fewer
% elements the group has the larger the sector is. Only the point group 1
% leaves the whole sphere; the triclinic Laue group $\bar 1$ already halves
% it, since the inversion identifies every direction with its opposite. The
% ten Laue groups below the triclinic one:

newMtexFigure('layout',[2 5],'figSize','medium');
for lId = 2:11
  nextAxis(lId-1);
  cs = crystalSymmetry('LaueId',lId);
  plot(cs,'doNotDraw')
  hold on
  plot(cs.fundamentalSector,'color','red','doNotDraw','LineWidth',3)
  hold off
  mtexTitle(cs.LaueName)
end

%%
% Each plot shows the symmetry elements of the group with its sector drawn
% in red. Going from |6/mmm| to |2/m| the red patch grows by exactly the
% factor by which the number of symmetry elements drops.
%
%% Next
%
% A sector is a purely geometric object and carries no orientation
% information. Its counterpart for orientations is the
% <OrientationFundamentalRegion.html Fundamental Region>, represented by an
% <orientationRegion.orientationRegion.html |@orientationRegion|>. The
% sector is also what an
% <OrientationInversePoleFigure.html inverse pole figure> is drawn on.

