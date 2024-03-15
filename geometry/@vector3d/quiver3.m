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

d = d.*arrowSize;

if ~check_option(varargin,'autoArrowSize')
  arrowSize = 0;
end
  
options = {arrowSize,'MaxHeadSize',mhs,'linewidth',2};

%d = d .* sign(dot(d,v));
if all(isnull(norm(v)-1)), v = v.*1.05; end

h = optiondraw(quiver3(v.x,v.y,v.z,d.x,d.y,d.z,options{:}),varargin{:});
if d.antipodal
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
