classdef scaleBar < handle
% Inserts a scale bar on the current ebsd or grain map.
%
% Syntax
%   sB = scaleBar(mP, scanUnit)
%   sB = scaleBar(mP, scanUnit, 'BackgroundColor', 'k', 'LineColor', 'w', ...
%     'BackgroundAlpha', 0.6, 'Location', 'nw')
%
% Input
%  mP        - the @mapPlot the scale bar is attached to
%  scanUnit  - units of the xy coordinates of the ebsd scan (e.g., 'um')
%
% Options
%  BackgroundColor - background color (ColorSpec)
%  BackgroundAlpha - background transparency (scalar 0<=a<=1)
%  LineColor       - border and text color (ColorSpec)
%  Length          - fixed scale bar length (in scanUnit units); if not
%                     given (default) a nice round length close to 10% of
%                     the map width is chosen automatically and kept up to
%                     date as the map is zoomed or resized
%  Location        - corner of the map the bar is drawn in:
%                     'sw' (default), 'se', 'nw', 'ne'
%
% Example
%  Use a scale bar on the aachen mtexdata.
%
%   mtexdata aachen
%   plot(ebsd,'BackgroundColor','k','LineColor','w', ...
%                 'BackgroundAlpha',0.6,'Location','nw')
%
% Note
%  The scale bar reads the plotting convention back from the axes camera
%  via <plottingConvention.getView.html plottingConvention.getView> and
%  realigns itself whenever the map is reoriented, e.g. via
%  <plottingConvention.setView.html plottingConvention.setView> or one of
%  <plotx2north.html plotx2north>, <plotzOutOfPlane.html plotzOutOfPlane>,
%  etc. - this works no matter which @plottingConvention object was used to
%  apply the view, since it never relies on a cached reference to it.
%
% Bugs/Issues
%  [1] Using the hardware OpenGL renderer can sometimes cause the text not
%  to appear on the scale bar. This can usually be fixed by adding the line
%
%   opengl software
%
%  _Before_ the call to scaleBar().
%
%  [2] The font and the bounding box do not scale with the figure window.
%  Therefore, the desired figure window size needs to be set before the
%  call to scaleBar().
%
% Authors
%  Eric Payton, eric.payton@bam.de
%  Philippe Pinard, pinard@gfe.rwth-aachen.de

properties (Hidden = true)
  hgt      % handle of the hgtransform grouping the scale bar graphics
end

properties
  txt                      % handle of the text
  shadow                   % handle of the shadow
  ruler                    % handle of the ruler
end

properties (SetObservable)
  backgroundColor = 'k'    % background color (ColorSpec)
  backgroundAlpha = 0.6    % background transparency (scalar 0<=a<=1)
  scanUnit        = 'um'   % units of the xy coordinates of the ebsd scan (e.g., 'um')
  lineColor       = 'w'    % border color and text color (ColorSpec)
  length          = NaN    % desired scale bar length
end

properties (SetObservable)
  location = 'sw'          % corner of the map: 'sw', 'se', 'nw', 'ne'
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

    % apply user options
    sB.backgroundColor = get_option(varargin,'BackgroundColor',sB.backgroundColor);
    sB.backgroundAlpha = get_option(varargin,'BackgroundAlpha',sB.backgroundAlpha);
    sB.lineColor       = get_option(varargin,'LineColor',sB.lineColor);
    sB.length          = get_option(varargin,'Length',sB.length);
    sB.location        = get_option(varargin,'Location',sB.location);

    % redraw whenever the axes is resized, zoomed/panned or reoriented
    % (e.g. through plottingConvention.setView) - reuses the same appdata
    % slot as mapPlot.m so a repeated plot into the same axes replaces the
    % old listeners instead of accumulating them. Position alone is not a
    % reliable proxy for a changed map width (e.g. 'axis equal' can keep
    % Position fixed across a zoom, or change it without XLim/YLim
    % changing), so XLim/YLim are watched explicitly.
    hax = mP.ax;
    hListener(1) = addlistener(hax,'Position',      'PostSet', @(~,~) sB.update);
    hListener(2) = addlistener(hax,'CameraPosition','PostSet', @(~,~) sB.update);
    hListener(3) = addlistener(hax,'CameraUpVector','PostSet', @(~,~) sB.update);
    hListener(4) = addlistener(hax,'XLim',          'PostSet', @(~,~) sB.update);
    hListener(5) = addlistener(hax,'YLim',          'PostSet', @(~,~) sB.update);
    setappdata(hax,'updatePos',hListener);

    addlistener(sB,'length',          'PostSet', @(~,~) sB.update);
    addlistener(sB,'scanUnit',        'PostSet', @(~,~) sB.update);
    addlistener(sB,'lineColor',       'PostSet', @(~,~) sB.update);
    addlistener(sB,'backgroundColor', 'PostSet', @(~,~) sB.update);
    addlistener(sB,'backgroundAlpha', 'PostSet', @(~,~) sB.update);
    addlistener(sB,'location',        'PostSet', @(~,~) sB.update);

  end

  function setOnTop(sB)
    try
      c = sB.hgt.Parent.Children;
      if ~isempty(c) && c(1) ~= sB.hgt
        uistack(sB.hgt,'top')
      end
    end
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

  function update(sB)

    % the plotting convention currently active on the map - read back from
    % the axes camera itself (not from a cached plottingConvention
    % reference) so this stays correct even if setView was applied through
    % a plottingConvention object other than the one the map was
    % originally created with
    ax = get(sB.hgt,'Parent');
    pC = plottingConvention.getView(ax);

    % determine which compass direction (E-S-W-N is 0-1-2-3) the data x-
    % and y-axis are currently pointing to on screen - cheaper and more
    % direct than the previous round trip through view(ax)'s azimuth /
    % elevation, and it is always consistent with pC since it is derived
    % from pC itself
    xDir = compassDirection(vector3d.X,pC);
    yDir = compassDirection(vector3d.Y,pC);

    % get extent
    dx = xlim(ax); dy = ylim(ax);
    if any(xDir == [1,2]), dx= fliplr(dx); end
    if any(yDir == [1,2]), dy= fliplr(dy); end
    if mod(xDir,2), [dx,dy] = deal(dy,dx); end

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

    % Set the label and measure its footprint before laying out the box -
    % the box (and hence the bar) must be sized for the label that is
    % about to be shown, not the one left over from the previous redraw
    labelStr = ['\rm{\textbf{' num2str(barLength) ' ' sBUnit '}}'];
    set(sB.txt,'string',labelStr,'position',[dx(1),dy(1)])
    extent = get(sB.txt, 'Extent');

    % Extent(3:4) are the text's footprint along data-x/data-y - which one
    % is the visually "wide" direction depends on whether the data axes
    % are currently swapped on screen (same flag as used by cP below)
    if mod(xDir,2)
      textWidth = extent(4); textHeight = extent(3) * sign(diff(dy));
    else
      textWidth = extent(3); textHeight = extent(4) * sign(diff(dy));
    end
    if isnan(textHeight) || isnan(textWidth)
      textWidth = 0; textHeight = (5+sB.txt.FontSize) *sign(diff(dy));
    end
    gapY = textHeight/3;
    gapX = abs(gapY) * sign(diff(dx));

    % Box position - dx(1)/dy(1) is the screen bottom-left corner of the
    % map, dx(2)/dy(2) the top-right corner, so the requested location
    % just picks which edge(s) the box is anchored to
    %
    % The box (and with it the bar) is sized to fit whichever of the bar
    % or the label is wider, so a short bar with a long label - which
    % easily happens after zooming or reorienting the map - does not spill
    % out of the background box
    boxWidth  = (max(abs(rulerLength),textWidth) + 2*abs(gapX)) * sign(diff(dx));
    boxHeight = 3*gapY + textHeight;

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

    % Make bounding box. The z-coordinate is used to put the box under the
    % line.
    verts = [boxx, boxy;
      boxx, boxy + boxHeight;
      boxx + boxWidth, boxy + boxHeight;
      boxx + boxWidth, boxy];
    set(sB.shadow,'Vertices', cP(verts), ...
      'Faces', [1 2 3 4], ...
      'FaceColor', sB.backgroundColor , 'EdgeColor', 'none', ...
      'LineWidth', 1, 'FaceAlpha', sB.backgroundAlpha);

    % update text (string and position were already set above to measure
    % its extent)
    set(sB.txt,...
      'HorizontalAlignment', 'Center',...
      'VerticalAlignment', 'baseline','color',sB.lineColor,...
      'Position', cP([boxx+boxWidth/2,boxy+3*gapY]));

    % Create line as a patch. The z-coordinate is used to layer the patch over
    % top of the bounding box. The bar is centered within the box, so it
    % stays centered under/above the label even when the label is wider
    % than the bar itself.
    rulerStart = boxx + (boxWidth - rulerLength)/2;
    set(sB.ruler,'Vertices',cP([rulerStart, boxy+gapY; ...
      rulerStart, boxy+2*gapY; ...
      rulerStart + rulerLength, boxy + 2*gapY; ...
      rulerStart + rulerLength, boxy + gapY]), ...
      'Faces',[1 2 3 4], 'FaceColor',sB.lineColor, 'FaceAlpha',1);

    sB.setOnTop;

    function pos = cP(pos)
      % interchange x and y if needed
      if mod(xDir,2), pos(:,[1,2]) = pos(:,[2,1]); end
    end

  end

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
