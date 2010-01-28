function o = subsref(o,s)
% overloads subsref

o.quaternion = subsref(o.quaternion,s);

if isa(s,'double') || isa(s,'logical')
  o.i = o.i(s);
else
  o.i = subsref(o.i,s);
end
