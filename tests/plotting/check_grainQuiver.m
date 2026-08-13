function check_grainQuiver
% check grain2d/quiver - where the arrows sit and how big their heads are
%
% Two properties of the plot, neither of which any numerical test sees:
%
% 1. An arrow pointing into the screen used to be drawn below the map, where
%    the grains hide it. It is now shifted so that its tip ends in the grain
%    center and its tail sticks out of the map, and the center it refers to
%    is marked. Note that the drawn segment is then the same as for the
%    opposite direction - only the head changes ends.
%
% 2. The MATLAB arrow head is a fixed fraction of the arrow, so on a map
%    whose grains differ by a factor of ten the long arrows end in a fork
%    while the short ones show no head at all. The head is bounded here by
%    headSize points on the screen, which is read off the axis limits and
%    therefore only correct if the heads are drawn after the arrows.
%
% The map is a 12x12 square grid of four blocks of two different sizes -
% unequal on purpose, since a bound that is never reached is not a bound.
%
% See also
% grain2d/quiver plottingConvention

oldVis = get(0,'DefaultFigureVisible');
set(0,'DefaultFigureVisible','off');
cleanUp = onCleanup(@() cleanup(oldVis)); %#ok<NASGU>

cs = crystalSymmetry('1','mineral','test');

n = 12;
[c,r] = meshgrid(1:n,1:n);
blockId = 1 + (r>4) + 2*(c>4);
oris = orientation.byAxisAngle(zvector,(1:4)*20*degree,cs);
rot = rotation.id(n,n);
for k = 1:4, rot(blockId==k) = oris(k); end
ebsd = EBSDsquare([],rot,2*ones(n,n),[0 1],{'notIndexed',cs},'dxy',[1 1]);

grains = calcGrains(ebsd,'threshold',5*degree);
assert(length(grains)==4,'expected 4 grains, got %d',length(grains));
assert(max(grains.diameter)/min(grains.diameter) > 1.5,...
  'the test map must have grains of different size');

pos = grains.centroid;
N = grains.how2plot.outOfScreen;

% two arrows out of the screen, two into it
dir = vector3d.byXYZ([[ones(2,1);-ones(2,1)],zeros(4,2)]);
dir = rotation.map(xvector,N) .* dir;  % +N for 1:2, -N for 3:4

close all
h = quiver(grains,dir);

%% the grain centers are marked

hM = findobj(gca,'tag','grainCenter');
assert(numel(hM)==1,'expected one marker object, got %d',numel(hM));
M = vector3d.byXYZ([hM.XData(:) hM.YData(:) hM.ZData(:)]);
assert(length(M)==length(grains) && all(norm(M - pos) < 1e-10),...
  'the markers must sit at the grain centers');
assert(isequal(hM.MarkerFaceColor,h.Color) && isequal(hM.MarkerEdgeColor,h.Color),...
  'the marker must be filled in the color of the arrow');
assert(strcmp(hM.Annotation.LegendInformation.IconDisplayStyle,'off'),...
  'the markers must not show up in the legend');

% these arrows point straight at the viewer and have no direction on the
% screen - they must not produce a degenerate head
assert(isempty(findobj(gca,'tag','arrowHead')),...
  'an arrow along the view axis must not get a head');

%% arrows pointing into the screen end in the grain center

X = [h.XData(:) h.YData(:) h.ZData(:)];
U = [h.UData(:) h.VData(:) h.WData(:)];
tip = X + U;

% arrows along +N start at the centroid
d0 = norm(vector3d.byXYZ(X(1:2,:)) - pos(1:2));
% arrows along -N end at the centroid
d1 = norm(vector3d.byXYZ(tip(3:4,:)) - pos(3:4));

assert(all(d0 < 1e-10),'out of plane arrows must start at the centroid: %g',max(d0));
assert(all(d1 < 1e-10),'into plane arrows must end at the centroid: %g',max(d1));

% and their tails must stick out of the map
above = dot(vector3d.byXYZ(X(3:4,:)) - pos(3:4),N);
assert(all(above > 0),'into plane arrows must have their tail above the map');

% the arrows themselves are untouched
assert(all(abs(norm(vector3d.byXYZ(U)) - 0.2*grains.diameter) < 1e-10),...
  'the arrow length must not change');

%% the arrow heads are bounded

dirT = rotation.byAxisAngle(cross(N,xvector),45*degree) .* dir;

% with a bound no arrow reaches, the head is proportional to the arrow
[hl,apex,tipT,len] = headOf(grains,dirT,{'headSize',1e6});
assert(all(abs(hl./len - 0.25) < 1e-6),...
  'below the bound the head must be a quarter of the arrow: %s',mat2str(hl./len,3));
assert(max(len)/min(len) > 1.5 && max(hl)/min(hl) > 1.5,...
  'below the bound a longer arrow must get a longer head');

% the apex is the arrow tip, lifted only towards the viewer - a head ending
% exactly in the plane of the map is a tie the depth sorting may lose
off = apex - tipT;
assert(all(angle(off,N) < 1e-10),'the head apex may only be lifted towards the viewer');
assert(all(norm(off) < 0.05*len),'the lift of the head must be negligible');

% once the bound bites, all heads are equal - however long the arrow
hl = headOf(grains,dirT,{'headSize',0.5});
assert(max(hl)/min(hl) - 1 < 1e-10,...
  'above the bound all heads must have the same length: %s',mat2str(hl,3));

% and the default is bounded, i.e. does not scale with the arrow
hl = headOf(grains,dirT,{});
assert(max(hl)/min(hl) < max(len)/min(len),...
  'the default head must not scale with the arrow length');

% the bound is read off the axis, which has its final limits only once the
% arrows are drawn - into a fresh axes it must come out as over a map
close all
plot(grains,grains.meanOrientation);
hold on
hlMap = headOf(grains,dirT,{},true);
hlFresh = headOf(grains,dirT,{});
assert(all(abs(hlMap./hlFresh - 1) < 0.5),...
  'the head size must not depend on the axis limits being set already: %s vs %s',...
  mat2str(hlMap,3),mat2str(hlFresh,3));

%% the options switch all of it off again

close all
h = quiver(grains,dirT,'noHead');
assert(isempty(findobj(gca,'tag','arrowHead')) && h.MaxHeadSize > 0,...
  'noHead must leave the MATLAB arrow head in place');

close all
quiver(grains,dir,'noMarker');
assert(isempty(findobj(gca,'tag','grainCenter')),...
  'noMarker must not draw any marker');

close all
h = quiver(grains,dir,'noShift');
X = [h.XData(:) h.YData(:) h.ZData(:)];
assert(all(norm(vector3d.byXYZ(X) - pos) < 1e-10),'noShift must not shift');

% antipodal axes are symmetric about the center and stay there
close all
h = quiver(grains,dir,'antipodal');
X = [h.XData(:) h.YData(:) h.ZData(:)];
assert(all(norm(vector3d.byXYZ(X) - [pos;pos]) < 1e-10),...
  'antipodal axes must stay centred at the centroid');

% with noScaling MATLAB scales the arrows itself, so neither the shifted
% position nor the head length is known here
close all
h = quiver(grains,dir,'noScaling');
X = [h.XData(:) h.YData(:) h.ZData(:)];
assert(all(norm(vector3d.byXYZ(X) - pos) < 1e-10),'noScaling must not shift');

%% the decorations do not consume a color of the axes

% line() takes the next color of the axes color order even when it is given
% an explicit one, so the markers and the heads used to advance it by two
% per call: the two quiver commands at the end of doc/Plasticity/
% SchmidtFactor.m came out blue and green instead of blue and red

close all
ax = gca; hold on
co = ax.ColorOrder;

h1 = quiver(grains,dirT);
assert(ax.ColorOrderIndex == 2, ...
  'one quiver must consume exactly one color, it consumed %d',ax.ColorOrderIndex-1);

h2 = quiver(grains,dirT);
assert(ax.ColorOrderIndex == 3, ...
  'the second quiver must consume exactly one color, it consumed %d',ax.ColorOrderIndex-2);

assert(max(abs(h1.Color - co(1,:))) < 1e-6, ...
  'the first quiver got %s instead of the first color %s',...
  mat2str(h1.Color,3),mat2str(co(1,:),3));
assert(max(abs(h2.Color - co(2,:))) < 1e-6, ...
  'the second quiver got %s instead of the second color %s',...
  mat2str(h2.Color,3),mat2str(co(2,:),3));

% and the decorations take the color of the arrows they belong to
hM = findobj(ax,'tag','grainCenter'); hH = findobj(ax,'tag','arrowHead');
assert(numel(hM)==2 && numel(hH)==2,'expected a marker and a head per quiver');
assert(isequal(sortrows(round(vertcat(hM.MarkerFaceColor),6)), ...
  sortrows(round([h1.Color;h2.Color],6))), ...
  'the markers do not have the colors of their arrows');
assert(isequal(sortrows(round(vertcat(hH.Color),6)), ...
  sortrows(round([h1.Color;h2.Color],6))), ...
  'the heads do not have the colors of their arrows');

%% all of it follows the plotting convention, not the z axis

assert(angle(N,-zvector) < 1e-10,...
  'the default plotting convention should have z pointing into the screen');
grains.how2plot = plottingConvention(zvector,xvector); % z out of the screen now

close all
h = quiver(grains,dir);
X = [h.XData(:) h.YData(:) h.ZData(:)];
tip = X + [h.UData(:) h.VData(:) h.WData(:)];
assert(all(norm(vector3d.byXYZ(tip(1:2,:)) - pos(1:2)) < 1e-10),...
  'inverted convention: the arrows that now point into the screen must end at the centroid');
assert(all(norm(vector3d.byXYZ(X(3:4,:)) - pos(3:4)) < 1e-10),...
  'inverted convention: the arrows that now point out of the screen must start at the centroid');

close all
disp('check_grainQuiver: passed');

end

% -------------------------------------------------------------------------

function [hl,apex,tip,len] = headOf(grains,dir,opt,keepAxis)
% length of every arrow head, its apex, the arrow tip and the length of the
% arrow as it appears on the screen

if nargin < 4 || ~keepAxis, close all; end
h = quiver(grains,dir,opt{:});

hH = findobj(gca,'tag','arrowHead');
assert(numel(hH)==1,'expected one head object, got %d',numel(hH));

v = vector3d.byXYZ([hH.XData(:) hH.YData(:) hH.ZData(:)]);
assert(length(v)==4*length(dir),...
  'expected 4 points per head, got %d',length(v)/length(dir));

% the barbs are stored as barb - apex - barb - NaN
apex = v(2:4:end);
hl = norm(v(1:4:end) - apex);
assert(all(abs(norm(v(3:4:end) - apex) - hl) < 1e-10),...
  'the two barbs must be equally long');

U = vector3d.byXYZ([h.UData(:) h.VData(:) h.WData(:)]);
tip = vector3d.byXYZ([h.XData(:) h.YData(:) h.ZData(:)]) + U;

% the head is bounded in what is seen on the screen, so measure it there
N = grains.how2plot.outOfScreen;
len = norm(U - dot(U,N,'noAntipodal').*N);

% the barbs are at 22.5 degree, the head is measured along the arrow
hl = hl .* cos(22.5*degree);

end

% -------------------------------------------------------------------------

function cleanup(oldVis)
close all
set(0,'DefaultFigureVisible',oldVis);
end
