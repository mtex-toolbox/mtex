function [v,faces] = generateUnitCells(pos,unitCell,varargin)
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
V = pos(:) + unitCell(:).';

% remove equal points
% in general every measurment point generates 4 or 6 vertex points
% some of them apear multiple times 
% lets try to reduce them
[~,m,n] = unique(V-V(1),'tolerance',0.01/sqrt(length(pos)));

%{
if ~check_option(varargin,'noStripes')
  eps = abs(diff(unitCell));
  eps = eps(eps > max(eps(:))/10);
  eps = min(eps) / 12;
  [~,m,n] = unique(round([x-min(x) y-min(y)]./eps),'rows');
else
  [~,m,n] = uniquetol([x-min(x) y-min(y)],0.01/sqrt(length(pos)),'ByRows',true );
end
%}

v = [V.x(m) V.y(m) V.z(m)];

% set faces
faces = reshape(n, [], length(unitCell));

% tic
% [~,m,n] = unique(round([x-min(x) y-min(y)]./eps),'rows');
% toc

%%
% tic
% [~,m,n] = uniquetol([x-min(x) y-min(y)],0.01/sqrt(size(xy,1)),'ByRows',true );
% toc
