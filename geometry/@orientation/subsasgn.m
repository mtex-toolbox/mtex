function rot = subsasgn(rot,s,b)
% overloads subsasgn


if isa(b,'rotation')
  
  rot.quaternion = subsasgn(rot.quaternion,s,b.quaternion);
  rot.i = subsasgn(rot.i,s,b.i);
  
elseif isa(b,'quaternion')
  
  rot.quaternion = subsasgn(rot.quaternion,s,b);
  rot.i = subsasgn(rot.i,s,1);
  
elseif isempty(b)
  
  rot.quaternion = subsasgn(rot.quaternion,s,[]);
  rot.i = subsasgn(rot.i,s,[]);
  
else
  error('value must be of type orientation or quaternion');
end
