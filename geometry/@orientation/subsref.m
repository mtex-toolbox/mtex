function o = subsref(o,s)
% overloads subsref

o.quaternion = subsref(o.quaternion,s);
o.i = subsref(o.i,s);
