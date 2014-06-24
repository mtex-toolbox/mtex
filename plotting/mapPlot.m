classdef mapPlot < handle
  % class to handle spatial plots of EBSD data and grains
  
  properties    
    ax        %
    parent    % the figure that contains the spherical plot
    micronbar %
    extend = [inf -inf inf -inf]   %
  end
  
  properties (Dependent = true)

  end
  
  methods
    
    function mP = mapPlot(ax,varargin)
  
      if nargin == 0, return;end
      
      % maybe there is already a map plot
      if isappdata(ax,'mapPlot') && ~ishold(ax)
        mP = getappdata(ax,'mapPlot');
        return
      end
      
      mP.ax = ax;
      mP.parent = get(ax,'parent');
      
      % general settings
      set(ax,'TickDir','out',...
        'XMinorTick','on',...
        'YMinorTick','on',...
        'Layer','top',...
        'box','on');
      grid(ax,'off');
      axis(ax,'equal','tight');
      
      setCamera(varargin{:});
      
      setappdata(ax,'mapPlot',mP);
      
      % set zoom function
      try
        h = zoom(mP.ax);

        if isempty(get(h,'ActionPostCallback'))
          set(h,'ActionPostCallback',@(e,v) resizeCanvas(e,v,mP));
        end
      catch %#ok<CTCH>
      end
      
    end
    
    function datacursormode
      
      % set data cursor
      dcm_obj = datacursormode(gcf);
      set(dcm_obj,'SnapToDataVertex','off')
      set(dcm_obj,'UpdateFcn',{@tooltip,ebsd});
      
    end
  end
end

% function for zooming
function resizeCanvas(e,v,mP) %#ok<*INUSL>
% this function changes the axis size while zooming such that it covers as
% much as possible space inside the figure

% restore old camera setting
setCamera(mP.ax);

% do everything for pixels
old_fig_units = get(mP.parent,'units');
old_ax_units = get(mP.ax,'units');
set(mP.parent,'units','pixels');
set(mP.ax ,'units','pixels');

% get the available space
pos = get(mP.ax,'position');

% x/y ratios of available space
ax_r = pos(4)/ pos(3);
ay_r = pos(3)/ pos(4);

% x/y rations of of maximum xlim  / ylim
ey_r = diff(mP.extend(1:2))/diff(mP.extend(3:4));

% current xlim  / ylim
cx = [xlim(mP.ax) ylim(mP.ax)];
dx = diff(cx(1:2));
dy = diff(cx(3:4));

% correct for xAxisDirection
if find(get(mP.ax,'CameraUpVector'))==1, [ax_r,ay_r] = deal(ay_r,ax_r); end

if ay_r < ey_r % resize ylim

  % new ylim = xlim * are_ratio
  dy = dx * ax_r - dy;

  % extend xlim to both sides
  y = cx(3:4) + [-1 1] * dy./2;

  % may be a shift is necessary
  if y(1) < mP.extend(3)
    y(2) = min(mP.extend(4),y(2)+mP.extend(3)-y(1));
    y(1) = mP.extend(3);
  elseif y(2) > mP.extend(4)
    y(1) = max(mP.extend(3),y(1)+mP.extend(4)-y(2));
    y(2) = mP.extend(4);
  end

  % set the new limit
  ylim(mP.ax,y)


else % resize xlim
  
  % new xlim = ylim * are_ratio
  dx = dy * ay_r - dx;

  % extend xlim to both sides
  x = cx(1:2) + [-1 1] * dx./2;

  % may be a shift is necessary
  if x(1) < mP.extend(1)
    x(2) = min(mP.extend(2),x(2)+mP.extend(1)-x(1));
    x(1) = mP.extend(1);
  elseif x(2) > mP.extend(2)
    x(1) = max(mP.extend(1),x(1)+mP.extend(2)-x(2));
    x(2) = mP.extend(2);
  end

  % set the new limit
  xlim(mP.ax,x);
end

% restore units
set(mP.parent,'units',old_fig_units);
set(mP.ax,'units',old_ax_units);

end

% ----------------------------------------------------------------------
% Tooltip function
function txt = tooltip(empt,eventdata,ebsd) %#ok<INUSL>


[pos,value] = getDataCursorPos(gcf);
[sub,map] = findByLocation(ebsd,[pos(1) pos(2)]);

if ~isempty(sub)

  txt{1} = ['#'  num2str(find(map))];
  txt{2} = ['Phase: ', sub.mineral];
  if ~isNotIndexed(sub)
    txt{3} = ['Orientation: ' char(sub.rotations,'nodegree')];
  end
  if ~isempty(value)
    txt{3} = ['Value: ' xnum2str(value)];
  end
else
  txt = 'no data';
end

end
