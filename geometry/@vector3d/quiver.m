function h = quiver(v, d, varargin )
%
% Description
% plots the tangential part of a vector field
%
% Syntax
%   quiver(v,d)
%
% Input
%  v - @vector3d
%  d - @vector3d  
%
% Options
%  arrowSize     - length of the arrows
%  autoArrowSize - automatically determine the length of the arrows
%  MaxHeadSize   - size of the head
%
% Output
%
% See also

% initialize spherical plot
opt = delete_option(varargin,{'lineStyle','lineColor','lineWidth','color'},1);
sP = newSphericalPlot(v,opt{:},'doNotDraw');

v = vector3d(v);
if length(d) == length(v), d = reshape(d,size(v)); end

mhs = get_option(varargin,'MaxHeadSize',0.9*(1-d.antipodal));
maxD = max(1e-10,max(reshape(norm(d),[],1)));
scale = 0.01 / maxD;
d = d.orthProj(v);
  
res = min(15*degree,v.resolution);
if isa(sP(1).proj,'plainProjection')
  arrowSize  = get_option(varargin,'arrowSize', 0.75 * res / degree) / maxD;
else
  arrowSize = get_option(varargin,'arrowSize', 0.5 * res / degree) * degree / maxD;
end

for j = 1:numel(sP)

  holdState = get(sP(j).ax,'nextPlot');
  set(sP(j).ax,'nextPlot','add');
  
  % project data
  [x0,y0] = project(sP(j).proj,normalize(v),'noAntipodal',varargin{:});
  if check_option(varargin,'centered') || mhs == 0
   
    [x1,y1] = project(sP(j).proj,normalize(v - scale * d),'noAntipodal',varargin{:});
    [x2,y2] = project(sP(j).proj,normalize(v + scale * d),'noAntipodal',varargin{:});
    
    % we need to rescale to avoid distortions according to projection
    l = sqrt((x1-x0).^2 + (y1-y0).^2);
    x1 = x0 + (x1-x0) ./ l .* norm(d) .* arrowSize / 2;
    y1 = y0 + (y1-y0) ./ l .* norm(d) .* arrowSize / 2;
    
    x0 = x0 + (x2-x0) ./ l .* norm(d) .* arrowSize / 2;
    y0 = y0 + (y2-y0) ./ l .* norm(d) .* arrowSize / 2;
    
  else
    
    [x1,y1] = project(sP(j).proj,normalize(v + 2*abs(scale) * d),'noAntipodal',varargin{:});
    
    % we need to rescale to avoid distortions according to projection
    l = sqrt((x0-x1).^2 + (y0-y1).^2);
    x1 = x0 + (x1-x0) ./ l .* norm(d) .* arrowSize;
    y1 = y0 + (y1-y0) ./ l .* norm(d) .* arrowSize;
    
  end
  
  % if arrowSize==0 the actual length is taken
  if check_option(varargin,'autoArrowSize')
    arrowSizeArg = {};
  else
    arrowSizeArg = {0}; 
  end
  
  % make the quiver plot
  varargin = delete_option(varargin,'parent',1);
  h(j) = optiondraw(quiver(x0,y0,x1-x0,y1-y0,arrowSizeArg{:},'MaxHeadSize',mhs,'parent',sP(j).hgt),varargin{:});     %#ok<AGROW>
  
  % finalize the plot
  % add annotations
  sP(j).plotAnnotate(varargin{:})
  set(sP(j).ax,'nextPlot',holdState);
end

if any(strcmpi(holdState,{'replaceChildren','replace'})) && isappdata(sP(1).parent,'mtexFig')
  mtexFig = getappdata(sP(1).parent,'mtexFig');
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
end

if nargout == 0, clear('h'); end
