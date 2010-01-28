function o = subsasgn(o,s,b)
% overloads subsasgn


if isa(b,'orientation')
  
  o.quaternion = subsasgn(o.quaternion,s,b.quaternion);
  o.i = subsasgn(o.i,s,b.i);
  
elseif isa(b,'quaternion')
  
  o.quaternion = subsasgn(o.quaternion,s,b);
  o.i = subsasgn(o.i,s,1);
  
elseif isempty(b)
  
  o.quaternion = subsasgn(o.quaternion,s,[]);
  o.i = subsasgn(o.i,s,[]);
  
else
  error('value must be of type orientation or quaternion');
end
