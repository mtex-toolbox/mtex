function o = subsasgn(o,s,b)
% overloads subsasgn


if isa(b,'orientation')
  
  o.rotation = subsasgn(o.rotation,s,b.rotation);
    
elseif isa(b,'quaternion')
  
  o.rotation = subsasgn(o.rotation,s,b);
    
elseif isempty(b)
  
  o.rotation = subsasgn(o.rotation,s,[]);
    
else
  error('value must be of type orientation or quaternion');
end
