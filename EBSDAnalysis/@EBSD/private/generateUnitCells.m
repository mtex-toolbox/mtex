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
eps = min(sqrt(diff(unitCell(:,1)).^2 + diff(unitCell(:,2)).^2))/10;
%xi = round(x-min(x)./eps);
%yi = round(y-min(y)./eps);
%[~,m,n] = unique((1+xi)*2*max(yi) + yi);
[v,m,n] = unique(round([x-min(x) y-min(y)]./eps),'rows');

v = [x(m) y(m)];

% set faces
faces = reshape(n, [], size(unitCell,1));
