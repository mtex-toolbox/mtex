function h = quiver(v, d, varargin )
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
opt = delete_option(varargin,{'lineStyle','lineColor','lineWidth','color'});
sP = newSphericalPlot(v,opt{:},'doNotDraw');

v = vector3d(v);
if length(d) == length(v), d = reshape(d,size(v)); end
d = d.orthProj(v);

for j = 1:numel(sP)

  holdState = get(sP(j).ax,'nextPlot');
  set(sP(j).ax,'nextPlot','add');
  
  % make the quiver plot
  mhs = get_option(varargin,'MaxHeadSize',0.9*(1-d.antipodal));
  arrowSize = get_option(varargin,'arrowSize',0.05/max(norm(d(:))));
  
  % project data
  if check_option(varargin,'centered') || mhs == 0
    [x0,y0] = project(sP(j).proj,normalize(v - abs(arrowSize) * d),'removeAntipodal',varargin{:});
    [x1,y1] = project(sP(j).proj,normalize(v + abs(arrowSize) * d),'removeAntipodal',varargin{:});
  else
    [x0,y0] = project(sP(j).proj,normalize(v),'removeAntipodal',varargin{:});
    [x1,y1] = project(sP(j).proj,normalize(v + 2*abs(arrowSize) * d),'removeAntipodal',varargin{:});
  end

  if ~check_option(varargin,'autoArrowSize')
    arrowSize = 0;
  end
  
  varargin = delete_option(varargin,'parent');
  h(j) = optiondraw(quiver(x0,y0,x1-x0,y1-y0,arrowSize,'MaxHeadSize',mhs,'parent',sP(j).hgt),varargin{:});     %#ok<AGROW>
  
  % finalize the plot
  % add annotations
  sP(j).plotAnnotate(varargin{:})
  set(sP(j).ax,'nextPlot',holdState);
end

if strcmpi(holdState,'replace') && isappdata(sP(1).parent,'mtexFig')
  mtexFig = getappdata(sP(1).parent,'mtexFig');
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
end

if nargout == 0, clear('h'); end
