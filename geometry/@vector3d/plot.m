function varargout = plot(v,varargin)
% plot vectors as two dimensional projections on the sphere
%
% Syntax
%   plot(v)
%   plot(v,value)
%   plot(v,rgb)
%   plot(v,'MarkerSize',10)
%   plot(v,'contourf')
%   plot(v,'contour')
%
% Input
%   v - @vector3d
%   value - values to be displayed
%   rgb - 
%
% Options
%  Marker           - 'square', 'triangle', 'o','diamond' 
%  MarkerSize       -
%  MarkerFaceColor  -
%  MarkerEdgeColor  -
%
% Flags
%  smooth   - plot point cloud as colored density
%  contourf - plot point cloud as filled contours
%  contour  - plot point cloud as contours
%

% maybe we should add this do all subplots
if check_option(varargin,'add2all')
  mtexFig = gcm;
  if isempty(gcm)
    ax = gca;
  else
    ax = mtexFig.children;
  end
  ax = get_option(varargin,'parent',ax);
  varargin = delete_option(varargin,'parent',1);
  varargin = delete_option(varargin,'add2all');
  
  h = [];
  for i = 1:length(ax)
    h = [h,plot(v,varargin{:},'parent',ax(i),'doNotDraw')]; %#ok<AGROW>
  end
  
  if nargout >=1, varargout{1} = h; end
  if nargout >=2, varargout{2} = ax; end
  
  return
end


% extract plot type
plotTypes = {'contour','contourf','smooth','scatter','text','quiver',...
  'line','plane','circle','surf','pcolor','custom','3d','scatter3d'};
plotType = get_flag(varargin,plotTypes);

% default plot type
if isempty(plotType)
  if isOption(v,'plot') && v.opt.plot
  
    if ~isempty(varargin) && isnumeric(varargin{1}) && all(size(varargin{1}) == [length(v),3])      
      plotType = 'surf';
    else
      plotType = 'smooth';
    end
    
  else
    plotType = 'scatter';
  end
end
varargin = delete_option(varargin,plotTypes(3:end));

% if data is vector3d type is quiver
if ~isempty(varargin) && isa(varargin{1},'vector3d')
  plotType = 'quiver';
end

if any(strcmpi(plotType,{'smooth','contourf','contour','pcolor'}))
  varargin = ensureData(varargin);
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
end

function v = ensureData(v)
  if ~isempty(v) && ~isnumeric(v{1}) 
    v = [{[]},v];
  end
end
