function r = times(a,b)
% r = a .* b

if isnumeric(a)
  
  r = b;
  
  if all(abs(a(:))==1)
  
    r.i = xor(r.i,a==-1); 
    
  else
    
    error([class(a) ' * ' class(b) ' is not defined!']);
    
  end
      
elseif isnumeric(b)
  
  r = a;
  
  if all(abs(b(:))==1)
  
    r.i = xor(r.i,b==-1);
    
  else
    
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
