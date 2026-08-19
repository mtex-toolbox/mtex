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
% via <plottingConvention.getView.html plottingConvention.getView> and
% realigns itself whenever the map is reoriented, e.g. via
% <plottingConvention.setView.html plottingConvention.setView> or one of
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

    % the reference frame indicator - the arrows and the filled dot of the
    % out of screen symbol share one patch (they are all filled with
    % lineColor), the circle and the cross of that symbol are one polyline
    sB.rfArrows = patch('parent',sB.hgt,'Faces',1,'Vertices',[NaN NaN],...
      'EdgeColor','none');
    sB.rfSymbol = line('parent',sB.hgt,'XData',NaN,'YData',NaN,'LineWidth',1);
    sB.rfLabels = gobjects(1,3);
    for k = 1:3
      sB.rfLabels(k) = text('parent',sB.hgt,'string','','position',[NaN,NaN],...
        'Interpreter',getMTEXpref('textInterpreter'),'FontSize',getMTEXpref('FontSize'));
    end

    % The scale bar is an annotation that happens to be drawn in data
    % coordinates: it is positioned *from* the axes limits and must never
    % contribute to them. Otherwise an 'axis tight' - EBSD/plot.m does one
    % after the map is drawn - picks up whatever position the bar was last
    % laid out for. On a fresh axes that is the corner of the default
    % [0 1] limits, so the map extent gets dragged all the way down to the
    % origin; the bar then follows the enlarged limits and the map ends up
    % squeezed into a corner of a far too large axes.
    set([sB.shadow, sB.txt, sB.ruler, sB.rfArrows, sB.rfSymbol, sB.rfLabels],...
      'XLimInclude','off','YLimInclude','off','ZLimInclude','off');

    % the labels of the reference frame indicator default to the axes
    % names of the frame the data lives in - a rolling framed map shows
    % RD, TD, ND - or of the session default frame for frame-free data
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

    % redraw whenever the axes is resized, zoomed/panned or reoriented
    % (e.g. through plottingConvention.setView). Position alone is not a
    % reliable proxy for a changed map width (e.g. 'axis equal' can keep
    % Position fixed across a zoom, or change it without XLim/YLim
    % changing), so XLim/YLim are watched explicitly. ZLim matters as well,
    % since the bar is laid out in the plane closest to the camera (see
    % update) - note though that this only covers limits that are set
    % explicitly, see setOnTop for the rest.
    % A Position change alters the axes' pixel geometry, which the label
    % measurement depends on even when the data limits are unchanged - so
    % it forces a fresh layout past the memo in update.
    hax = mP.ax;
    hListener(1) = addlistener(hax,'Position',      'PostSet', @(~,~) sB.update(true));
    hListener(2) = addlistener(hax,'CameraPosition','PostSet', @(~,~) sB.update);
    hListener(3) = addlistener(hax,'CameraUpVector','PostSet', @(~,~) sB.update);
    hListener(4) = addlistener(hax,'XLim',          'PostSet', @(~,~) sB.update);
    hListener(5) = addlistener(hax,'YLim',          'PostSet', @(~,~) sB.update);
    hListener(6) = addlistener(hax,'ZLim',          'PostSet', @(~,~) sB.update);

    % Position does not cover every way the pixel geometry can change: a
    % uiaxes laid out by a uigridlayout - the import wizard's tabs - is
    % given its size without its Position ever being written, so a bar laid
    % out while the axes was still at the default 400x300 would keep those
    % (data unit) sizes and blow up to several times the intended size as
    % soon as the layout ran. MarkedClean fires after every render of the
    % axes, whatever caused it, and is the one signal that is always there;
    % checkGeometry makes it cheap by only re-laying out when the label's
    % footprint actually moved.
    hListener(7) = addlistener(hax,'MarkedClean',    @(~,~) sB.checkGeometry);

    % Tie these axes-level listeners' lifetime directly to this scale
    % bar's own graphics, rather than to garbage collection of the
    % variable above: mapPlot.m clears the axes' appdata (via
    % rmallappdata) *before* constructing the next scale bar, so a
    % listener stored only in appdata can never be found and deleted by
    % the following scale bar's constructor. An app that repeatedly
    % cla's/replots the same axes (e.g. the import wizard) can then fire a
    % CameraPosition/CameraUpVector change while the old, now-unreferenced
    % listener is still alive (garbage collection is not immediate), which
    % calls back into the already-deleted old scale bar and errors.
    % Deleting the listeners the moment sB.hgt itself is destroyed (e.g.
    % by cla) is immediate and needs no appdata bookkeeping at all.
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

    % forceLayout skips the memo below - used by the Position listener,
    % since a changed pixel geometry invalidates the label measurement
    % without any of the memoized inputs changing
    if nargin < 2, forceLayout = false; end

    % belt-and-braces: a listener attached to the axes can outlive the
    % scale bar it belonged to (see the constructor), so bail out rather
    % than error if this instance's own graphics were already deleted
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

    % skip while the camera is only half updated: reorienting an axes takes
    % several property assignments (see plottingConvention.beginCameraUpdate)
    % and the ones in between describe a viewing direction paired with an up
    % vector that does not belong to it. Laying the bar out for such a state
    % is wasted work - a single notification follows once the camera is
    % consistent again
    if isappdata(ax,'MTEXcameraUpdate'), return; end

    % the plotting convention currently active on the map - read back from
    % the axes camera itself (not from a cached plottingConvention
    % reference) so this stays correct even if setView was applied through
    % a plottingConvention object other than the one the map was
    % originally created with
    pC = plottingConvention.getView(ax);

    % determine which compass direction (E-S-W-N is 0-1-2-3) the data x-
    % and y-axis are currently pointing to on screen - cheaper and more
    % direct than the previous round trip through view(ax)'s azimuth /
    % elevation, and it is always consistent with pC since it is derived
    % from pC itself
    xDir = compassDirection(vector3d.X,pC);
    yDir = compassDirection(vector3d.Y,pC);

    % where the reference frame directions point to on screen: how far to
    % the right (column 1), how far up (column 2) and how far out of the
    % screen (column 3) - i.e. the full screen projection, not just the
    % four compass directions above, so that the indicator stays correct
    % for a tilted view as well
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

    % The bar is an annotation and must never be hidden by the map content.
    % As long as the axes draws in child order, bringing the bar to the
    % front of that list (setOnTop) is all it takes. Once something with a
    % z extent is drawn on top of the map - the crystal shapes of
    % grain2d/plot, say - MATLAB sorts by depth instead, uistack stops
    % meaning anything, and the bar has to lay itself out in the plane
    % closest to the camera to stay visible. It cannot be moved any further
    % to the front than that: the axes clips everything to its own z limits,
    % and switching clipping off for the bar does not help either, since the
    % renderer's own near plane then cuts it away. See barPlanes.
    [zBar, zBack] = barPlanes(ax);
    sB.lastZ = [zBar, zBack];

    % Find the range in meters for later determination of magnitude
    % We do this so that we never display 10000 nm and always something like
    % 10 microns. Also, the correct choice of units will avoid decimals.
    %
    % In auto mode the nice length AND its unit both come from 10% of the
    % current map width, so the bar rescales (both value and unit) as the
    % map width changes through zooming/resizing/replotting instead of
    % freezing at whatever was picked when the bar was first drawn. In
    % fixed-length mode the unit is instead derived from sB.length itself,
    % since that is a length given in scanUnit units, independent of
    % whatever the map width currently happens to be.
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

    % Skip the expensive re-layout - it includes a full drawnow to measure
    % the label - when nothing the layout depends on has changed. The
    % camera/limits listeners fire in bursts (a single setView triggers
    % several PostSet events), so most calls end here. Pixel geometry
    % changes are covered separately: the Position listener passes
    % forceLayout, so no (layout-forcing) geometry probe is needed here.
    % rfScreen has to be part of the key as well: reorienting the map by
    % less than a quarter turn changes the indicator without changing
    % xDir/yDir, so the four compass directions alone would memoize it away
    key = {xDir, yDir, dx, dy, zBar, zBack, rulerLength, labelStr, sB.lineColor, ...
      sB.backgroundColor, sB.backgroundAlpha, sB.location, ...
      rfScreen, sB.refFrameLabels};
    if ~forceLayout && isequal(key, sB.lastLayout)
      sB.setOnTop % newly plotted content may still require restacking
      return
    end
    sB.lastLayout = key;

    % Set the label and measure its footprint before laying out the box -
    % the box (and hence the bar) must be sized for the label that is
    % about to be shown, not the one left over from the previous redraw.
    %
    % The extent is measured without flushing pending layout/rendering
    % first: a drawnow here is extremely expensive on large maps (it
    % synchronously renders everything pending, possibly several times per
    % interaction). If the axes' pixel geometry is not settled yet (e.g. a
    % uiaxes inside a freshly built App Designer layout), the measured
    % extent is implausible and the fallback below kicks in; the final
    % correct layout follows automatically once the geometry settles,
    % because that fires the Position listener which forces a re-layout.
    set(sB.txt,'string',labelStr,'position',cP([dx(1),dy(1)]))
    extent = get(sB.txt, 'Extent');

    % what checkGeometry compares against - the measurement this layout is
    % about to be built on, not the fallback that may replace it below
    sB.lastExtent = extent(3:4);

    % Extent(3:4) are the text's footprint along data-x/data-y - which one
    % is the visually "wide" direction depends on whether the data axes
    % are currently swapped on screen (same flag as used by cP below)
    if mod(xDir,2)
      textWidth = extent(4); textHeight = extent(3) * sign(diff(dy));
    else
      textWidth = extent(3); textHeight = extent(4) * sign(diff(dy));
    end

    % Fall back to a size proportional to the map's own current extent -
    % rather than a fixed font-size-based guess, which would only look
    % right at whatever zoom level its absolute size happens to match -
    % whenever Extent could not be measured (NaN) or is implausible
    % (larger than a generous fraction of the map itself). The latter
    % happens when the axes has not settled on its final pixel geometry
    % yet (e.g. a uiaxes inside a freshly built App Designer layout, as in
    % the import wizard), which throws off the pixel-to-data scale behind
    % Extent; see the comment above the measurement for why this is only
    % transient.
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

    % Reference frame indicator - laid out in screen relative lengths (u to
    % the right, v upwards, both unsigned) around an origin of its own, and
    % only mapped onto the data axes further below. mapPlot sets
    % 'axis equal', so one data unit is the same screen length along both
    % axes and a single set of lengths serves both directions. Its size is
    % derived from the measured label height, hence it scales with the font
    % just like the rest of the box - including the fallback above.
    if showRF
      [rfV, rfF, rfLine, rfLabPos, rfLabStr, rfBox] = ...
        refFrameGeometry(rfScreen, sB.refFrameLabels, abs(textHeight));
      triadWidth  = rfBox(2) - rfBox(1);
      triadHeight = rfBox(4) - rfBox(3);
    else
      triadWidth = 0; triadHeight = 0;
    end

    % Box position - dx(1)/dy(1) is the screen bottom-left corner of the
    % map, dx(2)/dy(2) the top-right corner, so the requested location
    % just picks which edge(s) the box is anchored to
    %
    % The box (and with it the bar) is sized to fit whichever of the bar
    % or the label is wider, so a short bar with a long label - which
    % easily happens after zooming or reorienting the map - does not spill
    % out of the background box
    %
    % When the reference frame indicator is shown the box additionally
    % grows upwards by its height plus one gap separating it from the
    % label; with 'refFrame','off' the geometry is exactly the one without
    % the indicator
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

    % Create line as a patch, in the plane in front of the bounding box.
    % The bar is centered within the box, so it stays centered under/above
    % the label even when the label is wider than the bar itself.
    rulerStart = boxx + (boxWidth - rulerLength)/2;
    set(sB.ruler,'Vertices',cP([rulerStart, boxy+gapY; ...
      rulerStart, boxy+2*gapY; ...
      rulerStart + rulerLength, boxy + 2*gapY; ...
      rulerStart + rulerLength, boxy + gapY]), ...
      'Faces',[1 2 3 4], 'FaceColor',sB.lineColor, 'FaceAlpha',1);

    % Place the reference frame indicator: horizontally centered in the box
    % - its own bounding box, so that a two arrow indicator is not pushed
    % off center by the empty quadrants - and sitting one gap above the
    % label
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

function [V, F, L, labPos, labStr, bbox] = refFrameGeometry(rfScreen, labels, t)
% geometry of the reference frame indicator, in screen relative coordinates
% around its own origin - u to the right, v upwards, both unsigned
%
% Input
%  rfScreen - n x 3 matrix of the (right, up, outOfScreen) components
%  labels   - cell of char, one per direction
%  t        - the measured text height, used as the length unit
%
% Output
%  V, F     - vertices and faces of everything filled: the arrows and, if
%             present, the dot of the out of screen symbol. The faces
%             differ in length, hence F is NaN padded
%  L        - polyline of the circle and, for a direction pointing into the
%             screen, of the cross inside it
%  labPos   - n x 2 label positions, NaN for directions that are not drawn
%  labStr   - the labels belonging to them
%  bbox     - [minU maxU minV maxV] of everything drawn

arm       = 1.2*t;          % length of a full length arrow
shaftHalf = t/8;            % half width of the arrow shaft
headHalf  = 3*shaftHalf;    % half width of the arrow head
headLen   = 0.3*arm;
symR      = 0.32*arm;       % radius of the out of screen circle
pad       = 0.55*t;         % distance between an arrow tip and its label
% estimated half extent of a label, growing with the longest label - the
% frame axes names may be two letters, RD or X1
maxLen    = max([1,cellfun(@numel,labels)]);
labHalf   = [(0.15 + 0.25*maxLen)*t, 0.5*t];

n = size(rfScreen,1);

% a direction is drawn as an arrow as soon as it is more than about 9
% degree away from the viewing direction - closer than that its projection
% is too short to show a direction, and the circled symbol is used instead
inPlane = hypot(rfScreen(:,1),rfScreen(:,2)) >= 0.15;

V = zeros(0,2); L = zeros(0,2); faceIdx = {};
labPos = nan(n,2); labStr = repmat({''},1,n);

% the direction along the viewing axis becomes a circled dot (out of the
% screen) or a circled cross (into the screen), as in the string form of
% @plottingConvention. It is drawn first since the arrows have to start
% outside of it - otherwise they would run right through the circle and
% cover the very mark that distinguishes the two cases
kSym = find(~inPlane,1);
if isempty(kSym)
  r0 = 0;
else
  r0 = 1.3*symR;

  phi = linspace(0,2*pi,49).';
  L = symR * [cos(phi), sin(phi)];

  if rfScreen(kSym,3) > 0
    psi = linspace(0,2*pi,13).'; psi(end) = [];
    V = [V; 0.35*symR * [cos(psi), sin(psi)]];
    faceIdx{end+1} = size(V,1)-11 : size(V,1);
  else
    r = symR/sqrt(2);
    L = [L; NaN NaN; -r -r; r r; NaN NaN; -r r; r -r];
  end
end

for k = reshape(find(inPlane),1,[])

  % the arrow is shortened by the projection, so that a direction tilted
  % away from the screen plane reads as such
  d = rfScreen(k,1:2);
  len = norm(d)*arm;
  d = d ./ norm(d);
  p = [-d(2), d(1)]; % normal to the arrow

  % keep the head from swallowing a strongly foreshortened arrow
  hl = min(headLen, 0.6*len);

  V = [V; ...
    r0*d + shaftHalf*p; ...
    (r0+len-hl)*d + shaftHalf*p; ...
    (r0+len-hl)*d + headHalf*p; ...
    (r0+len)*d; ...
    (r0+len-hl)*d - headHalf*p; ...
    (r0+len-hl)*d - shaftHalf*p; ...
    r0*d - shaftHalf*p]; %#ok<AGROW>
  faceIdx{end+1} = size(V,1)-6 : size(V,1); %#ok<AGROW>

  labPos(k,:) = (r0 + len + pad)*d;
  if k <= numel(labels), labStr{k} = labels{k}; end

end

if ~isempty(kSym)

  % place the label of the circled symbol away from the arrows, so that it
  % can never sit on one
  inP = rfScreen(inPlane,1:2);
  d = -sum(inP ./ hypot(inP(:,1),inP(:,2)), 1);
  if norm(d) < 1e-6, d = [-1 -1]/sqrt(2); else, d = d ./ norm(d); end

  labPos(kSym,:) = (symR + 0.75*pad)*d;
  if kSym <= numel(labels), labStr{kSym} = labels{kSym}; end

end

if isempty(faceIdx)
  V = [NaN NaN]; F = 1;
else
  F = nan(numel(faceIdx),max(cellfun(@numel,faceIdx)));
  for k = 1:numel(faceIdx), F(k,1:numel(faceIdx{k})) = faceIdx{k}; end
end

% the tight bounding box of arrows, symbol, labels and the origin
P = [V; L; labPos - labHalf; labPos + labHalf; 0 0];
P(any(isnan(P),2),:) = [];
bbox = [min(P(:,1)), max(P(:,1)), min(P(:,2)), max(P(:,2))];

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
