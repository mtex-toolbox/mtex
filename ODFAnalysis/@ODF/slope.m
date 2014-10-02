function Z = slope(odf,h,r,varargin)
% | grad(r) |

d = 10e-5;

v = vector3d(r);

sz = length(v);
ndx = @(n) (n*sz+1):(n+1)*sz;

% directions
dx = d*xvector; dy = d*yvector; dz = d*zvector;
dxyz = [v-dx v+dx v-dy v+dy v-dz v+dz];

% gradient
D = odf.calcPDF(h,dxyz);
dv = @(n) (D(ndx(2*(n)))-D(ndx(2*(n)+1)))./(d*2);
v = vector3d(dv(0),dv(1),dv(2));

% slope
Z = norm(v);
