function v = subsref(v,s)
%overloads subsref

if isa(s,'double') || isa(s,'logical')
  v.x = v.x(s);
  v.y = v.y(s);
  v.z = v.z(s);
else
  v.x = subsref(v.x,s);
  v.y = subsref(v.y,s);
  v.z = subsref(v.z,s);
end
