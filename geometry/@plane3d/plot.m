function varargout = plot(plane,varargin)
% plot planes in 3d space clipped by current axis
%
% Syntax
%   plot(plane3d)
%
% Input
%
% See also
% patch

% -------------------- GET OPTIONS ----------------------------------------

if nargin>1 && isnumeric(varargin{1})
  % color by property

  color = varargin{1};
  varargin(1) = [];

  assert(any(numel(color) == numel(plane) * [1,3]),...
    'Number of grains must be the same as the number of data');

  if (numel(color) == numel(plane));  colorbar; end
  varargin = set_option(varargin,'FaceColor',color);

end

% where to plot
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
  varargin = delete_option(varargin, 'parent',1);
else
  ax = gca;
end

Faces = reshape(1:4*numel(plane),[],numel(plane))';
Vertices = zeros(numel(plane)*4,3);

for i = 1:numel(plane)

  A = plane(i).a;
  B = plane(i).b;
  C = plane(i).c;
  D = plane(i).d;
  
  % extract axis bounds to crop plane
  lim = ax.XLim;
  xmin = lim(1);
  xmax = lim(2);
  lim = ax.YLim;
  ymin = lim(1);
  ymax = lim(2);
  lim = ax.ZLim;
  zmin = lim(1);
  zmax = lim(2);
  
  % find intercept
  % TODO: more efficient
  X = [xmin xmin xmax xmax];
  Y = [ymin ymax ymax ymin];
  Z = -1/C*(A*X+B*Y-D);
  
  z_bound_min = Z<zmin;
  z_bound_max = Z>zmax;
  
  if any(z_bound_min)||any(z_bound_max)||any(isnan(Z))||any(isinf(Z))
    if any(z_bound_min&z_bound_max)
      Z(z_bound_min) = zmin;
      Z(z_bound_max) = zmax;
    else
      Z = [zmin zmin zmax zmax];
    end
  
    X = 1/A*(D-C*Z-B*Y);
    x_bound_min = X<xmin;
    x_bound_max = X>xmax;
    if any(x_bound_min)||any(x_bound_max)||any(isnan(X))||any(isinf(X))
      if any(x_bound_min&x_bound_max)
        X(x_bound_min) = xmin;
        X(x_bound_max) = xmax;
      else
        X = [xmin xmin xmax xmax];
        Z = [zmin zmax zmax zmin];
      end
      Y = 1/B*(D-C*Z-A*X);

      y_bound_min = Y<ymin;
      y_bound_max = Y>ymax;
      if any(y_bound_min)||any(y_bound_max)||any(isnan(Y))||any(isinf(Y))
          warning('plane outside of current plot boundaries. Nothing to plot')
          return
      end

    end

  end

  Vertices((i-1)*4+1:(i-1)*4+4,:) = [X' Y' Z'];
  
end

h = patch('Faces',Faces,'Vertices',Vertices, varargin{:});

if nargout>0
    varargout = {h,ax};
end
