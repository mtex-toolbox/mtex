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

% where to plot
[ax,v,varargin] = getAxHandle(v,varargin{:});

% extract plot type
plotType = extract_option(varargin,{'smooth','scatter','text','contour','contourf','quiver'});
if isempty_cell(plotType)
  plotType = 'scatter';
else
  plotType = plotType{end};
end

% special option -> labeled
if check_option(varargin,'labeled')
  s = cell(1,numel(v));
  for i = 1:numel(v), s{i} = subsref(v,i); end
  varargin = {'MarkerEdgeColor','w','MarkerFaceColor','k','Marker','s','label',s,varargin{:}};
  c = colormap;
  if ~all(equal(c,2)), varargin = {'BackGroundColor','w',varargin{:}};end
end
  
% call plotting routine according to type
switch plotType

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

if check_option(varargin,{'text','label'})
  hold all
  [varargout{1:nargout}] = text(ax,v,get_option(varargin,{'text','label'}),varargin{:});
  hold off
end
