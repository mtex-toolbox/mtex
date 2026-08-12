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

%% Testing and projecting
%
% Let us take an arbitrary crystal direction

v = Miller(2,3,1,cs)

%%
% We may check whether a direction is inside the fundamental region by the
% command <sphericalRegion.checkInside.html checkInside>

sR.checkInside(v)


%%
% and its symmetrically equivalent representative inside the sector is
% found by <Miller.project2FundamentalRegion.html project2FundamentalRegion>

v.project2FundamentalRegion

%%

hold on
plot(v)
plot(v.project2FundamentalRegion,'MarkerFaceColor','Red')
hold off

%% Other symmetries
%
% The shape of the sector depends on the point group, and it becomes larger
% the fewer symmetry elements there are. The triclinic group leaves the
% whole sphere.

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
% Note that a sector is a purely geometric object - it carries no
% orientation information. Its counterpart in orientation space is the
% <MisorientationTheory.html fundamental region>, represented by
% <orientationRegion.orientationRegion.html orientationRegion>.

