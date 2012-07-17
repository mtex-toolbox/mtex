function ind = inpolygon(p1,p2,method)
% check whether the polygons p1 are inside the polygon p2
%
%% Syntax
%  ind = inpolygon(p1 ,p2)
% 
%% Input
%  p1  - @polygon
%  p2  - @polygon
%
%% Option
%  method - 'complete' (default), 'centroids', 'intersect'
%
%% Output
%  ind    - logical indexing
%

% ensure both argument are polygons
p1 = polygon(p1);
p2 = polygon(p2);

% extract vertices
Vertices = vertcat(p2.Vertices);

% complete is the default method
if nargin < 3, method = 'complete';end

% switch by method
switch lower(method)
  
  case 'complete'
    
    % all the vertices has to be inside the given polygon
    ind = in_it(p1,Vertices,@all);
  
  case {'centroids','centroid'}
    
    % the centroid has to be inside the given polygon    
    pVertices = centroid(p1);
    ind = inpolygon(pVertices(:,1),pVertices(:,2),Vertices(:,1),Vertices(:,2));
    
  case 'intersect'
    
    % at least one of the vertices has to be inside the given polygon
    ind = in_it(p1,Vertices,@any);
end

% formate output
ind = reshape(ind,size(p1));


%% check whether a point is inside a polygon
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
