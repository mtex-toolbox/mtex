function r = times(a,b)
% orientation times Miller and quaternion times orientation


if isa(a,'rotation') && isa(b,'vector3d')
  
  r = a.quaternion .* vector3d(b);
   
elseif isa(a,'quaternion') && isa(b,'quaternion')
    
  if isa(a,'rotation')
    r = a;
    a = a.quaternion;
    
    if isa(b,'rotation'), b = b.quaternion; end
  else
    r = b;
    b = b.quaternion;
  end
  
  r.quaternion = a .* b;  
    
else
  
  error([class(a) ' * ' class(b) ' is not defined!'])
    
end
