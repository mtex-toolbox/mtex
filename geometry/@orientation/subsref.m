function rot = subsref(rot,s)
% overloads subsref

rot.quaternion = subsref(rot.quaternion,s);

if isa(s,'double') || isa(s,'logical')
  rot.i = rot.i(s);
else
  rot.i = subsref(rot.i,s);
end
