function m = subsref(m,s)
% overloads subsref

m.vector3d = subsref(m.vector3d,s);
