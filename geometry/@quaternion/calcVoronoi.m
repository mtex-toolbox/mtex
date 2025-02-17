function [V,C,E] = calcVoronoi(q,varargin)
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

% be sure q is quaternion
q = quaternion(q);

% make it double cover
% TODO: Possibly only double the quaternions which are nearly at the
% boundary of upper S^3
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

% delete the cells of the doubled quaternions
ind = center<=n/2;
center = center(ind);
left = left(ind);

C = cell(n,1);
last = [0;find(diff(center));length(center)];
for k=1:length(last)-1  
  ndx = last(k)+1:last(k+1);
  C{center(ndx(1))} = left( ndx );
end

% delete obsolet cells
C = C(1:length(C)/2);
% simplify if the same vertex occurs several times in a cell 
C = cellfun(@unique,C,'UniformOutput',false);
 
% TODO: Now in V some rotations occurs a second time by there opposite quaternion
% for example try: unique(rotation(V))

% compute edges
if nargout>3
  faces = faces(first,:);   % delete duplicated faces (look at line 39)
  faces = sort(faces,2);
  f = [faces(:,[2 3 4]); faces(:,[1 3 4]); faces(:,[1 2 4]); faces(:,[1 2 3])];
  [~,first,f] = unique(f,'rows','first');
  [~,last,~] = unique(f,'rows','last');
  first = mod(first-1,length(V))+1;
  last = mod(last-1,length(V))+1;
  E = [first,last];
  % G = graph(first,last);
  % E = adjacency(G);
end

if check_option(varargin,'struct')
  C = struct('center',center(:),'vertices',left(:));
end





