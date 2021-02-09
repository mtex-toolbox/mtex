function [v,faces] = generateUnitCells(xy,unitCell,varargin)
% generate a list of patches according to spatial coordinates and the unitCell
%
% Input
%  xy       - midpoints of the cells
%  unitCell - spatial coordinates of the unit cell
%
% Ouput
%  v     - list of vertices
%  faces - list of faces

% compute the vertices
x = reshape(bsxfun(@plus,xy(:,1),unitCell(:,1).'),[],1);
y = reshape(bsxfun(@plus,xy(:,2),unitCell(:,2).'),[],1);

% remove equal points
% in general every measurment point generates 4 or 6 vertex points
% some of them apear multiple times 
% lets try to reduce them

if ~check_option(varargin,'noStripes')
  eps = abs(diff(unitCell));
  eps = eps(eps > max(eps(:))/10);
  eps = min(eps) / 12;
  [~,m,n] = unique(round([x-min(x) y-min(y)]./eps),'rows');
else
  [~,m,n] = uniquetol([x-min(x) y-min(y)],0.01/sqrt(size(xy,1)),'ByRows',true );
end

v = [x(m) y(m)];

% set faces
faces = reshape(n, [], size(unitCell,1));

% tic
% [~,m,n] = unique(round([x-min(x) y-min(y)]./eps),'rows');
% toc

%%
% tic
% [~,m,n] = uniquetol([x-min(x) y-min(y)],0.01/sqrt(size(xy,1)),'ByRows',true );
% toc
