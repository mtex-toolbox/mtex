function r = mtimes(a,b)
% rotation times vector3d and rotation times rotation

if isa(a,'rotation')
  
  a = rotation(a);
  
  if isa(b,'rotation')
    
    r = a;
    r.quaternion = a.quaternion * b.quaternion;
    if ~(isempty(a.inversion) && isempty(b.inversion))
      
      if isempty(a.inversion), a.inversion = ones(size(a.quaternion)); end
      if isempty(b.inversion), b.inversion = ones(size(b.quaternion)); end
      
      r.inversion = a.inversion(:) * b.inversion(:).';
      
    end
        
  elseif isa(b,'quaternion')
    
    r = a;
    r.quaternion = a.quaternion * b;
    
  elseif isa(b,'vector3d')
    
    r = rotate(b,a);
        
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
