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

%% where to plot
[ax,v,varargin] = getAxHandle(v,varargin{:});




%% extract plot type
plotTypes = {'contour','contourf','smooth','scatter','text','quiver','line','plane','circle','surf','pcolor','patchPatala'};
plotType = extract_option(varargin,plotTypes);
if isempty_cell(plotType)
  plotType = 'scatter';
else
  plotType = plotType{end};
end
varargin = delete_option(varargin,plotTypes(3:end));

% if data is vector3d type is quiver
if ~isempty(varargin) && isa(varargin{1},'vector3d')
  plotType = 'quiver';
end

% remove label option
labelopt = varargin;
varargin = delete_option(varargin,{'text','label','labeled'});


%% call plotting routine according to type
switch lower(plotType)

  case 'scatter'
  
    [varargout{1:nargout}] = scatter(ax{:},v,varargin{:});
    
  case 'smooth'
    
    [varargout{1:nargout}] = smooth(ax{:},v,varargin{:});
    
  case 'surf'
    
    [varargout{1:nargout}] = surf(ax{:},v,varargin{:});
  
  case 'patchpatala'
        
    [varargout{1:nargout}] = patchPatala(ax{:},v,varargin{:});
        
  case 'contourf'
    
    [varargout{1:nargout}] = contourf(ax{:},v,varargin{:});
    
  case 'contour'
    
    [varargout{1:nargout}] = contour(ax{:},v,varargin{:});
    
  case 'pcolor'
    
    [varargout{1:nargout}] = pcolor(ax{:},v,varargin{:});
    
  case 'quiver'
    
    [varargout{1:nargout}] = quiver(ax{:},v,varargin{:});
    
  case 'line'
    
    [varargout{1:nargout}] = line(ax{:},v,varargin{:});
    
  case 'circle'
    
    [varargout{1:nargout}] = circle(ax{:},v,varargin{:});
    
  case 'plane'
    
    [varargout{1:nargout}] = circle(ax{:},v,90*degree,varargin{:});
    
  case 'text'
    
    [varargout{1:nargout}] = text(ax{:},v,varargin{:});
    
end

%% plot labels

if check_option(labelopt,{'text','label','labeled'})
  washold = getHoldState(ax{:});
  hold(ax{:},'all');
  text(ax{:},v,get_option(labelopt,{'text','label'}),labelopt{:});
  hold(ax{:},washold);
  
  % call resize callback to make positioning of the labels right
  fn = get(gcf,'ResizeFcn');
  if ~isempty(fn), fn(gcf,[]);end
end
