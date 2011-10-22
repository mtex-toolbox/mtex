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

%% compute the Delaunay triangulation.
[face,vertices,S2G] = calcDelaunay(S2G);

%% sort triangles
p1 = face(1,:);
p2 = face(2,:);
p3 = face(3,:);

d1 = S2G.vector3d(p1);
d2 = S2G.vector3d(p2);
d3 = S2G.vector3d(p3);

d12 = d1 + d2; d12 = d12 ./ norm(d12);
d23 = d2 + d3; d23 = d23 ./ norm(d23);
d31 = d3 + d1; d31 = d31 ./ norm(d31);
    
%%  Compute orientation and area of the 6 subtriangles.
o1a = vertices2Orientation(d1,vertices,d31);
a1a = vertices2Area(d1,vertices,d31);

o1b = vertices2Orientation(d1,d12,vertices);
a1b = vertices2Area(d1,d12,vertices);

o2a = vertices2Orientation(d2,vertices,d12);
a2a = vertices2Area(d2,vertices,d12);

o2b = vertices2Orientation(d2,d23,vertices);
a2b = vertices2Area(d2,d23,vertices);

o3a = vertices2Orientation(d3,vertices,d23);
a3a = vertices2Area(d3,vertices,d23);

o3b = vertices2Orientation(d3,d31,vertices);
a3b = vertices2Area(d3,d31,vertices);

%%  Contribute to the Voronoi areas.

area = full(sum(sparse([p1 p2 p3],1:(numel(p1)+numel(p2)+numel(p2)),...
  [o1a .* a1a + o1b .* a1b;...
  o2a .* a2a + o2b .* a2b;...
  o3a .* a3a + o3b .* a3b]),2));


%%
if antipodal
  area = sum(reshape(area,[],2),2);
end

%% compute orientation of a spherical triangle
function o = vertices2Orientation ( a, b, c )

%  Centroid.
cd = ( a + b + c ) ./ 3.0;

%  Cross product ( C - B ) x ( A - B );
cp = cross(c-b,a-b);
  
%  Compare the directions.
o = 1 - 2 * (dot(cp,cd) < 0);

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



