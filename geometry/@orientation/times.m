function r = times(a,b)
% rotation times vector3d and rotation times rotation

if isa(a,'rotation')
  
  if isa(b,'rotation')
    
    r = a;
    r.quaternion = a.quaternion .* b.quaternion;
    r.i = a.i .* b.i;
    
  elseif isa(b,'quaternion')
    
    r = a;
    r.quaternion = a.quaternion .* b;
    if numel(r.i) == 1
      r.i = repmat(r.i,size(b));
    end
    
  elseif isa(b,'vector3d')
    
    r = a.i .* (a.quaternion .* b);
    
  elseif isa(b,'double')
    
    r = a;
    r.i = r.i .* b;
    
  else 
    
    error('Type mismatch!')
    
  end
  
else
  
  if isa(a,'quaternion')
    
    r = b;
    r.quaternion = a .* b.quaternion;
    if numel(r.i) == 1
      r.i = repmat(r.i,size(a));
    end
        
  elseif isa(a,'double')
    
    r = b;
    r.i = a .* r.i; 
    
  else 
    
    error('Type mismatch!')
    
  end    
end
