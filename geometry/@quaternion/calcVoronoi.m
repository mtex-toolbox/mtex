function [V,C,E] = calcVoronoi(q,varargin)
% compute the the Voronoi decomposition for unit quaternions
%
% Input
%  q - @quaternion
%
% Output
%  V - Voronoi--Vertices, both lifts of every vertex of the double cover
%  C - Voronoi--Cells containing the index to the Voronoi--Vertex
%  E - pairs of Voronoi--Vertices bounding a Voronoi--Edge
%
% Flags
%  struct - C as center/vertex incidences and the number of quaternions
%           sharing each cell
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

% convhulln keeps one of a set of coincident points - let it stand for them
[~,firstQ,indQ] = unique(round(squeeze(double(q))*1e10),'rows','stable');
q = q.subSet(firstQ);

% compute the delaunay triangulation
faces = convhulln(squeeze(double(q)));

% voronoi-vertices
V = cross(...
  q.subSet(faces(:,4))-q.subSet(faces(:,1)),...
  q.subSet(faces(:,3))-q.subSet(faces(:,1)),...
  q.subSet(faces(:,2))-q.subSet(faces(:,1)));

% a degenerated tetrahedron has no circumcenter - take the mean instead
isBad = norm(V)<1e-8;
V = V.setSubSet(isBad,sum(reshape(q.subSet(faces(isBad,:)),nnz(isBad),4),2));

V = V.normalize;

% voronoi-vertices around generators
[center, vertices] = sort(faces(:));
vertices = mod(vertices-1,length(V))+1;

% now we delete duplicated voronoi vertices
tol = 1e-10;
[~,firstV,indV] = unique(round(squeeze(double(V))/tol)*tol,'rows');
V = V.subSet(firstV);

% keep the cells of the original quaternions, each of them reading off the
% point that stands for it
gen = indQ(1:n/2);
inc = sparse(center,indV(vertices),1,length(q),length(V));
[vertices,center] = find(inc(gen,:).');
mult = accumarray(gen,1,[length(q) 1]);

% compute edges
if nargout>2
  % two tetrahedrons sharing a triangle are joined by a voronoi edge
  tri = sort([faces(:,[2 3 4]); faces(:,[1 3 4]); faces(:,[1 2 4]); faces(:,[1 2 3])],2);
  [~,iFirst] = unique(tri,'rows','first');
  [~,iLast] = unique(tri,'rows','last');
  E = indV(mod([iFirst,iLast]-1,size(faces,1))+1);
  E = E(E(:,1)~=E(:,2),:);
end

if check_option(varargin,'struct')
  C = struct('center',center,'vertices',vertices,'mult',mult(gen));
else % convert to cell list of vertices
  C = cell(n/2,1);
  last = [0;find(diff(center));length(center)];
  for k=1:length(last)-1
    ndx = last(k)+1:last(k+1);
    C{center(ndx(1))} = vertices(ndx);
  end
end

end
