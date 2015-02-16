function r = mtimes(a,b)
% r = a * b

% multiplication with -1 -> inversion
if isnumeric(a) 
  assert(all(abs(a(:))==1),'Rotations can be multiplied only by 1 or -1');
  tmp = rotation(idquaternion(size(a)));
  tmp(a==-1) = -tmp(a==-1);
  a = tmp;
end  

if isnumeric(b)
  assert(all(abs(b(:))==1),'Rotations can be multiplied only by 1 or -1');
  tmp = rotation(idquaternion(size(b)));
  tmp(b==-1) = -tmp(b==-1);
  b = tmp;
end  

if isa(b,'vector3d')
  
  % apply rotation
  r = rotate(b,a);
    
elseif isa(b,'quaternion')
  
  a = rotation(a);
  if isa(b,'orientation')
    if ~b.SS.id > 2 && any(max(dot_outer(b.SS,a))<0.99)      
      warning('Symmetry mismatch');
    end
    r = mtimes@quaternion(a,b);
    r.i = bsxfun(@xor,a.i(:),b.i(:).');
    r = orientation(r,b.CS,b.SS);
  else
    b = rotation(b);
    r = mtimes@quaternion(a,b);
    r.i = bsxfun(@xor,a.i(:),b.i(:).');
  end   
    
  
    
end
