function varargout = plot(o,varargin)
% plot function
%
%% Input
%  o - @orientation
%
%% Options
%  RODRIGUES - plot in rodrigues space
%  AXISANGLE - plot in axis / angle
%
%% See also
% orientation/scatter Plotting

newMTEXplot;

if ~(ishold && strcmp(get(gca,'tag'),'ebsd_raster')) && ...
    ~check_option(varargin,{'scatter','rodrigues','axisangle'})

  washold = ishold;
  hold all
  for i = 1:numel(o)
    
    h = [Miller(1,0,0),Miller(0,1,0),Miller(0,0,1)];
    plot(subsref(o,i) * h,'label',...
      char(h,getpref('mtex','textInterpreter'),'cell'),...
      varargin{:});
  end
  
  if ~washold, hold off;end
    
else % scatter plot
  
  scatter(o,varargin{:});
  
end
