function quiver(v, d, varargin )
%
% Syntax
%   quiver(v,d)
%
% Input
%  v - @vector3d
%  d - @vector3d  
%
% Options
%  arrowSize     - length of the arrow
%  autoArrowSize - automatically determine the length of the arrow
%  MaxHeadSize   - size of the head
%
% Output
%
% See also

% initialize spherical plot
sP = newSphericalPlot(v,varargin{:});

for j = 1:numel(sP)

  % project data
  [x,y] = project(sP(j).proj,v,varargin{:});
  x = x(:); y = y(:);

  % make the quiver plot

  mhs = get_option(varargin,'MaxHeadSize',0.9*d.antipodal);
  arrowSize = get_option(varargin,'arrowSize',0.03);

  proj = sP(j).proj;
  proj.sR = sphericalRegion;
  [dx,dy] = project(proj,d,'removeAntipodal');
  
  dx = reshape(abs(arrowSize)*dx,size(x));
  dy = reshape(abs(arrowSize)*dy,size(x));

  if ~check_option(varargin,'autoArrowSize')
    arrowSize = 0;
  end
  
  optiondraw(quiver(x,y,dx,dy,arrowSize,'MaxHeadSize',mhs,'parent',sP(j).ax),varargin{:});
  
  if mhs == 0 % no head -> extend into opposite direction
    hold(sP(j).ax,'on')
    optiondraw(quiver(x,y,-dx,-dy,arrowSize,'MaxHeadSize',0,'parent',sP(j).ax),varargin{:});
    hold(sP(j).ax,'off')
  end

  % finalize the plot

  % add annotations
  sP(j).plotAnnotate(varargin{:})

  %set(ax,'DataAspectRatio',[1 1 1])
  %set(ax,'PlotBoxAspectRatio',[1 1 1])
end
