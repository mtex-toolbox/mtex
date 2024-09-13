classdef mapPlot < handle
  % class to handle spatial plots of EBSD data and grains
  
  properties    
    ax        % the axes that contain the map
    parent    % the figure that contains the map plot
    micronBar % 
    extent = [inf -inf inf -inf]   %
    how2plot = plottingConvention % the plotting convention
  end
  
  properties (Dependent = true)

  end
  
  methods
    
    function mP = mapPlot(ax,varargin)
  
      if nargin == 0, return;end
      
      % maybe there is already a map plot
      if isappdata(ax,'mapPlot') && ishold(ax)
        mP = getappdata(ax,'mapPlot');
        return
      end
        
      if ax.Type == "polaraxes", 
        delete(ax);
        ax = axes;
      end
      cla(ax,'reset'), rmallappdata(ax);

      mP.ax = ax;
      mP.parent = get(ax,'parent');      
      
      % general settings
      axis(ax,'equal','tight','on');
      
      set(ax,'TickDir','out',...
        'XMinorTick','off',...
        'YMinorTick','off',...
        'ZMinorTick','off',...
        'XTickLabel',{},...
        'yTickLabel',{},...
        'zTickLabel',{},...
        'Layer','top',...
        'box','on','FontSize',getMTEXpref('FontSize'));
      grid(ax,'off');
      
      mP.how2plot = getClass(varargin,'plottingConvention',getMTEXpref('xyzPlotting'));
      mP.how2plot.setView;
      setappdata(ax,'mapPlot',mP);
      
      % set zoom function
      try
        h = zoom(mP.ax);

        if isempty(get(h,'ActionPostCallback'))
          set(h,'ActionPostCallback',@(e,v) resizeCanvas(e,v,mP));
        end
      catch %#ok<CTCH>
      end
      
      % coordinates
      showCoordinates = get_option(varargin,'coordinates',getMTEXpref('showCoordinates'));
      if strcmpi(showCoordinates,'on')
        set(ax,'xtickLabelMode','auto','ytickLabelMode','auto','ZTickLabelMode','auto');
        xlabel(ax,'x')
        ylabel(ax,'y')
        zlabel(ax,'z')
      else
        set(ax,'tickLength',[0,0]);
        xlabel(ax,'x','visible','off')
        ylabel(ax,'y','visible','off')
        zlabel(ax,'z','visible','off')
      end
      
      % add a micron bar
      mP.micronBar = scaleBar(mP,get_option(varargin,'scanUnit','um'));
      onOff = {'off','on'};            
      vis = get_option(varargin,'micronbar',getMTEXpref('showMicronBar'));
      if islogical(vis)
        mP.micronBar.visible = onOff{1+vis};
      else
        mP.micronBar.visible = vis;
      end

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
ey_r = diff(mP.extent(1:2))/diff(mP.extent(3:4));

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
  if y(1) < mP.extent(3)
    y(2) = min(mP.extent(4),y(2)+mP.extent(3)-y(1));
    y(1) = mP.extent(3);
  elseif y(2) > mP.extent(4)
    y(1) = max(mP.extent(3),y(1)+mP.extent(4)-y(2));
    y(2) = mP.extent(4);
  end

  % set the new limit
  if ~any(isinf(x)), ylim(mP.ax,y); end
  
else % resize xlim
  
  % new xlim = ylim * are_ratio
  dx = dy * ay_r - dx;

  % extend xlim to both sides
  x = cx(1:2) + [-1 1] * dx./2;

  % may be a shift is necessary
  if x(1) < mP.extent(1)
    x(2) = min(mP.extent(2),x(2)+mP.extent(1)-x(1));
    x(1) = mP.extent(1);
  elseif x(2) > mP.extent(2)
    x(1) = max(mP.extent(1),x(1)+mP.extent(2)-x(2));
    x(2) = mP.extent(2);
  end

  % set the new limit
  if ~any(isinf(x)), xlim(mP.ax,x); end
  
end

% restore units
set(mP.parent,'units',old_fig_units);
set(mP.ax,'units',old_ax_units);

% update micronbar
mP.micronBar.update;

end

