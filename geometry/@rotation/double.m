function [a,b,c,d,i] = double(rot)
% quaternion to double

if nargout >= 4
  a = rot.a;
  b = rot.b;
  c = rot.c;
  d = rot.d;
  if nargout == 5, i = rot.i; end
elseif nargout == 1
  a = cat(length(size(rot.a))+1,rot.a,rot.b,rot.c,rot.d);
elseif nargout == 0
  a = cat(length(size(rot.a))+1,rot.a,rot.b,rot.c,rot.d);
end
