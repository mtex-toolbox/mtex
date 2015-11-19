function [x,y,z] = allTriple(d)
% all triple of elements of x and y modulo permutation
%

[x,y,z] = meshgrid(1:length(d));

ind = x <= y & y <= z;

x = x(ind);
y = y(ind);
z = z(ind);

if nargout <= 1, x = [x(:),y(:),z(:)]; end
