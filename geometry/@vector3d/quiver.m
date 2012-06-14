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
[ax,v,varargin] = getAxHandle(v,varargin{:});

% extract plot options
projection = getProjection(ax,v,varargin{:});

% project data
[x,y,hemi,p] = project(v,projection); %#ok<ASGLU>
x = x(:); y = y(:);

%% make the quiver plot

mhs = get_option(varargin,'MaxHeadSize',0.9);
arrowSize = get_option(varargin,'arrowSize',0.2);

[dx,dy] = project(d,projection);
  
dx = reshape(abs(arrowSize)*dx,size(x));
dy = reshape(abs(arrowSize)*dy,size(x));

if ~check_option(varargin,'autoArrowSize')
  arrowSize = 0;
end
  
optiondraw(quiver(x,y,dx,dy,arrowSize,'MaxHeadSize',mhs),varargin{:});
  
if mhs == 0 % no head -> extend into opposite direction
  hold on
  optiondraw(quiver(x,y,-dx,-dy,arrowSize,'MaxHeadSize',0),varargin{:});
  hold off
end

%% finalize the plot

% plot a spherical grid
plotGrid(ax,projection,varargin{:});

% add annotations
plotAnnotate(ax,varargin{:})

% output
if nargout > 0
  varargout{1} = ax;
  varargout{2} = h;
else
  m = 0.025;
  set(ax,'units','normalized','position',[0+m 0+m 1-2*m 1-2*m]);
end

