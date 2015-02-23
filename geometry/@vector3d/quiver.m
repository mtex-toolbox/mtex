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

  holdState = get(sP(j).ax,'nextPlot');
  set(sP(j).ax,'nextPlot','add');
  
  % project data
  [x,y] = project(sP(j).proj,v,varargin{:});
  x = x(:); y = y(:);

  % make the quiver plot

  mhs = get_option(varargin,'MaxHeadSize',0.9*(1-d.antipodal));
  arrowSize = get_option(varargin,'arrowSize',0.05);

  proj = sP(j).proj;
  proj.sR = sphericalRegion;
  [dx,dy] = project(proj,d,'removeAntipodal');
  
  dx = reshape(abs(arrowSize)*dx,size(x));
  dy = reshape(abs(arrowSize)*dy,size(x));

  if ~check_option(varargin,'autoArrowSize')
    arrowSize = 0;
  end
    
  options = {arrowSize,'MaxHeadSize',mhs,'parent',sP(j).ax};
  
  if mhs == 0 % no head -> extend into opposite direction  
    optiondraw(quiver(x-dx,y-dy,2*dx,2*dy,options{:}),varargin{:});    
  else
    optiondraw(quiver(x,y,dx,dy,options{:}),varargin{:});
  end

  % finalize the plot

  % add annotations
  sP(j).plotAnnotate(varargin{:})
  set(sP(j).ax,'nextPlot',holdState);
end
