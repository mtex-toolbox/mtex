function [nx,ny,nz]=quaternion_mtimes(a,b,c,d,x,y,z)
% quaternionen multiplication q * v

n = b.^2 + c.^2 + d.^2;
s = b*x + c*y + d*z;
l = length(a);
da = spdiags(a,0,l,l);

nx = 2*da * (c * z - d * y) + 2*spdiags(b,0,l,l)*s + (a.^2 - n) * x;
ny = 2*da * (d * x - b * z) + 2*spdiags(c,0,l,l)*s + (a.^2 - n) * y;
nz = 2*da * (b * y - c * x) + 2*spdiags(d,0,l,l)*s + (a.^2 - n) * z;
	
