function r = mtimes(a,b)
% rotation times vector3d and rotation times rotation

if isnumeric(a)
  
  if a == -1
    
    r = -b;
    
  elseif a ~= 1
    
    error([class(a) ' * ' class(b) ' is not defined!']);
    
  end
      
elseif isnumeric(b)
  
  if b == -1
    
    r = -a;
    
  elseif b ~= 1
    
    error([class(a) ' * ' class(b) ' is not defined!']);
    
  end
  
elseif isa(b,'vector3d')
  
  % apply rotation
  r = rotate(b,a);
    
elseif isa(b,'quaternion')
  
  a = rotation(a);
  b = rotation(b);
    
  r = mtimes@quaternion(a,b);
  r.i = bsxfun(@xor,a.i(:),b.i(:).');
    
end
