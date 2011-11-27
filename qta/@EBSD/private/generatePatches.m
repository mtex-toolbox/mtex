function [v faces] = generatePatches(xy,unitCell,varargin)
% generate a list of patches according to spatial coordinates and the unitCell
%
%% Input
%  xy       - midpoints of the cells
%  unitCell - spatial coordinates of the unit cell
%
%% Ouput
%  v     - list of vertices
%  faces - list of faces

% compute the vertices
x = bsxfun(@plus,xy(:,1),unitCell(:,1).');
y = bsxfun(@plus,xy(:,2),unitCell(:,2).');

% remove equal points
eps = min(sqrt(diff(unitCell(:,1)).^2 + diff(unitCell(:,2)).^2))/10;
[v,m,n] = unique(round([x(:)-min(x(:)) y(:)-min(y(:))]./eps),'rows');
% [v,m,n] = unique(fix([x(:) y(:)]./eps),'rows');

v = [x(m) y(m)];

% set faces
faces = reshape(n, size(x));
