function h = quiver3(v, d, varargin )
% plot vectors as three dimensional arrows
%
% Syntax
%
%   quiver3(v,d)                     % the arrows d starting at the points v
%   h = quiver3(v,d,'arrowSize',0.1) % longer arrows, returning the handles
%
% Input
%  v - @vector3d, starting points
%  d - @vector3d, directions, drawn in both directions when antipodal
%
% Output
%  h - handles of the quiver plots
%
% Options
%  arrowSize   - length of the arrows, default 0.05
%  MaxHeadSize - size of the head
%
% Flags
%  autoArrowSize - let quiver3 scale the arrows automatically

% initialize spherical plot

v = vector3d(v);
if length(d) == length(v), d = reshape(d,size(v)); end

% make the quiver plot
mhs = get_option(varargin,'MaxHeadSize',0.9*(1-d.antipodal));
arrowSize = get_option(varargin,'arrowSize',0.05);

d = d.*arrowSize;

if ~check_option(varargin,'autoArrowSize')
  arrowSize = 0;
end
  
options = {arrowSize,'MaxHeadSize',mhs,'linewidth',2};

%d = d .* sign(dot(d,v));
if all(isnull(norm(v)-1)), v = v.*1.05; end

h = optiondraw(quiver3(v.x,v.y,v.z,d.x,d.y,d.z,options{:}),varargin{:});
if d.antipodal
  hG = holdOn(gca); %#ok<NASGU>
  h = [h,optiondraw(quiver3(v.x,v.y,v.z,-d.x,-d.y,-d.z,options{:}),varargin{:})];
  clear hG
end
  
% finalize the plot
axis equal off
fcw

% add annotations

if nargout == 0, clear('h'); end
