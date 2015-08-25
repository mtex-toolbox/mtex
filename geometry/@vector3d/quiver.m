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

v = vector3d(v);
if length(d) == length(v), d = reshape(d,size(v)); end
d = d.orthProj(v);

for j = 1:numel(sP)

  holdState = get(sP(j).ax,'nextPlot');
  set(sP(j).ax,'nextPlot','add');
  
  % make the quiver plot
  mhs = get_option(varargin,'MaxHeadSize',0.9*(1-d.antipodal));
  arrowSize = get_option(varargin,'arrowSize',0.05);
  
  % project data  
  [x0,y0] = project(sP(j).proj,normalize(v - abs(arrowSize) * d),varargin{:});
  [x1,y1] = project(sP(j).proj,normalize(v + abs(arrowSize) * d),varargin{:});

  if ~check_option(varargin,'autoArrowSize')
    arrowSize = 0;
  end
  
  options = {arrowSize,'MaxHeadSize',mhs,'parent',sP(j).ax};
  
  optiondraw(quiver(x0,y0,x1-x0,y1-y0,options{:}),varargin{:});    
  

  % finalize the plot

  % add annotations
  sP(j).plotAnnotate(varargin{:})
  set(sP(j).ax,'nextPlot',holdState);
end
