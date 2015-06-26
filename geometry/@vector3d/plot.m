function varargout = plot(v,varargin)
% plot three dimensional vector
%
%
% Options
%  Marker          
%  MarkerSize
%  MarkerFaceColor
%  MarkerEdgeColor
%
% Flags
%  smooth   - plot point cloud as colored density
%  contourf - plot point cloud as filled contours
%  contour  - plot point cloud as contours

% extract plot type
plotTypes = {'contour','contourf','smooth','scatter','text','quiver',...
  'line','plane','circle','surf','pcolor','custom','3d','scatter3d'};
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

% call plotting routine according to type
switch lower(plotType)

  case '3d'    
    if v.isOption('plot')
      [varargout{1:nargout}] = v.plot3d(varargin{:});
    else
      [varargout{1:nargout}] = v.scatter3d(varargin{:});
    end
    
  case 'scatter3d'
    
    [varargout{1:nargout}] = v.plot3d(varargin{:});
  
  case 'scatter'
  
    [varargout{1:nargout}] = v.scatter(varargin{:});
    
  case 'smooth'
    
    [varargout{1:nargout}] = v.smooth(varargin{:});
    
  case 'surf'
    
    [varargout{1:nargout}] = v.surf(varargin{:});
            
  case 'contourf'
    
    [varargout{1:nargout}] = v.contourf(varargin{:});
    
  case 'contour'
    
    [varargout{1:nargout}] = v.contour(varargin{:});
    
  case 'pcolor'
    
    [varargout{1:nargout}] = v.pcolor(varargin{:});
    
  case 'quiver'
    
    [varargout{1:nargout}] = v.quiver(varargin{:});
    
  case 'line'
    
    [varargout{1:nargout}] = v.line(varargin{:});
    
  case 'circle'
    
    [varargout{1:nargout}] = v.circle(varargin{:});
    
  case 'plane'
    
    [varargout{1:nargout}] = v.circle(90*degree,varargin{:});
    
  case 'text'
    
    [varargout{1:nargout}] = v.text(varargin{:});
    
  case 'custom'
      
    [varargout{1:nargout}] = v.plotCustom(varargin{:});      
    
end
