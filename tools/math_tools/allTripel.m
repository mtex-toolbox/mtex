function [x,y,z] = allTripel(d)
% all tripel of elements of x and y modulo permutation
%

[x,y,z] = meshgrid(1:length(d));

ind = x <= y & y <= z;

x = x(ind);
y = y(ind);
z = z(ind);

if nargout <= 1, x = [x(:),y(:),z(:)]; end
