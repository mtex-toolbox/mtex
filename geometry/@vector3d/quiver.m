function varargout = quiver(v, d, varargin )
%
%% Syntax
%   quiver(v,d)
%
%% Input
%  v - @vector3d
%  d - @vector3d  
%
%% Options
%  arrowSize     - length of the arrow
%  autoArrowSize - automatically determine the length of the arrow
%  MaxHeadSize   - size of the head
%
%% Output
%
%% See also

%% plot prepertations

% where to plot
[ax,v,d,varargin] = splitNorthSouth(v,d,varargin{:},'quiver');
if isempty(ax), return;end

% extract plot options
[projection,extend] = getProjection(ax,v,varargin{:});

% project data
[x,y] = project(v,projection,extend);
x = x(:); y = y(:);

%% make the quiver plot

mhs = get_option(varargin,'MaxHeadSize',0.9);
arrowSize = get_option(varargin,'arrowSize',0.03);

dextend.minTheta = 0;
dextend.maxTheta = pi;
dextend.minRho = 0;
dextend.maxRho = 2*pi;
[dx,dy] = project(d,projection,dextend,'removeAntipodal');
  
dx = reshape(abs(arrowSize)*dx,size(x));
dy = reshape(abs(arrowSize)*dy,size(x));

if ~check_option(varargin,'autoArrowSize')
  arrowSize = 0;
end
  
optiondraw(quiver(ax,x,y,dx,dy,arrowSize,'MaxHeadSize',mhs),varargin{:});
  
if mhs == 0 % no head -> extend into opposite direction
  hold(ax,'on')
  optiondraw(quiver(ax,x,y,-dx,-dy,arrowSize,'MaxHeadSize',0),varargin{:});
  hold(ax,'off')
end

%% finalize the plot

% plot a spherical grid
plotGrid(ax,projection,extend,varargin{:});

% add annotations
plotAnnotate(ax,varargin{:})

set(ax,'DataAspectRatio',[1 1 1])
set(ax,'PlotBoxAspectRatio',[1 1 1])

% output
if nargout > 0
  varargout{1} = ax;
  varargout{2} = h;
end

