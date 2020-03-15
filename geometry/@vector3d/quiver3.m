function h = quiver3(v, d, varargin )
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

v = vector3d(v);
if length(d) == length(v), d = reshape(d,size(v)); end

% make the quiver plot
mhs = get_option(varargin,'MaxHeadSize',0.9*(1-d.antipodal));
arrowSize = get_option(varargin,'arrowSize',0.05);
  
% project data
if check_option(varargin,'centered') || mhs == 0
  %[x0,y0] = project(sP(j).proj,normalize(v - abs(arrowSize) * d),varargin{:});
  %[x1,y1] = project(sP(j).proj,normalize(v + abs(arrowSize) * d),varargin{:});
else
  %[x0,y0] = project(sP(j).proj,normalize(v),varargin{:});
  %[x1,y1] = project(sP(j).proj,normalize(v + 2*abs(arrowSize) * d),varargin{:});
end

d = d.*arrowSize;

if ~check_option(varargin,'autoArrowSize')
  arrowSize = 0;
end
  
options = {arrowSize,'MaxHeadSize',mhs,'linewidth',2};

%d = d .* sign(dot(d,v));
v = v.*1.05;

h = optiondraw(quiver3(v.x,v.y,v.z,d.x,d.y,d.z,options{:}),varargin{:});
if d.antipodal %#ok<BDLGI>
  washold = getHoldState(gca);
  hold on
  h = [h,optiondraw(quiver3(v.x,v.y,v.z,-d.x,-d.y,-d.z,options{:}),varargin{:})];
  hold(gca,washold); 
end
  
% finalize the plot
axis equal off
fcw

% add annotations

if nargout == 0, clear('h'); end
