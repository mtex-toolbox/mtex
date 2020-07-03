function area = sphericalTriangleArea (va,vb,vc)
% compute the area of a spherical triangle given by its vertices

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
n_ab = n_ab.subSet(nd)./l2n_ab(nd);
n_bc = n_bc.subSet(nd)./l2n_bc(nd);
n_ca = n_ca.subSet(nd)./l2n_ca(nd);

% Girard's formula. A+B+C-pi, with angles  A,B,C between the great circles
area = zeros(size(nd));
area(nd) = ...
  acos(dot(n_ab,-n_bc,'noSymmetry'))+...
  acos(dot(n_bc,-n_ca,'noSymmetry'))+...
  acos(dot(n_ca,-n_ab,'noSymmetry'))- pi;
