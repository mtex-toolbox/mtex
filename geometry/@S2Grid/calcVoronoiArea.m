function area = calcVoronoiArea(S2G,varargin)
% compute the area of the Voronoi decomposition
%
%% Input
%  S2G - @S2Grid
%
%% Output
%  area - area of the corresponding Voronoi cells
%
%% Options
% incomplete -

%% in case of antipodal symmetry - add antipodal points
antipodal = check_option(S2G,'antipodal');
if antipodal
  S2G = [S2G,-S2G];
  S2G = delete_option(S2G,'antipodal');
end

S2G = reshape(vector3d(S2G),[],1);
[x,y,z] = double(S2G);
faces = convhulln([x(:) y(:) z(:)]); % delauny triangulation on sphere

% voronoi-vertices
v = normalize(cross(S2G(faces(:,3))-S2G(faces(:,1)),S2G(faces(:,2))-S2G(faces(:,1))));

% the triangulation may have some defects, i.e. interior faces;
if check_option(varargin,'incomplete')
  del = angle(v,-zvector) > eps;
  faces = faces(del,:);
  v = v(del,:);
end

% voronoi-vertices around generators
[center vertices] = sort(faces(:));
S2Gc = S2G(center);
vert = repmat(v,3,1);
vert = vert(vertices);

% the azimuth of a voronoi-vertex relativ to its generator
[ignore,azimuth] = polar(hr2quat(S2Gc,zvector).*cross(S2Gc,vert));

% sort the vertices clockwise around with respect to its center
[ignore,left] = sortrows([center azimuth]);

% pointer to the next vertex around center
last = [find(diff(center));numel(center)]; % cumulative indizes
shift = 2:numel(center)+1;         % that is the shift
shift(last) = [0;last(1:end-1)]+1; % and the last gets the first
right = left(shift);

% spherical-triangles (va -- vb -- vc) around the generator (va)
va = S2Gc;   vb = vert(left);    vc = vert(right);

% calculate the area for each triangle around generator (va)
area = vertices2Area(va,vb,vc);

% accumulate areas of spherical triangles around generator
area = full(sparse(center,1,area,numel(S2G),1));

if antipodal
  area = sum(reshape(area,[],2),2);
end

%% compute are of a spherical triangle given its vertices
function area = vertices2Area (va,vb,vc)

% planes (great circles) spanned by the spherical triangle
n_ab = cross(va,vb);
n_bc = cross(vb,vc);
n_ca = cross(vc,va);

l2n_ab = norm(n_ab);
l2n_bc = norm(n_bc);
l2n_ca = norm(n_ca);

% if any cross product is to small, there is almost no area between the great
% circles
eps = 10^-10;
nd = ~(l2n_ab < eps | l2n_bc < eps | l2n_ca < eps);

% normalize the plane normal vector
n_ab = n_ab(nd)./l2n_ab(nd);
n_bc = n_bc(nd)./l2n_bc(nd);
n_ca = n_ca(nd)./l2n_ca(nd);

% Girard's formula. A+B+C-pi, with angles  A,B,C between the great circles
area = zeros(size(nd));
area(nd) = ...
  acos(dot(n_ab,-n_bc))+...
  acos(dot(n_bc,-n_ca))+...
  acos(dot(n_ca,-n_ab))- pi;


