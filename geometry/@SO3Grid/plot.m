function plot(SO3G,varargin)
% vizualize SO3Grid
%
%% Input
%  SO3G - @SO3Grid
%
%% Options
%  RODRIGUES    - plot in rodrigues space
%  AXISANGLE    - plot in axis angle space
%  CENTER       - reference orientation
%  

washold = ishold;

%% Three Dimensional Plot
if (ishold && strcmp(get(gca,'tag'),'ebsd_raster')) || ...
  (check_option(varargin,{'RODRIGUES','AXISANGLE','scatter'}) || sum(GridLength(SO3G)) > 50)

  for i = 1:length(SO3G)
   
    if check_option(varargin,'center')
      setappdata(gcf,'center',get_option(varargin,'center'));
    elseif ishold && isappdata(gcf,'center')
      varargin = {'center',getappdata(gcf,'center')};
    end
    
    if ~check_option(varargin,'no_projection')
      q = getFundamentalRegion(SO3G(i),varargin{:});
    else
      q = quaternion(SO3G(i));
    end
    
    plot(q,varargin{:});
    hold all
  end  

%% two dimensional plot
else

  v = [xvector,yvector,zvector];
  
  for i = 1:numel(v)

    plot(S2Grid(quaternion(SO3G).*v(i)),'dots',varargin{:});
    hold all
  end  
  
end

%% finish

% set hold back
if ~washold, hold off;end
