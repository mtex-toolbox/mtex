function [area,centroids] = calcVoronoiArea(S2G,varargin)
% compute the area of the Voronoi decomposition
%
%% Input
%  S2G - @S2Grid
%
%% Output
%  area - area of the corresponding Voronoi cells
%  centroids - centroid of the voronoi cell
%
%% Options
% incomplete -

%% in case of antipodal symmetry - add antipodal points

antipodal = check_option(S2G,'antipodal');
if antipodal
  S2G = [S2G(:);-S2G(:)];
  S2G = delete_option(S2G,'antipodal');
end

S2G = reshape(S2G,[],1);
[V,C] = calcVoronoi(S2G);

nd = ~cellfun('isempty',C);
S2G = S2G.vector3d(nd);

last = cumsum(cellfun('prodofsize',C(nd)));

left = [C{nd}];
shift = 2:last(end)+1;             % that is the shift
shift(last) = [0;last(1:end-1)]+1; % and the last gets the first
right = left(shift);

center = cumsum([1 diff(shift)>1]);

va = S2G(center);
vb = V(left);
vc = V(right);    % next vertex around

% calculate the area for each triangle around generator (va)
A = real(sphericalTriangleArea(va,vb,vc));

if nargout>1
  [x,y,z]= double(A.*(va+vb+vc));
  x = full(sparse(center,1,x,numel(S2G),1));
  y = full(sparse(center,1,y,numel(S2G),1));
  z = full(sparse(center,1,z,numel(S2G),1));
  centroids = (vector3d(x,y,z));
end

% accumulate areas of spherical triangles around generator
A = full(sparse(center,1,A,numel(S2G),1));

area = zeros(size(nd));
area(nd) = A(1:nnz(nd));

if antipodal
  area = sum(reshape(area,[],2),2);
end

