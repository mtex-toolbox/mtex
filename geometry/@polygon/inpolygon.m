function ind = inpolygon( p , p2, method)
% check whether a polygon is in a given polygon
%
%% Syntax
%  ind = inpolygon(polygon1 ,polygon2)
% 
%% Input
%  p   - @polygon
%  p2  - @polygon
%
%% Option
%  method - 'complete' (default), 'centroids', 'intersect'
%
%% Output
%  ind    - logical indexing
%

if isa(p,'EBSD')
  ind = inpolygon(p,polygon(p2));
  return
end

p = polygon( p );
x = polygon( p2 );

Vertices = vertcat(x.Vertices);

if nargin < 3
  method = 'complete';
end

switch lower(method)
  case 'complete'
    ind = in_it(p,Vertices,@all);
  case {'centroids','centroid'}
    pVertices = centroid(p);
    ind = inpolygon(pVertices(:,1),pVertices(:,2),Vertices(:,1),Vertices(:,2));
  case 'intersect'
    ind = in_it(p,Vertices,@any);
end

ind = reshape(ind,size(p));



function ind = in_it(p,Vertices,modifier)

np = cellfun('length',{p.Vertices});
pVertices = vertcat(p.Vertices);
    
in = inpolygon(pVertices(:,1),pVertices(:,2),Vertices(:,1),Vertices(:,2));

cs = [0 cumsum(np)];

ind = false(size(np));
for k=1:length(np)
  ind(k) = modifier(in(cs(k)+1:cs(k+1)));
end


% ind = cellfun(modifier,mat2cell(in, np,1));
