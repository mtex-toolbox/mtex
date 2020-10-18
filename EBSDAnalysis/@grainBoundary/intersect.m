function  [x,y,segLength] = intersect(gB,xy1,xy2,varargin)
% length of a boundary segment
%
% Syntax
%   [x,y] = intersect(gB,xy1,xy2)
%   [x,y,segLength] = intersect(gB,xy1,xy2)
%
% Input
%  gb - @grainBoundary
%  xy1, xy2 - coordinates of the endpoints of the line
%
% Output
%  x,y - list of intersection points
%
% Example
%  mtexdata small
%  grains = calcGrains(ebsd('indexed'))
%  grains = smooth(grains,4)
%  plot(grains.boundary,'micronbar','off')
%  % define some line
%  xy1 = [33500,4500];  % staring point
%  xy2 = [36000,7500]; % end point
%  line([xy1(1);xy2(1)],[xy1(2);xy2(2)],'linewidth',1.5,'color','g')
%  [x,y] = grains.boundary.intersect(xy1,xy2);
%  hold on
%  scatter(x,y,'red')
%
%  % find the number of intersection points  
%  sum(~isnan(x))
%  % mark the intersected boundary segments
%  plot(grains.boundary(~isnan(x)),'lineColor','b','linewidth',2)
%  hold off

n_rows_1 = size(xy1,1);
n_rows_2 = length(gB);

% end points of the lines
X1 = repmat(xy1(:,1),1,n_rows_2);
Y1 = repmat(xy1(:,2),1,n_rows_2);
X2 = repmat(xy2(:,1),1,n_rows_2);
Y2 = repmat(xy2(:,2),1,n_rows_2);

% end points boundary segments
X3 = repmat(gB.V(gB.F(:,1),1).',n_rows_1,1);
Y3 = repmat(gB.V(gB.F(:,1),2).',n_rows_1,1);
X4 = repmat(gB.V(gB.F(:,2),1).',n_rows_1,1);
Y4 = repmat(gB.V(gB.F(:,2),2).',n_rows_1,1);

X4_X3 = X4-X3;
Y1_Y3 = Y1-Y3;
Y4_Y3 = Y4-Y3;
X1_X3 = X1-X3;
X2_X1 = X2-X1;
Y2_Y1 = Y2-Y1;

numerator_a = X4_X3 .* Y1_Y3 - Y4_Y3 .* X1_X3;
numerator_b = X2_X1 .* Y1_Y3 - Y2_Y1 .* X1_X3;
denominator = Y4_Y3 .* X2_X1 - X4_X3 .* Y2_Y1;

u_a = numerator_a ./ denominator;
u_b = numerator_b ./ denominator;
inside = (u_a >= -1e-5) & (u_a <= 1+1e-5) & (u_b >= -1e-5) & (u_b <= 1+1e-5);

% Find the adjacency matrix A of intersecting lines.
x = X1 + X2_X1 .* u_a;
y = Y1 + Y2_Y1 .* u_a;
x(~inside) = NaN;
y(~inside) = NaN;

% sort by distance to starting point
d = sqrt((x(~isnan(x))-xy1(1)).^2 + (y(~isnan(x))-xy1(2)).^2);
[~,ind] = sort(d);

segLength = diff(d(ind));



