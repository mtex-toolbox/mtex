function m = subsasgn(m,s,b)
% overloads subsasgn

if isempty(m), m = Miller;end
m.vector3d = subsasgn(m.vector3d,s,b.vector3d);
