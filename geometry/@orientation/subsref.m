function o = subsref(o,s)
% overloads subsref

o.rotation = subsref(o.rotation,s);

