function r = times(a,b)
% r = a .* b

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
  
elseif isa(a,'rotation') && isa(b,'vector3d')
  
  % apply proper rotation
  r = times@quaternion(a,b);
  
  % apply inversion
  r(a.i) = -r(a.i);

else
  
  % cast to rotation
  a = rotation(a);
  b = rotation(b);
  
  % apply proper rotation
  r = times@quaternion(a,b);
    
  % apply inversion
  r.i = xor(a.i,b.i);
    
end
