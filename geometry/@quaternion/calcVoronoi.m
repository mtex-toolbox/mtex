function [V,C] = calcVoronoi(q,varargin)
% compute the the Voronoi decomposition for unit quaternions
%
%% Input
%  q - @quaternion
%
%% Output
%  V - Voronoi--Vertices
%  C - Voronoi--Cells containing the index to the Voronoi--Vertex
%
%% See also
% S2Grid\calcVoronoi voronoin

% make it double cover
q = reshape([q -q],[],1);
n = numel(q);
[a,b,c,d] = double(q);
% compute the delaunay triangulation
[faces] = convhulln([a(:) b(:) c(:) d(:)]);

% voronoi-vertices
V = normalize(cross(...
  subsref(q,faces(:,4))-subsref(q,faces(:,1)),...
  subsref(q,faces(:,3))-subsref(q,faces(:,1)),...
  subsref(q,faces(:,2))-subsref(q,faces(:,1))));


% voronoi-vertices around generators
[center vertices] = sort(faces(:));

vertices = mod(vertices'-1,numel(V))+1;

% now we delete duplicated voronoi vertices
eps = 10^-10; % machine precision
[ignore,first,ind] = unique(round(squeeze(double(V))/eps)/eps,'rows');
V = subsref(V,first); 
left = ind(vertices)';

% erase duplicated vertices in the pointer list
dublicated = find([diff(vertices)==0,false]);

% check whether the duplicated is in the next cell // they shouldn't be
% deleted
last = [0;find(diff(center));numel(center)];
dublicated(ismember(dublicated,last)) = [];

left(dublicated) = [];
center(dublicated) = [];

C = cell(n,1);
last = [0;find(diff(center));numel(center)];
for k=1:numel(last)-1  
  ndx = last(k)+1:last(k+1);
  C{center(ndx(1))} = left( ndx );
end