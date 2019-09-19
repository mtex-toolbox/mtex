function [V,C] = calcVoronoi(q,varargin)
% compute the the Voronoi decomposition for unit quaternions
%
% Input
%  q - @quaternion
%
% Output
%  V - Voronoi--Vertices
%  C - Voronoi--Cells containing the index to the Voronoi--Vertex
%
% See also
% S2Grid\calcVoronoi voronoin

% make it double cover
q = reshape([q -q],[],1);
n = length(q);
[a,b,c,d] = double(q);
% compute the delaunay triangulation
[faces] = convhulln([a(:) b(:) c(:) d(:)]);

% voronoi-vertices
V = normalize(cross(...
  q.subSet(faces(:,4))-q.subSet(faces(:,1)),...
  q.subSet(faces(:,3))-q.subSet(faces(:,1)),...
  q.subSet(faces(:,2))-q.subSet(faces(:,1))));


% voronoi-vertices around generators
[center, vertices] = sort(faces(:));

vertices = mod(vertices'-1,length(V))+1;

% now we delete duplicated voronoi vertices
eps = 10^-10; % machine precision
[~,first,ind] = unique(round(squeeze(double(V))/eps)/eps,'rows');
V = V.subSet(first); 
left = ind(vertices)';

% erase duplicated vertices in the pointer list
dublicated = find([diff(vertices)==0,false]);

% check whether the duplicated is in the next cell // they shouldn't be
% deleted
last = [0;find(diff(center));length(center)];
dublicated(ismember(dublicated,last)) = [];

left(dublicated) = [];
center(dublicated) = [];

C = cell(n,1);
last = [0;find(diff(center));length(center)];
for k=1:length(last)-1  
  ndx = last(k)+1:last(k+1);
  C{center(ndx(1))} = left( ndx );
end
