classdef scaleBar < handle
% Inserts a scale bar on the current ebsd or grain map.
%
% Syntax
%   hg = scaleBar(ebsd, scanunits)
%
% Input
%  ebsd      - an mtex ebsd or grain object
%  scanunits - units of the xy coordinates of the ebsd scan (e.g., 'um')
%
% Output
%  oval  - output value 
%  ounit - output unit
%
% Options
%  BACKGROUNDCOLOR - background color (ColorSpec)
%  BACKGROUNDALPHA - background transparency (scalar 0<=a<=1)

%
% Example
%  Use a scale bar on the aachen mtexdata.
%
%   mtexdata aachen
%   plot(ebsd)
%   scaleBar(ebsd,'um','BackgroundColor','k','LineColor','w', ...
%                 'Border','off','BackgroundAlpha',0.6,'Location','nw')
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
%
% Revision History
%  2012.07.17 EJP - First version submitted for mtex commit. 
%  2012.07.27 EJP - Added option for specifying scale bar lengths.

properties (Hidden = true)
  hgt %
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
  % border          = 'off ' % controls whether the box has a border ('on', 'off')
  % borderWidth     = 2      % width of border (scalar)
  % location        = 'sw'   % location of the scale bar ('nw,'ne','sw','se', or [x,y] coordinate vector (len(vector)==2)
end


properties (Dependent = true)
  visible
end

  
methods

  function sB = scaleBar(mP,scanUnit,varargin)
    
    sB.scanUnit = scanUnit;
    sB.hgt = hgtransform('parent',mP.ax);
    sB.shadow = patch('parent',sB.hgt,'Faces',1,'Vertices',[NaN NaN NaN]);
    sB.txt = text('parent',sB.hgt,'string','1mm','position',[NaN,NaN],...
      'Interpreter',getMTEXpref('textInterpreter'),'FontSize',getMTEXpref('FontSize'));
    sB.ruler = patch('parent',sB.hgt,'Faces',1,'Vertices',[NaN NaN NaN]);
    
    % set resize function
    hax = handle(mP.ax);
    try      
      hListener(1) = handle.listener(hax, findprop(hax, 'Position'), ...
        'PropertyPostSet',@(a,b) sB.update);
      % save listener, otherwise  callback may die
      setappdata(hax, 'updatePos', hListener);
    catch
      if ~isappdata(hax, 'updatePos')
        hListener = addlistener(hax,'Position','PostSet',...
          @(obj,events) sB.update);
        setappdata(hax, 'updatePos', hListener);
      end
    end  

    try
      addlistener(sB,'length','PostSet', @(x,y) sB.update);
      addlistener(sB,'scanUnit','PostSet', @(x,y) sB.update);
      addlistener(sB,'lineColor','PostSet', @(x,y) sB.update);
      addlistener(sB,'backgroundColor','PostSet', @(x,y) sB.update);
      addlistener(sB,'backgroundAlpha','PostSet', @(x,y) sB.update);
      %addlistener(sB,'location','PostSet', @(x,y) sB.update);
      %addlistener(sB,'borderWidth','PostSet', @(x,y) sB.update);
      %addlistener(sB,'border','PostSet', @(x,y) sB.update);
    end
    
  end

  function setOnTop(sB)
    uistack(sB.hgt,'top')
  end
  
  
  function set.visible(sB,value)
    set(sB.hgt,'visible',value);
  end
  
  function value = get.visible(sB)
    value = get(sB.hgt,'visible');
  end
  
  function update(sB)
    
    % get axes orientation
    ax = get(sB.hgt,'parent');
    [el,az] = view(ax);
    xDir = mod((-1)^(az<0) * round(el / 90),4); % E-S-W-N is 0 1 2 3
    yDir = mod(xDir - round(az / 90),4); % E-S-W-N is 0 1 2 3
    
    % get extend
    dx = xlim(ax); dy = ylim(ax);
    if any(xDir == [1,2]), dx= fliplr(dx); end
    if any(yDir == [1,2]), dy= fliplr(dy); end
    if mod(xDir,2), [dx,dy] = deal(dy,dx); end
        
    % Find the range in meters for later determination of magnitude
    % We do this so that we never display 10000 nm and always something like
    % 10 microns. Also, the correct choice of units will avoid decimals.
    [sBLength, sBUnit, factor] = switchUnit(0.1*abs(diff(dx)), sB.scanUnit);
    if strcmpi(sBUnit,'um'), sBUnit = '$\mu$m';end
    
    % we would like to have SBlength beeing a nice number
    if isnan(sB.length)
      goodValues = [1 2 5 10 15 20 25 50 75 100 125 150 200 500 750]; % Possible values for scale bar length
      [~,ind] = min(abs(sBLength-goodValues));
      sB.length = goodValues(ind);
    end
    rulerLength = sB.length * factor * sign(diff(dx));

    % A gap around the bar of 1% of bar length looks nice
    set(sB.txt,'position',[dx(1),dy(1)])
    textHeight = get(sB.txt, 'Extent');
    textHeight = min(textHeight(3:4)) * sign(diff(dy));
    gapY = textHeight/3;
    gapX = abs(gapY) * sign(diff(dx));

    % Box position
    boxWidth = rulerLength + 2.0 * gapX;
    boxx = dx(1) + gapX;
    boxy = dy(1) + gapY;
    
    % Make bounding box. The z-coordinate is used to put the box under the
    % line.
    verts = [boxx, boxy;
      boxx, boxy +  3*gapY + textHeight;
      boxx + boxWidth, boxy + 3*gapY + textHeight;
      boxx + boxWidth, boxy];
    set(sB.shadow,'Vertices', cP(verts), ...
      'Faces', [1 2 3 4], ...
      'FaceColor', sB.backgroundColor , 'EdgeColor', 'none', ...
      'LineWidth', 1, 'FaceAlpha', sB.backgroundAlpha);
    
    % update text
    set(sB.txt,'string',['\rm{\textbf{' num2str(sB.length) ' ' sBUnit '}}'],...
      'HorizontalAlignment', 'Center',...
      'VerticalAlignment', 'baseline','color',sB.lineColor,...
      'Position', cP([boxx+boxWidth/2,boxy+3*gapY]));

    % Create line as a patch. The z-coordinate is used to layer the patch over
    % top of the bounding box.
    set(sB.ruler,'Vertices',cP([boxx+gapX, boxy+gapY; ...
      boxx + gapX, boxy+2*gapY; ...
      boxx + gapX + rulerLength, boxy + 2*gapY; ...
      boxx + gapX + rulerLength, boxy + gapY]), ...
      'Faces',[1 2 3 4], 'FaceColor',sB.lineColor, 'FaceAlpha',1);
        
    sB.setOnTop;
    
    function pos = cP(pos)
      % interchange x and y if needed
      if mod(xDir,2), pos(:,[1,2]) = pos(:,[2,1]); end      
    end
    
  end
     
end
  
end

