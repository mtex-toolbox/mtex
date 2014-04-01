function plot(v,varargin)
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
  'line','plane','circle','surf','pcolor','custom','PatchPatala','3d','scatter3d'};
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
      v.plot3d(varargin{:});
    else
      v.scatter3d(varargin{:});
    end
    
  case 'scatter3d'
    
    v.plot3d(varargin{:});
  
  case 'scatter'
  
    v.scatter(varargin{:});
    
  case 'smooth'
    
    v.smooth(varargin{:});
    
  case 'surf'
    
    v.surf(varargin{:});
  
  case 'patchpatala'
        
    v.patchPatala(varargin{:});
        
  case 'contourf'
    
    v.contourf(varargin{:});
    
  case 'contour'
    
    v.contour(varargin{:});
    
  case 'pcolor'
    
    v.pcolor(varargin{:});
    
  case 'quiver'
    
    v.quiver(varargin{:});
    
  case 'line'
    
    v.line(varargin{:});
    
  case 'circle'
    
    v.circle(varargin{:});
    
  case 'plane'
    
    v.circle(90*degree,varargin{:});
    
  case 'text'
    
    v.text(varargin{:});
    
  case 'custom'
      
    v.plotCustom(varargin{:});      
    
end
