classdef scaleBar < handle
% Inserts a scale bar on the current ebsd or grain map.
%
% Above the bar and its label the same box also indicates how the specimen
% reference frame is aligned on screen: an arrow for every axis that has a
% component within the screen plane, and a circled dot / circled cross for
% the axis pointing out of / into the screen. This can be switched off by
% the option |'refFrame','off'| or globally by
% |setMTEXpref('showRefFrame','off')|.
%
% The scale bar reads the plotting convention back from the axes camera
% via <plottingConvention.html plottingConvention.getView> and
% realigns itself whenever the map is reoriented, e.g. via
% <plottingConvention.html plottingConvention.setView> or one of
% <plotx2north.html plotx2north>, <plotzOutOfPlane.html plotzOutOfPlane>,
% etc. - this works no matter which @plottingConvention object was used to
% apply the view, since it never relies on a cached reference to it. The
% reference frame indicator is derived from that same convention, so it
% always shows the alignment actually in effect.
%
% Syntax
%   sB = scaleBar(mP, scanUnit)
%   sB = scaleBar(mP, scanUnit, 'SBBackgroundColor', 'k', 'SBLineColor', 'w', ...
%     'SBBackgroundAlpha', 0.6, 'Location', 'nw')
%
% Input
%  mP        - the @mapPlot the scale bar is attached to
%  scanUnit  - units of the xy coordinates of the ebsd scan (e.g., 'um')
%
% Options
%  SBBackgroundColor - background color (ColorSpec)
%  SBBackgroundAlpha - background transparency (scalar 0<=a<=1)
%  SBLineColor       - border and text color (ColorSpec)
%  Length            - fixed scale bar length (in scanUnit units); if not
%                       given (default) a nice round length close to 10% of
%                       the map width is chosen automatically and kept up to
%                       date as the map is zoomed or resized
%  Location          - corner of the map the bar is drawn in:
%                       'sw' (default), 'se', 'nw', 'ne'
%  refFrame          - 'on' / 'off' - show the reference frame, defaults to
%                       the |showRefFrame| preference
%  refFrameDirs      - @vector3d, the directions to indicate
%                       (default xvector, yvector, zvector)
%  refFrameLabels    - cell of char, their labels; default are the axes
%                       names of the frame the data lives in, e.g.
%                       X1, Y1, Z1 or RD, TD, ND
%
% Example
%
%   % use a scale bar on the aachen mtexdata
%   mtexdata aachen
%   plot(ebsd,'SBBackgroundColor','k','SBLineColor','w', ...
%     'SBBackgroundAlpha',0.6,'Location','nw')
%


properties (Hidden = true)
  hgt      % handle of the hgtransform grouping the scale bar graphics
  lastLayout = {}          % memo of the inputs of the last layout (see update)
  lastZ = NaN              % the plane the bar was last laid out in (see update)
  lastExtent = []          % label footprint the last layout was measured against
  updating logical = false % re-entrance guard for update
end

properties
  txt                      % handle of the text
  shadow                   % handle of the shadow
  ruler                    % handle of the ruler
  rfArrows                 % handle of the reference frame arrows (patch)
  rfSymbol                 % handle of the out of screen symbol (line)
  rfLabels                 % handles of the reference frame labels (text)
end

properties (SetObservable)
  backgroundColor = 'k'    % background color (ColorSpec)
  backgroundAlpha = 0.6    % background transparency (scalar 0<=a<=1)
  scanUnit        = 'um'   % units of the xy coordinates of the ebsd scan (e.g., 'um')
  lineColor       = 'w'    % border color and text color (ColorSpec)
  length          = NaN    % desired scale bar length
  refFrameDirs   = vector3d.byXYZ(eye(3)) % directions of the reference frame
  refFrameLabels = {'x','y','z'}          % their labels
end

properties (SetObservable)
  location = 'sw'          % corner of the map: 'sw', 'se', 'nw', 'ne'
  refFrame = 'on'          % show the reference frame indicator: 'on', 'off'
end

properties (Dependent = true)
  visible
end


methods

  function sB = scaleBar(mP,scanUnit,varargin)

    sB.scanUnit = scanUnit;
    sB.hgt = hgtransform('parent',mP.ax);
    sB.shadow = patch('parent',sB.hgt,'Faces',1,'Vertices',[NaN NaN NaN],'EdgeColor','none');
    sB.txt = text('parent',sB.hgt,'string','1mm','position',[NaN,NaN],...
      'Interpreter',getMTEXpref('textInterpreter'),'FontSize',getMTEXpref('FontSize'));
    sB.ruler = patch('parent',sB.hgt,'Faces',1,'Vertices',[NaN NaN NaN]);

    % the reference frame indicator - all filled parts share one patch
    sB.rfArrows = patch('parent',sB.hgt,'Faces',1,'Vertices',[NaN NaN],...
      'EdgeColor','none');
    sB.rfSymbol = line('parent',sB.hgt,'XData',NaN,'YData',NaN,'LineWidth',1);
    sB.rfLabels = gobjects(1,3);
    for k = 1:3
      sB.rfLabels(k) = text('parent',sB.hgt,'string','','position',[NaN,NaN],...
        'Interpreter',getMTEXpref('textInterpreter'),'FontSize',getMTEXpref('FontSize'));
    end

    % the bar is positioned from the axes limits and must not contribute to them
    set([sB.shadow, sB.txt, sB.ruler, sB.rfArrows, sB.rfSymbol, sB.rfLabels],...
      'XLimInclude','off','YLimInclude','off','ZLimInclude','off');

    % label the indicator with the axes names of the frame the data lives in
    fr = getClass(varargin,'referenceFrame',specimenFrame.default);
    sB.refFrameLabels = fr.axesNames;

    % apply user options
    sB.backgroundColor = get_option(varargin,'SBBackgroundColor',sB.backgroundColor);
    sB.backgroundAlpha = get_option(varargin,'SBBackgroundAlpha',sB.backgroundAlpha);
    sB.lineColor       = get_option(varargin,'SBLineColor',sB.lineColor);
    sB.length          = get_option(varargin,'Length',sB.length);
    sB.location        = get_option(varargin,'Location',sB.location);
    sB.refFrameDirs    = get_option(varargin,'refFrameDirs',sB.refFrameDirs);
    sB.refFrameLabels  = get_option(varargin,'refFrameLabels',sB.refFrameLabels);
    sB.refFrame        = get_option(varargin,'refFrame',...
      getMTEXpref('showRefFrame','on'));

    % redraw whenever the axes is resized, zoomed, panned or reoriented
    hax = mP.ax;
    hListener(1) = addlistener(hax,'Position',      'PostSet', @(~,~) sB.update(true));
    hListener(2) = addlistener(hax,'CameraPosition','PostSet', @(~,~) sB.update);
    hListener(3) = addlistener(hax,'CameraUpVector','PostSet', @(~,~) sB.update);
    hListener(4) = addlistener(hax,'XLim',          'PostSet', @(~,~) sB.update);
    hListener(5) = addlistener(hax,'YLim',          'PostSet', @(~,~) sB.update);
    hListener(6) = addlistener(hax,'ZLim',          'PostSet', @(~,~) sB.update);

    % a uiaxes in a uigridlayout is sized without writing Position, so watch MarkedClean
    hListener(7) = addlistener(hax,'MarkedClean',    @(~,~) sB.checkGeometry);

    % tie the listeners to the graphics, appdata is cleared before the next scale bar
    addlistener(sB.hgt, 'ObjectBeingDestroyed', @(~,~) delete(hListener(isvalid(hListener))));

    addlistener(sB,'length',          'PostSet', @(~,~) sB.update);
    addlistener(sB,'scanUnit',        'PostSet', @(~,~) sB.update);
    addlistener(sB,'lineColor',       'PostSet', @(~,~) sB.update);
    addlistener(sB,'backgroundColor', 'PostSet', @(~,~) sB.update);
    addlistener(sB,'backgroundAlpha', 'PostSet', @(~,~) sB.update);
    addlistener(sB,'location',        'PostSet', @(~,~) sB.update);
    addlistener(sB,'refFrame',        'PostSet', @(~,~) sB.update);
    addlistener(sB,'refFrameDirs',    'PostSet', @(~,~) sB.update);
    addlistener(sB,'refFrameLabels',  'PostSet', @(~,~) sB.update);

  end

  function setOnTop(sB)
    % Bring the bar in front of everything else in the axes. The child
    % order settles ties between coplanar objects, the plane the bar is
    % drawn in settles the rest (see update) - both have to be redone
    % whenever something was plotted on top of the map.
    %
    % Call this after adding content to a map that is already there, MTEX
    % does so in EBSD/plot and grain2d/plot. It is not automatic: MATLAB
    % recomputing the z limits because new content appeared fires no
    % listener the bar could hook into (ZLim/PostSet only reacts to limits
    % that are set explicitly), so the only alternative would be to
    % recheck on every single redraw.

    try
      c = sB.hgt.Parent.Children;
      if ~isempty(c) && c(1) ~= sB.hgt
        uistack(sB.hgt,'top')
      end
    end

    % during update the bar has just been laid out for the current plane,
    % and calling back into it would recurse
    if sB.updating || isempty(sB.hgt) || ~isvalid(sB.hgt), return; end
    [z, zBack] = barPlanes(get(sB.hgt,'Parent'));
    if ~isequal([z, zBack], sB.lastZ), sB.update; end

  end

  function unlock(sB)
    sB.updating = false;
  end


  function set.visible(sB,value)
    sB.hgt.Visible = value;
  end

  function value = get.visible(sB)
    value = sB.hgt.Visible;
  end

  function set.location(sB,loc)
    aliases = struct('sw','sw','se','se','nw','nw','ne','ne',...
      'southwest','sw','southeast','se','northwest','nw','northeast','ne');
    loc = lower(loc);
    if ~isfield(aliases,loc)
      error('mtex:scaleBar:location',...
        'Unknown scale bar location "%s". Use one of sw, se, nw, ne.',loc);
    end
    sB.location = aliases.(loc);
  end

  function set.refFrame(sB,value)
    % accept the same spellings as the 'micronbar' option does
    onOff = {'off','on'};
    if islogical(value), value = onOff{1+value}; end
    value = lower(char(value));
    if ~any(strcmp(value,onOff))
      error('mtex:scaleBar:refFrame',...
        'Unknown reference frame visibility "%s". Use ''on'' or ''off''.',value);
    end
    sB.refFrame = value;
  end

  function checkGeometry(sB)
    % Called after every render of the axes (MarkedClean). The whole
    % layout is derived from how much of the map one line of the label
    % covers, so that footprint is at the same time the probe for "did the
    % axes' pixel geometry change": a resized window, an axes that just
    % got its size from a layout manager, a colorbar taking a slice off
    % it. Only its width and height are compared - the position within it
    % is what the layout moves around, and comparing that would make every
    % layout trigger the next one.
    if sB.updating || isempty(sB.hgt) || ~isvalid(sB.hgt) || ...
        isempty(sB.txt) || ~isvalid(sB.txt), return, end

    e = get(sB.txt,'Extent');
    if ~isequaln(e(3:4), sB.lastExtent), sB.update(true); end
  end

  function update(sB, forceLayout)

    % forceLayout skips the memo below, a changed pixel geometry is not part of its key
    if nargin < 2, forceLayout = false; end

    % a listener attached to the axes can outlive the scale bar it belonged to
    if isempty(sB.hgt) || ~isvalid(sB.hgt)
      return
    end

    % re-entrance guard: the drawnow further down flushes pending layout,
    % which can fire the very listeners that call this method again
    if sB.updating
      return
    end
    sB.updating = true;
    restoreGuard = onCleanup(@() sB.unlock); %#ok<NASGU>

    ax = get(sB.hgt,'Parent');

    % skip while the camera is only half updated, a notification follows
    if isappdata(ax,'MTEXcameraUpdate'), return; end

    % read the plotting convention back from the axes camera, not from a cache
    pC = plottingConvention.getView(ax);

    % which compass direction (E-S-W-N is 0-1-2-3) the data axes point to on screen
    xDir = compassDirection(vector3d.X,pC);
    yDir = compassDirection(vector3d.Y,pC);

    % the full screen projection of the reference frame directions, for a tilted view
    showRF = strcmp(sB.refFrame,'on') && ~isempty(sB.refFrameDirs);
    if showRF
      rfDir = normalize(sB.refFrameDirs(:).');
      rfScreen = [dot(rfDir,pC.east,'noAntipodal').', ...
        dot(rfDir,pC.north,'noAntipodal').', ...
        dot(rfDir,pC.outOfScreen,'noAntipodal').'];
    else
      rfScreen = [];
    end

    % get extent
    dx = xlim(ax); dy = ylim(ax);
    if any(xDir == [1,2]), dx= fliplr(dx); end
    if any(yDir == [1,2]), dy= fliplr(dy); end
    if mod(xDir,2), [dx,dy] = deal(dy,dx); end

    % lay the bar out in the plane closest to the camera, depth sorting beats uistack
    [zBar, zBack] = barPlanes(ax);
    sB.lastZ = [zBar, zBack];

    % pick the unit from 10% of the map width, so that the bar never says
    % 10000 nm - in fixed length mode take it from sB.length instead
    if isnan(sB.length)
      [sBLength, sBUnit, factor] = switchUnit(0.1*abs(diff(dx)), sB.scanUnit);
      goodValues = [1 2 5 10 15 20 25 50 75 100 125 150 200 500 750]; % Possible values for scale bar length
      [~,ind] = min(abs(sBLength-goodValues));
      barLength = goodValues(ind);
    else
      [barLength, sBUnit, factor] = switchUnit(sB.length, sB.scanUnit);
    end
    if strcmpi(sBUnit,'um'), sBUnit = '$\mu$m';end
    rulerLength = barLength * factor * sign(diff(dx));

    labelStr = ['\rm{\textbf{' num2str(barLength) ' ' sBUnit '}}'];

    % skip the expensive re-layout when none of its inputs changed
    key = {xDir, yDir, dx, dy, zBar, zBack, rulerLength, labelStr, sB.lineColor, ...
      sB.backgroundColor, sB.backgroundAlpha, sB.location, ...
      rfScreen, sB.refFrameLabels};
    if ~forceLayout && isequal(key, sB.lastLayout)
      sB.setOnTop % newly plotted content may still require restacking
      return
    end
    sB.lastLayout = key;

    % measure the label that is about to be shown, but without a drawnow
    set(sB.txt,'string',labelStr,'position',cP([dx(1),dy(1)]))
    extent = get(sB.txt, 'Extent');

    % what checkGeometry compares against - the measurement this layout is
    % about to be built on, not the fallback that may replace it below
    sB.lastExtent = extent(3:4);

    % Extent(3:4) is the footprint along data x and y, which may be swapped on screen
    if mod(xDir,2)
      textWidth = extent(4); textHeight = extent(3) * sign(diff(dy));
    else
      textWidth = extent(3); textHeight = extent(4) * sign(diff(dy));
    end

    % fall back to a size proportional to the map when the extent is not measurable
    bogus = isnan(textHeight) || isnan(textWidth) || ...
      abs(textHeight) > 0.4*abs(diff(dy)) || abs(textWidth) > 0.9*abs(diff(dx));
    if bogus
      textWidth = 0;
      textHeight = 0.05 * abs(diff(dy)) * sign(diff(dy));
    end
    gapY = textHeight/3;
    gapX = abs(gapY) * sign(diff(dx));

    % screen orientation of the data axes, as signs
    sX = sign(diff(dx)); sY = sign(diff(dy));

    % the indicator is laid out in screen relative lengths around its own origin
    if showRF
      [rfV, rfF, rfLine, rfLabPos, rfLabStr, rfBox] = ...
        refFrameGeometry(rfScreen, sB.refFrameLabels, abs(textHeight));
      triadWidth  = rfBox(2) - rfBox(1);
      triadHeight = rfBox(4) - rfBox(3);
    else
      triadWidth = 0; triadHeight = 0;
    end

    % box position - the location picks which corner of the map the box is
    % anchored to, and it is sized to fit whichever of bar or label is wider
    boxWidth  = (max([abs(rulerLength),textWidth,triadWidth]) + 2*abs(gapX)) * sign(diff(dx));
    if showRF
      boxHeight = 4*gapY + textHeight + triadHeight * sY;
    else
      boxHeight = 3*gapY + textHeight;
    end

    if any(strcmp(sB.location,{'sw','nw'}))
      boxx = dx(1) + gapX;
    else
      boxx = dx(2) - gapX - boxWidth;
    end

    if any(strcmp(sB.location,{'sw','se'}))
      boxy = dy(1) + gapY;
    else
      boxy = dy(2) - gapY - boxHeight;
    end

    % Make bounding box. It goes into the plane behind the bar, which is
    % what puts it underneath everything else drawn here - see nearPlane.
    verts = [boxx, boxy;
      boxx, boxy + boxHeight;
      boxx + boxWidth, boxy + boxHeight;
      boxx + boxWidth, boxy];
    set(sB.shadow,'Vertices', cP(verts,zBack), ...
      'Faces', [1 2 3 4], ...
      'FaceColor', sB.backgroundColor , 'EdgeColor', 'none', ...
      'LineWidth', 1, 'FaceAlpha', sB.backgroundAlpha);

    % update text (string and position were already set above to measure
    % its extent)
    set(sB.txt,...
      'HorizontalAlignment', 'Center',...
      'VerticalAlignment', 'baseline','color',sB.lineColor,...
      'Position', cP([boxx+boxWidth/2,boxy+3*gapY]));

    % create line as a patch, centered in the box, in front of the bounding box
    rulerStart = boxx + (boxWidth - rulerLength)/2;
    set(sB.ruler,'Vertices',cP([rulerStart, boxy+gapY; ...
      rulerStart, boxy+2*gapY; ...
      rulerStart + rulerLength, boxy + 2*gapY; ...
      rulerStart + rulerLength, boxy + gapY]), ...
      'Faces',[1 2 3 4], 'FaceColor',sB.lineColor, 'FaceAlpha',1);

    % place the indicator centered in its own bounding box, one gap above the label
    if showRF

      originU = boxx + boxWidth/2 - (rfBox(1) + rfBox(2))/2 * sX;
      originV = boxy + 4*gapY + textHeight - rfBox(3) * sY;

      set(sB.rfArrows,'Vertices',mapRF(rfV),'Faces',rfF,...
        'FaceColor',sB.lineColor,'EdgeColor','none','FaceAlpha',1);

      symXY = mapRF(rfLine);
      if isempty(symXY), symXY = NaN(1,size(symXY,2)); end
      set(sB.rfSymbol,'XData',symXY(:,1),'YData',symXY(:,2),...
        'ZData',symXY(:,3:end),'Color',sB.lineColor);

      labXY = mapRF(rfLabPos);
      for k = 1:numel(sB.rfLabels)
        if k <= size(labXY,1)
          set(sB.rfLabels(k),'String',rfLabStr{k},'Position',labXY(k,:),...
            'HorizontalAlignment','center','VerticalAlignment','middle',...
            'Color',sB.lineColor);
        else
          set(sB.rfLabels(k),'String','','Position',[NaN,NaN]);
        end
      end

    else
      set(sB.rfArrows,'Faces',1,'Vertices',cP([NaN NaN]));
      set(sB.rfSymbol,'XData',NaN,'YData',NaN,'ZData',zBar);
      set(sB.rfLabels,'String','','Position',[NaN,NaN]);
    end

    sB.setOnTop;

    function pos = cP(pos,z)
      % interchange x and y if needed and, in a depth sorted axes, lift into
      % the plane of the bar - or into the one just behind it, for the
      % translucent background
      if mod(xDir,2), pos(:,[1,2]) = pos(:,[2,1]); end
      if nargin < 2, z = zBar; end
      if ~isempty(z), pos(:,3) = z; end
    end

    function pos = mapRF(pos)
      % from screen relative indicator coordinates to data coordinates
      pos = cP([originU + pos(:,1)*sX, originV + pos(:,2)*sY]);
    end

  end

end

end

function [z, zBack] = barPlanes(ax)
% The planes the scale bar is laid out in - both empty as long as the axes
% draws in child order, which is the case for a plain flat map.
%
% Then the bar needs no z coordinate at all: MATLAB draws the children in
% order, so the background box, created first, ends up behind the bar and
% the arrows all by itself. Giving the bar a z coordinate in that situation
% would do active harm - it makes the axes three dimensional, MATLAB
% switches SortMethod from 'childorder' to 'depth', and from then on the
% whole map is rendered by depth. Among other things the box, being
% transparent, is then composited over the opaque bar and arrows lying at
% the same depth and dims them.
%
% Once the axes really is depth sorted - because something with a z extent
% was plotted on top of the map, crystal shapes say - child order no longer
% decides anything and the bar has to place itself in depth:
%
%  z     - the end of the z axis closest to the camera, so that nothing can
%          be drawn in front of the bar. Read from the camera rather than
%          from the plotting convention, since it is the camera that
%          decides the depth order.
%  zBack - just behind it, for the translucent background box, which has to
%          be separated from the opaque graphics it sits behind for the
%          reason above. One thousandth of the z range is enough for the
%          depth buffer to tell the two planes apart, and little enough
%          that nothing else fits in between.

if strcmp(ax.SortMethod,'childorder')
  z = []; zBack = [];
  return
end

dz = zlim(ax);
if ax.CameraPosition(3) > ax.CameraTarget(3)
  z = dz(2); zBack = z - 1e-3*diff(dz);
else
  z = dz(1); zBack = z + 1e-3*diff(dz);
end

end

function d = compassDirection(v,pC)
% which compass direction a data direction v currently points to on
% screen, given the plotting convention pC - E-S-W-N is 0-1-2-3

if dot(v,pC.east) > 0.5
  d = 0; % East
elseif dot(v,pC.east) < -0.5
  d = 2; % West
elseif dot(v,pC.north) > 0.5
  d = 3; % North
else
  d = 1; % South
end

end
