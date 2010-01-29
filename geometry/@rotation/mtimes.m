function r = mtimes(a,b)
% rotation times vector3d and rotation times rotation

if isa(a,'rotation')
  
  if isa(b,'rotation')
    
    r = a;
    r.quaternion = a.quaternion * b.quaternion;
    r.i = a.i * b.i;
    
  elseif isa(b,'quaternion')
    
    r = a;
    r.quaternion = a.quaternion * b;
    r.i = repmat(r.i(:),numel(b),1);    
    
  elseif isa(b,'vector3d')
    
    n = 1:length(a.i);
    r = sparse(n,n,a.i) * a.quaternion * b;
    
  elseif isa(b,'double')
    
    r = a;
    r.i = r.i * b;
    
  else 
    
    error('Type mismatch!')
    
  end
  
else
  
  if isa(a,'quaternion')
    
    r = b;
    r.quaternion = a * b.quaternion;
    r.i = repmat(r.i(:).',numel(a),1);
        
  elseif isa(a,'double')
    
    r = b;
    r.i = a * r.i; 
    
  else 
    
    error('Type mismatch!')
    
  end    
end
