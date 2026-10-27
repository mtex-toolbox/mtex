function check_scaleBar
% check the scale bar and its reference frame indicator
%
% Verifies that
%
% * the indicator points where the plotting convention says it does
% * everything drawn stays inside the background box and clear of the bar
% * a direction along the viewing axis is named at the crossing of the
%   arrows, all others get an arrow, nothing is circled
% * with the indicator the bar is no wider than the indicator
% * 'refFrame','off' reproduces the geometry of a bar without indicator
% * the bar stays in front of content with a z extent, e.g. crystal shapes
%   plotted on top of the map
%

oldVis = get(0,'DefaultFigureVisible');
set(0,'DefaultFigureVisible','off');
cleanUp = onCleanup(@() cleanup(oldVis)); %#ok<NASGU>

% note the functional form - inside a function mtexdata would assign to the
% base workspace instead
ebsd = mtexdata('small');
ebsd = ebsd('indexed');

% the axis aligned conventions, the screen direction (right, up) of x, y and z,
% where [0 0] is the axis along the view
cases = { ...
  'y↑→x', [1 0; 0 1; 0 0]; ...
  'y↓→x', [1 0; 0 -1; 0 0]; ...  % plottingConvention.ij
  'x←↑y', [-1 0; 0 1; 0 0]; ...
  'x↑→y', [0 1; 1 0; 0 0]};

for k = 1:size(cases,1)

  conv = cases{k,1};
  expected = cases{k,2};

  plottingConvention.default(conv);
  plot(ebsd);
  drawnow
  sB = getappdata(gca,'mapPlot').micronBar;

  % the label positions are data coordinates - project them back onto the
  % screen to compare them against the convention
  pC = plottingConvention.getView(gca);
  origin = commonRoot(sB);

  nArrows = 0;
  for j = 1:3

    p = sB.rfLabels(j).Position(1:2) - origin;
    v = vector3d(p(1),p(2),0);
    onScreen = [dot(v,pC.east,'noAntipodal'), dot(v,pC.north,'noAntipodal')];

    if all(expected(j,:) == 0)

      % this direction is along the viewing axis, hence named at the crossing
      if norm(onScreen) > 0.05 * norm(sB.rfLabels(1).Extent(3:4))
        error(['check_scaleBar: %s - %s is along the viewing axis but sits ' ...
          '[%.2g %.2g] off the crossing'], conv, sB.rfLabels(j).String, onScreen);
      end

    else

      nArrows = nArrows + 1;
      if dot(onScreen./norm(onScreen), expected(j,:)) < cos(20*degree)
        error(['check_scaleBar: %s - the label %s sits at [%.2f %.2f] on ' ...
          'screen, expected [%d %d]'], conv, sB.rfLabels(j).String, ...
          onScreen./norm(onScreen), expected(j,:));
      end

    end
  end

  % one filled face per arrow, and nothing circled
  if size(sB.rfArrows.Faces,1) ~= nArrows || ~all(isnan(sB.rfSymbol.XData))
    error('check_scaleBar: %s - %d filled faces and a symbol, expected %d arrows only',...
      conv, size(sB.rfArrows.Faces,1), nArrows);
  end

  % the whole indicator has to stay within the background box ...
  box = sB.shadow.Vertices;
  inside(sB.rfArrows.Vertices, box, ['the arrows, ' conv]);
  inside(vertcat(sB.rfLabels.Position), box, ['the labels, ' conv]);

  % ... the bar is no wider than the indicator ...
  ink = [sB.rfArrows.Vertices(:,1:2); labelCorners(sB.rfLabels)];
  bar = max(max(sB.ruler.Vertices(:,1:2)) - min(sB.ruler.Vertices(:,1:2)));
  wide = max(max(ink) - min(ink));
  if bar > wide * (1 + 1e-6)
    error('check_scaleBar: %s - the bar is %g long, the indicator only %g wide', ...
      conv, bar, wide);
  end

  % ... and clear of the bar itself
  if overlaps(sB.rfArrows.Vertices, sB.ruler.Vertices)
    error('check_scaleBar: %s - the indicator overlaps the bar', conv);
  end

  close all
end

% the bar is positioned from the axes limits and must not contribute to them
plottingConvention.default('y↑→x');
plot(ebsd,'micronbar','off');
drawnow
limNoBar = [xlim(gca) ylim(gca)];
close all
plot(ebsd);
drawnow
limBar = [xlim(gca) ylim(gca)];
if ~all(abs(limBar - limNoBar) <= 1e-9*max(abs(limNoBar)))
  error(['check_scaleBar: the bar changed the axes limits from %s to %s - ' ...
    'it must not take part in the limit computation'],...
    mat2str(limNoBar,6), mat2str(limBar,6));
end
close all

% #2576: the bar is laid out in data coordinates, so its corner is decided on screen
for conv = {'y↑→x','y↓→x','x←↑y','x↑→y'}

  plottingConvention.default(conv{1});

  for loc = {'sw','se','nw','ne'}

    plot(ebsd,'Location',loc{1});
    drawnow
    ax = gca;
    sB = getappdata(ax,'mapPlot').micronBar;
    pC = plottingConvention.getView(ax);

    xl = xlim(ax); yl = ylim(ax);
    off = vector3d(mean(sB.shadow.XData) - mean(xl), ...
      mean(sB.shadow.YData) - mean(yl), 0);
    east  = dot(off,pC.east, 'noAntipodal') / (0.5*diff(xl));
    north = dot(off,pC.north,'noAntipodal') / (0.5*diff(yl));

    wanted = [2*startsWith(loc{1},'n')-1, 2*endsWith(loc{1},'e')-1];
    if sign(north) ~= wanted(1) || sign(east) ~= wanted(2)
      error(['check_scaleBar: %s, ''Location'',''%s'' - the bar sits at ' ...
        'east %+.2f north %+.2f on screen, i.e. in the wrong corner'], ...
        conv{1}, loc{1}, east, north);
    end

    % and it reads left to right on screen whatever the map does, rather
    % than turning with it - the label stays upright either way
    V = sB.ruler.Vertices;
    [~,~,W] = svd(V - mean(V,1),0);
    along = vector3d(W(1,1),W(2,1),0);
    if abs(dot(along,pC.east,'noAntipodal')) < cos(5*degree) || sB.txt.Rotation ~= 0
      error(['check_scaleBar: %s - the bar runs at east %+.2f north %+.2f ' ...
        'on screen with the label rotated %g degree'], conv{1}, ...
        dot(along,pC.east,'noAntipodal'), dot(along,pC.north,'noAntipodal'), ...
        sB.txt.Rotation);
    end

    close all
  end
end

% a view no axis is aligned with: all three directions become arrows
pC = plottingConvention; pC.outOfScreen = vector3d(0.4,0.3,1);
plottingConvention.default(pC);
plot(ebsd);
drawnow
sB = getappdata(gca,'mapPlot').micronBar;
if ~all(isnan(sB.rfSymbol.XData)) || size(sB.rfArrows.Faces,1) ~= 3
  error(['check_scaleBar: a tilted view should draw three arrows, ' ...
    'got %d faces'], size(sB.rfArrows.Faces,1));
end
inside(sB.rfArrows.Vertices, sB.shadow.Vertices, 'the arrows, tilted view');
close all

% switching the indicator off has to restore the bare bar
plottingConvention.default('y↑→x');
plot(ebsd,'refFrame','off');
drawnow
sB = getappdata(gca,'mapPlot').micronBar;
if ~isequaln(sB.rfArrows.Vertices,[NaN NaN]) || ~isequaln(sB.rfSymbol.XData,NaN) ...
    || ~all(cellfun(@isempty,{sB.rfLabels.String}))
  error('check_scaleBar: ''refFrame'',''off'' still draws the indicator');
end
hOff = abs(sB.shadow.Vertices(2,2) - sB.shadow.Vertices(1,2));

% ... i.e. twice the height of its own label, as before the indicator was introduced
if abs(2*abs(sB.txt.Extent(4)) - hOff) > 0.03*hOff
  error('check_scaleBar: ''refFrame'',''off'' box is %g high, expected %g',...
    hOff, 2*abs(sB.txt.Extent(4)));
end
close all

% with the indicator the box has to be taller
plot(ebsd);
drawnow
sB = getappdata(gca,'mapPlot').micronBar;
hOn = abs(sB.shadow.Vertices(2,2) - sB.shadow.Vertices(1,2));
if hOn <= hOff
  error('check_scaleBar: the indicator did not make the box taller (%g vs %g)', hOn, hOff);
end
% a flat map stays a two dimensional, child order drawn axes
if ~strcmp(get(gca,'SortMethod'),'childorder') || ...
    size(sB.shadow.Vertices,2) > 2 || ~isempty(sB.rfSymbol.ZData)
  error('check_scaleBar: a flat map was turned into a depth sorted 3d axes');
end
close all

% content with a z extent makes MATLAB sort by depth, the bar has to follow
plottingConvention.default('y↓→x');
grains = calcGrains(ebsd,'threshold',10*degree);
biggest = grains(grains.numPixel == max(grains.numPixel));
plot(ebsd);
hold on
plot(biggest, crystalShape(Miller({1,0,0},{0,1,0},{0,0,1},biggest.CS)))
hold off
drawnow
ax = gca;
sB = getappdata(ax,'mapPlot').micronBar;

% an axes showing nothing but a flat map keeps the default z limits [-1 1]
if diff(zlim(ax)) <= 2
  error('check_scaleBar: the crystal shape did not give the axes a z extent');
end
planes(sB, ax, 'with crystal shapes')
close all

disp('check_scaleBar: ok')

end

% ------------------------------------------------------------------------

function planes(sB, ax, what)
% Once the axes is depth sorted the bar has to be drawn in the plane closest
% to the camera, so that content with a z extent cannot bury it, and its
% translucent background just behind that plane - coplanar with the rest
% MATLAB composites the transparent box over the opaque bar and arrows and
% dims them.

dz = zlim(ax);
toCam = ax.CameraPosition(3) - ax.CameraTarget(3);
zNear = dz(1 + (toCam > 0));

labels = vertcat(sB.rfLabels.Position);
z = [sB.ruler.Vertices(:,3); sB.rfArrows.Vertices(:,3); sB.rfSymbol.ZData(:); ...
  sB.txt.Position(3); labels(:,3)];
z(isnan(z)) = [];

if any(abs(z - zNear) > 1e-9*abs(diff(dz)))
  error(['check_scaleBar: %s - the bar is drawn at z = %g..%g instead of ' ...
    'the near plane z = %g'], what, min(z), max(z), zNear);
end

zBox = unique(sB.shadow.Vertices(:,3));
behind = (zNear - zBox) * sign(toCam);
if ~isscalar(zBox) || behind <= 0 || behind > 0.01*abs(diff(dz))
  error(['check_scaleBar: %s - the background box is not just behind the ' ...
    'bar (box at z = %g, bar at z = %g)'], what, zBox(1), zNear);
end

end

function o = commonRoot(sB)
% the crossing the arrows leave from - where the lines through the first
% two arrows meet, each running from the middle of its base to its tip

V = sB.rfArrows.Vertices(:,1:2); F = sB.rfArrows.Faces;
p = (V(F(1:2,1),:) + V(F(1:2,7),:)) / 2;
d = V(F(1:2,4),:) - p;
ab = [d(1,:).', -d(2,:).'] \ (p(2,:) - p(1,:)).';
o = p(1,:) + ab(1) * d(1,:);

end

function P = labelCorners(labels)
% the corners of the labels' extents

e = vertcat(labels(~cellfun(@isempty,{labels.String})).Extent);
P = [e(:,1:2); e(:,1:2) + e(:,3:4)];

end

function inside(P, box, what)
% all points of P have to lie within the axis aligned hull of box

P(any(isnan(P),2),:) = [];
if isempty(P), return; end

lo = min(box,[],1); hi = max(box,[],1);
tol = 1e-9 * max(hi-lo);

if any(P(:,1) < lo(1)-tol) || any(P(:,1) > hi(1)+tol) || ...
    any(P(:,2) < lo(2)-tol) || any(P(:,2) > hi(2)+tol)
  error('check_scaleBar: %s reaches outside of [%g %g] × [%g %g]',...
    what, lo(1), hi(1), lo(2), hi(2));
end

end

function out = overlaps(P, Q)
% do the axis aligned bounding boxes of P and Q overlap?

P(any(isnan(P),2),:) = []; Q(any(isnan(Q),2),:) = [];
if isempty(P) || isempty(Q), out = false; return; end

out = min(P(:,1)) < max(Q(:,1)) && max(P(:,1)) > min(Q(:,1)) && ...
  min(P(:,2)) < max(Q(:,2)) && max(P(:,2)) > min(Q(:,2));

end

function cleanup(oldVis)
close all
set(0,'DefaultFigureVisible',oldVis);
end
