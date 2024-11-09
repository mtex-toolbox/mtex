function v = origin(plane)
% returns one possible plane origin ("Stuezvektor", point within the plane)
%
% Syntax
%   v = origin(plane)
%
% Input
%
% See also
% 

v = vector3d.zeros(size(plane));

a = plane.a~=0;
b = plane.b~=0;

v(a) = vector3d(plane.d(a)./plane.a(a),0,0);
if ~all(a)
  v(~a&b) = vector3d(0,plane.d(~a&b)./plane.b(~a&b),0);
  if ~all(~a&b)
    v(~a&~b) = vector3d(0,0,plane.d(~a&~b)./plane.c(~a&~b));
  end
end

