function r = mtimes(a,b)
% rotation times vector3d and rotation times rotation

if isa(a,'rotation')
  
  a = rotation(a);
  
  if isa(b,'rotation')
    
    r = a;
    r.quaternion = a.quaternion * b.quaternion;
        
  elseif isa(b,'quaternion')
    
    r = a;
    r.quaternion = a.quaternion * b;
    
  elseif isa(b,'vector3d')
    
    r = a.quaternion * b;
    
  else
    
    error('Type mismatch!')
    
  end
  
else
  
  if isa(a,'quaternion')
    
    r = rotation(b);
    r.quaternion = a * b.quaternion;
            
  else
    
    error('Type mismatch!')
    
  end
end
