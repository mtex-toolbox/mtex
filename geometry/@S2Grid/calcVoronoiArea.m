function area = calcVoronoiArea(S2G)
% compute the area of the Voronoi decomposition
%
%% Input
%  S2G - @S2Grid
%
%% Output
%  area - area of the corresponding Voronoi cells
%

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
del = angle(v,-zvector) > eps; 
faces = faces(del,:);
v = v(del,:);

% voronoi-vertices around generators
[center vertices] = sort(faces(:));
S2Gc = S2G(center);
vert = repmat(v,3,1);
vert = vert(vertices);

% init an pointer set
vl = zeros(numel(vert),1); vr = zeros(numel(vert),1);
cs = [0; find(diff(center)); numel(center)];

% the azimut of a voronoi-vertex relativ to its generator
[t,azimuth] = polar(cross(S2Gc-vert,zvector));
for k=1:numel(cs)-1
  nd = cs(k)+1:cs(k+1);
  % sort vertices clockwise around generator
  [a,ndx] = sort(azimuth(nd));
  vl(nd) = nd(ndx);
  vr(nd) = nd(ndx([2:end 1])); % pointer to the next vertex
end

% spherical-triangles around the generator
va = S2Gc;
vb = vert(vl);
vc = vert(vr);

% some points may be identical, if the voronoi-diagram is degenerated
nd = angle(vb,vc) > eps;
area(nd) = vertices2Area(va(nd),vb(nd),vc(nd));
area(any(imag(area(:)),2)) = 0; % some areas are sometimes corrupted?

% accumulate areas of spherical triangles around generator
area = full(sparse(center,1,area,numel(S2G),1)); 

if antipodal
  area = sum(reshape(area,[],2),2);
end

%% compute are of a spherical triangle given its vertices
function area = vertices2Area (v1,v2,v3)

%  Compute the lengths of the sides of the spherical triangle.
[as,bs,cs] = vertices2Sides(v1,v2,v3);

%  Get the spherical angles.
[a,b,c] = sides2Angles(as,bs,cs);

%  Get the area.
area = angles2Area(a,b,c);

%% compute 
function [a,b,c] = sides2Angles(as,bs,cs)

asu = as;
bsu = bs;
csu = cs;
ssu = ( asu + bsu + csu ) ./ 2.0;

tan_a2 = sqrt ( ( sin ( ssu - bsu ) .* sin ( ssu - csu ) ) ./ ...
  ( sin ( ssu ) .* sin ( ssu - asu )     ) );

a = 2.0 * atan ( tan_a2 );

tan_b2 = sqrt ( ( sin ( ssu - asu ) .* sin ( ssu - csu ) ) ./ ...
  ( sin ( ssu ) .* sin ( ssu - bsu )     ) );

b = 2.0 * atan ( tan_b2 );

tan_c2 = sqrt ( ( sin ( ssu - asu ) .* sin ( ssu - bsu ) ) ./ ...
  ( sin ( ssu ) .* sin ( ssu - csu )     ) );

c = 2.0 * atan ( tan_c2 );

%% compute area of a spherical triangle given its angles
function area = angles2Area (a,b,c)

%  Apply Girard's formula.
area = a + b + c - pi;

%% compute sides of a spherical triangle given its angles
function [as,bs,cs] = vertices2Sides(v1,v2,v3)
%
  
as = angle(v2,v3);
bs = angle(v3,v1);
cs = angle(v1,v2);



