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
plotType = extract_option(varargin,{'smooth','scatter','text','contour','contourf','quiver'});
if isempty_cell(plotType)
  plotType = 'scatter';
else
  plotType = plotType{end};
end

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
    
end

if check_option(varargin,{'text','label','labeled'})
  hold all
  [varargout{1:nargout}] = text(ax,v,get_option(varargin,{'text','label'}),varargin{:});
  hold off
end
