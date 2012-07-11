function varargout = plot(v,varargin)
% plot three dimensional vector
%
%
%% Options
%  Marker          
%  MarkerSize
%  MarkerFaceColor
%  MarkerEdgeColor
%
%% Flags
%  smooth   - plot point cloud as colored density
%  contourf - plot point cloud as filled contours
%  contour  - plot point cloud as contours

% new plot if needed
if ~ishandle(v), newMTEXplot;end

% where to plot
[ax,v,varargin] = getAxHandle(v,varargin{:});

% extract plot type
plotTypes = {'smooth','scatter','text','contour','contourf','quiver','line','plane','circle'};
plotType = extract_option(varargin,plotTypes);
if isempty_cell(plotType)
  plotType = 'scatter';
else
  plotType = plotType{end};
end
varargin = delete_option(varargin,plotTypes);

% if data is vector3d type is quiver
if ~isempty(varargin) && isa(varargin{1},'vector3d')
  plotType = 'quiver';
end

% call plotting routine according to type
switch lower(plotType)

  case 'scatter'
  
    [varargout{1:nargout}] = scatter(ax,v,varargin{:});
    
  case 'smooth'
    
    [varargout{1:nargout}] = smooth(ax,v,varargin{:});
    
  case 'contourf'
    
    [varargout{1:nargout}] = contourf(ax,v,varargin{:});
    
  case 'contour'
    
    [varargout{1:nargout}] = contour(ax,v,varargin{:});
    
  case 'quiver'
    
    [varargout{1:nargout}] = quiver(ax,v,varargin{:});
    
  case 'line'
    
    [varargout{1:nargout}] = line(ax,v,varargin{:});
    
  case 'circle'
    
    [varargout{1:nargout}] = circle(ax,v,varargin{:});
    
  case 'plane'
    
    [varargout{1:nargout}] = circle(ax,v,90*degree,varargin{:});
    
end

if check_option(varargin,{'text','label','labeled'})
  washold = ishold;
  hold all
  [varargout{1:nargout}] = text(ax,v,get_option(varargin,{'text','label'}),varargin{:});
  if ~washold, hold off;end
end
