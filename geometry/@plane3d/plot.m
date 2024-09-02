function [h,ax] = plot(plane,varargin)
% plot planes in 3d space
%
% Syntax
%   plot(plane3d)
%
% Input
%
% See also
% 

% -------------------- GET OPTIONS ----------------------------------------

A = plane.a;
B = plane.b;
C = plane.c;
D = plane.d;

% where to plot
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
else
  ax = gca;
end

% extract axis bounds to crop plane
lim = ax.XLim;
xmin = lim(1);
xmax = lim(2);
lim = ax.YLim;
ymin = lim(1);
ymax = lim(2);
zlim = ax.ZLim;

% find intercept
% TODO: more efficient
X = [xmin xmin xmax xmax];
Y = [ymin ymax ymax ymin];
Z = -1/C*(A*X+B*Y-D);

z_bound_min = Z<zmin;
z_bound_max = Z>zmax;

if any(z_bound_min)&&any(z_bound_max)&&any(isnan(Z))&&any(isinf(Z))
  if any(z_bound_min&z_bound_max)
    Z(z_bound_min) = zmin;
    Z(z_bound_max) = zmax;
  else
    Z = [zmin zmin zmax zmax];
  end

  X = 1/A*(D-C*Z-B*Y);
  x_bound_min = X<xmin;
  x_bound_max = X>xmax;
  if any(x_bound_min)&&any(x_bound_max)&&any(isnan(X))&&any(isinf(X))
    if any(x_bound_min&x_bound_max)
      X(x_bound_min) = xmin;
      X(x_bound_max) = xmax;
    else
      X = [xmin xmin xmax xmax];
      Z = [zmin zmax zmax zmin];
    end
    Y = 1/B*(D-C*Z-A*X);
  end

end

h = patch(X,Y,Z,'red');
