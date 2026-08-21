function check_hemispherePlots
% check that a plot spanning both hemispheres behaves as a single plot
%
% A spherical region that covers the upper as well as the lower hemisphere
% is drawn into two axes. That is a layout decision, not two plots: a small
% circle whose cone crosses the equator belongs on both halves, and so does
% a marker or a label added later.
%
% Before #330 was fixed everything added with hold on went into whichever
% axes happened to be current - typically the lower one, even for a circle
% around an axis in the upper hemisphere - and the half that did not fit
% there was simply clipped away at the rim rather than continued in the
% other axes.
%
% See also
% newSphericalPlot registerHemispheres sphericalPlot/allHemispheres

oldVis = get(0,'DefaultFigureVisible');
set(0,'DefaultFigureVisible','off');
cleanUp = onCleanup(@() cleanup(oldVis)); %#ok<NASGU>

% the triclinic pair of #330 - one axis just above, one well below the
% equator, both cones wide enough to cross it
cs = crystalSymmetry('1',[8.1 13 7.2],[94.23 116.64 87.72]*degree,'X||a*','Z||c');
o  = orientation.byEuler([322.049 87.7868 226.876; 50.0499 105.209 49.6594]*degree, cs);
h  = Miller(0,0,1,'uvw',cs);
v  = o*h;

checkAxesCount(v);
checkCircleOnBothHalves(o,h,v);
checkODFPoleFigure(o,h,v);
checkOtherPoleFigureUntouched(o,cs,v);

disp('check_hemispherePlots: passed');

end

% =========================================================================
function checkAxesCount(v)
% how many axes a plot spans

expected = {{},2; {'upper'},1; {'lower'},1; {'complete'},2; ...
  {'antipodal'},1; {'upper','lower'},2; {'antipodal','upper','lower'},2};

for i = 1:size(expected,1)

  close all
  plot(v,expected{i,1}{:},'doNotDraw');
  n = numel(gcmChildren);

  if n ~= expected{i,2}
    error('check_hemispherePlots: plot(v%s) gave %d axes, expected %d', ...
      sprintf(',''%s''',expected{i,1}{:}), n, expected{i,2});
  end
end

end

% =========================================================================
function checkCircleOnBothHalves(o,h,v)
% a circle crossing the equator is continued in the other half

close all
plotPDF(o,h,'complete','MarkerSize',8,'doNotDraw');
hold on
c = circle(v(1),35*degree,'lineColor','r','linewidth',2);
m = plot(v(1),'MarkerColor','b','MarkerSize',10);
hold off

ax = gcmChildren;
if numel(ax) ~= 2
  error('check_hemispherePlots: a complete pole figure needs two axes, got %d',numel(ax));
end

n = arrayfun(@(a) nPoints(c,a), ax);
if any(n == 0)
  error(['check_hemispherePlots: the circle around an axis %.2f degree '...
    'above the equator was drawn with %d / %d points into the two halves '...
    '- one of them got nothing'], 90 - v(1).theta/degree, n(1), n(2));
end

% no point of the circle may be lost on the way, and none drawn twice -
% vector3d/circle samples the small circle in one degree steps
total = 361;
if sum(n) ~= total
  error(['check_hemispherePlots: the two halves show %d of the %d points '...
    'of the circle'], sum(n), total);
end

% both halves have to draw the marker, so that their colors cycle in lockstep
if ~all(arrayfun(@(a) any(ismember(m(:),allchild(a))), ax))
  error('check_hemispherePlots: a marker added with hold on reached only one half');
end

end

% =========================================================================
function checkODFPoleFigure(o,h,v)
% the same, on a pole figure of an ODF - those axes are built by S2Fun/plot

close all
odf = unimodalODF(o(1),'halfwidth',15*degree);
plotPDF(odf,h,'complete','doNotDraw');
hold on
c = circle(v(1),35*degree,'lineColor','r','linewidth',2);
hold off

ax = gcmChildren;
n = arrayfun(@(a) nPoints(c,a), ax);

if numel(ax) ~= 2 || any(n == 0)
  error(['check_hemispherePlots: on an ODF pole figure the circle went '...
    '%s into %d axes'], mat2str(n), numel(ax));
end

end

% =========================================================================
function checkOtherPoleFigureUntouched(o,cs,v)
% both halves of the current pole figure - and only of that one

close all
h = [Miller(0,0,1,'uvw',cs),Miller(0,1,0,'uvw',cs)];
plotPDF(o,h,'complete','MarkerSize',8,'doNotDraw');
hold on
c = circle(v(1),35*degree,'lineColor','r','linewidth',2);
hold off

ax = gcmChildren;
n = arrayfun(@(a) nPoints(c,a), ax);

% the last pole figure is the current one, the first one must stay clean
if numel(ax) ~= 4 || any(n(1:2) > 0) || any(n(3:4) == 0)
  error(['check_hemispherePlots: over two pole figures the circle was '...
    'distributed as %s - it belongs to the current one, both halves of it'],...
    mat2str(n));
end

end

% =========================================================================
function n = nPoints(h,ax)
% number of points the handles h contribute to the axes ax
%
% Everything outside the region of an axes is projected onto NaN, so the
% points that are actually drawn are the finite ones.

n = 0;
for i = 1:numel(h)
  if ~isgraphics(h(i)) || ~ismember(h(i),allchild(ax)), continue; end
  if isprop(h(i),'Vertices')
    xy = h(i).Vertices;
  else
    xy = [h(i).XData(:), h(i).YData(:)];
  end
  n = n + sum(all(~isnan(xy),2));
end

end

% =========================================================================
function ax = gcmChildren

mtexFig = gcm;
ax = mtexFig.children;

end

% =========================================================================
function cleanup(oldVis)
close all
set(0,'DefaultFigureVisible',oldVis);
end
