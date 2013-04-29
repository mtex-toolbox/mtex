function v = subsref(v,s)
%overloads subsref

if isstruct(s)
  v.x = subsref(v.x,s);
  v.y = subsref(v.y,s);
  v.z = subsref(v.z,s);
else
  v.x = v.x(s);
  v.y = v.y(s);
  v.z = v.z(s);  
end
