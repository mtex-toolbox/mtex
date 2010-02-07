function r = times(a,b)
% orientation times Miller and quaternion times orientation


if isa(a,'rotation') && isa(b,'vector3d')
  
  r = a.i .* (a.quaternion .* vector3d(b));
   
elseif isa(a,'quaternion') && isa(b,'quaternion')
    
  if isa(a,'rotation')
    r = a;
    a = a.quaternion;
    
    if isa(b,'rotation')
      r.i = r.i .* b.i;
      b = b.quaternion;      
    else      
      r.i = a.i .* ones(size(b));      
    end
  else
    r = b;
    b = b.quaternion;
    r.i = r.i .* ones(size(a));    
  end
  
  r.quaternion = a .* b;  
    
else
  
  error([class(a) ' * ' class(b) ' is not defined!'])
    
end
