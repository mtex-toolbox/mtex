function [a,b,c,d,i] = double(q)
% quaternion to double

if nargout >= 4
  a = q.a;
  b = q.b;
  c = q.c;
  d = q.d;
  if nargout == 5, i = false(size(a)); end
elseif nargout == 1
  a = cat(length(size(q.a))+1,q.a,q.b,q.c,q.d);
elseif nargout == 0
  a = cat(length(size(q.a))+1,q.a,q.b,q.c,q.d);
end
