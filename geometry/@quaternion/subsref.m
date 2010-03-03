function q = subsref(q,s)
% overloads subsref

if isa(s,'double') || isa(s,'logical')
  q.a = q.a(s);
  q.b = q.b(s);
  q.c = q.c(s);
  q.d = q.d(s);
else
  q.a = subsref(q.a,s);
  q.b = subsref(q.b,s);
  q.c = subsref(q.c,s);
  q.d = subsref(q.d,s);
end
