function [area,centroids] = calcVoronoiArea(v,varargin)
% compute the spherical area of the Voronoi decomposition
%
% Input
%  v - @vector3d
%
% Output
%  area - area of the corresponding Voronoi cells
%  centroids - centroid of the voronoi cell
%
% Options
% incomplete -

v = reshape(v,[],1);
N = length(v);

% in case of antipodal symmetry - add antipodal points
antipodal = v.antipodal || check_option(varargin, 'antipodal');
if antipodal
  v.antipodal = false;
  [v,~,IC] = unique([v;-v],'noSymmetry');
end

[V,C] = calcVoronoi(v);

nd = ~cellfun('isempty',C);
v = v.subSet(nd);

last = cumsum(cellfun('prodofsize',C(nd)));

left = [C{nd}];
shift = 2:last(end)+1;             % that is the shift
shift(last) = [0;last(1:end-1)]+1; % and the last gets the first
right = left(shift);

center = cumsum([1 diff(shift)>1]);

va = v.subSet(center);
vb = V.subSet(left);
vc = V.subSet(right);    % next vertex around

% calculate the area for each triangle around generator (va)
A = real(sphericalTriangleArea(va,vb,vc));

if nargout>1
  [x,y,z]= double(A.*(va+vb+vc));
  x = full(sparse(center,1,x,length(S2G),1));
  y = full(sparse(center,1,y,length(S2G),1));
  z = full(sparse(center,1,z,length(S2G),1));
  centroids = vector3d(x,y,z);
end

% accumulate areas of spherical triangles around generator
A = full(sparse(center,1,A,length(v),1));

area = zeros(size(nd));
area(nd) = A(1:nnz(nd));

if antipodal
  idx = ( accumarray(IC,ones(size(IC))) == 2 ); % find all double occurences
  area(idx) = area(idx)/2; % halve their weight
  area = area(IC); % go back to original order
  area = area(1:N); % only the original nodes
end




