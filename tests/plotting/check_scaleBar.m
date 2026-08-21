function check_scaleBar
% check the scale bar and its reference frame indicator
%
% Verifies that
%
% * the indicator points where the plotting convention says it does
% * everything drawn stays inside the background box and clear of the bar
% * a direction along the viewing axis gets the circled symbol, all others
%   an arrow
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
% where [0 0] is the axis along the view, and the symbol expected for it
cases = { ...
  'y↑→x', [1 0; 0 1; 0 0], 'dot'; ...
  'y↓→x', [1 0; 0 -1; 0 0], 'cross'; ...  % plottingConvention.ij
  'x←↑y', [-1 0; 0 1; 0 0], 'cross'; ...
  'x↑→y', [0 1; 1 0; 0 0], 'cross'};

for k = 1:size(cases,1)

  conv = cases{k,1};
  expected = cases{k,2};
  symbol = cases{k,3};

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

      % this direction is along the viewing axis, hence it is the one drawn
      % as a circled dot / circled cross
      if all(isnan(sB.rfSymbol.XData))
        error(['check_scaleBar: %s - no circled symbol although %s is ' ...
          'along the viewing axis'], conv, sB.rfLabels(j).String);
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

  % out of the screen adds the filled dot to the arrows, into the screen
  % adds the two diagonals of the cross to the polyline of the circle
  nFaces = nArrows + strcmp(symbol,'dot');
  if size(sB.rfArrows.Faces,1) ~= nFaces
    error('check_scaleBar: %s - %d filled faces, expected %d',...
      conv, size(sB.rfArrows.Faces,1), nFaces);
  end
  if sum(isnan(sB.rfSymbol.XData)) ~= 2*strcmp(symbol,'cross')
    error('check_scaleBar: %s - the circled symbol is not a %s', conv, symbol);
  end

  % the whole indicator has to stay within the background box ...
  box = sB.shadow.Vertices;
  inside(sB.rfArrows.Vertices, box, ['the arrows, ' conv]);
  inside([sB.rfSymbol.XData(:), sB.rfSymbol.YData(:)], box, ['the symbol, ' conv]);
  inside(vertcat(sB.rfLabels.Position), box, ['the labels, ' conv]);

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

% a view no axis is aligned with: all three directions become arrows and
% there is no circled symbol at all
pC = plottingConvention; pC.outOfScreen = vector3d(0.4,0.3,1);
plottingConvention.default(pC);
plot(ebsd);
drawnow
sB = getappdata(gca,'mapPlot').micronBar;
if ~all(isnan(sB.rfSymbol.XData)) || size(sB.rfArrows.Faces,1) ~= 3
  error(['check_scaleBar: a tilted view should draw three arrows and no ' ...
    'circled symbol, got %d faces'], size(sB.rfArrows.Faces,1));
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
wOff = abs(sB.shadow.Vertices(3,1) - sB.shadow.Vertices(1,1));

% ... i.e. twice the height of its own label, as before the indicator was introduced
if abs(2*abs(sB.txt.Extent(4)) - hOff) > 0.03*hOff
  error('check_scaleBar: ''refFrame'',''off'' box is %g high, expected %g',...
    hOff, 2*abs(sB.txt.Extent(4)));
end
close all

% with the indicator the box has to be taller, and never narrower
plot(ebsd);
drawnow
sB = getappdata(gca,'mapPlot').micronBar;
hOn = abs(sB.shadow.Vertices(2,2) - sB.shadow.Vertices(1,2));
wOn = abs(sB.shadow.Vertices(3,1) - sB.shadow.Vertices(1,1));
if hOn <= hOff || wOn < wOff - 1e-6*wOff
  error('check_scaleBar: the indicator did not make the box grow (%gx%g vs %gx%g)',...
    wOn, hOn, wOff, hOff);
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
% the origin the indicator is drawn around - the center of the circled
% symbol if there is one, otherwise the point all arrows emanate from

if ~all(isnan(sB.rfSymbol.XData))
  o = [(min(sB.rfSymbol.XData) + max(sB.rfSymbol.XData))/2, ...
    (min(sB.rfSymbol.YData) + max(sB.rfSymbol.YData))/2];
else
  V = sB.rfArrows.Vertices;
  o = [(min(V(:,1)) + max(V(:,1)))/2, (min(V(:,2)) + max(V(:,2)))/2];
end

end

function inside(P, box, what)
% all points of P have to lie within the axis aligned hull of box

P(any(isnan(P),2),:) = [];
if isempty(P), return; end

lo = min(box,[],1); hi = max(box,[],1);
tol = 1e-9 * max(hi-lo);

if any(P(:,1) < lo(1)-tol) || any(P(:,1) > hi(1)+tol) || ...
    any(P(:,2) < lo(2)-tol) || any(P(:,2) > hi(2)+tol)
  error('check_scaleBar: %s reaches outside of [%g %g] x [%g %g]',...
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
