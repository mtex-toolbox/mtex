function r = mtimes(a,b)
% r = a * b

% multiplication with -1 -> inversion
if isnumeric(a) 
  assert(all(abs(a(:))==1),'Rotations can be multiplied only by 1 or -1');
  tmp = rotation(rotation.id(size(a)));
  tmp.i = (1-a)./2;
  a = tmp;
end  

if isnumeric(b)
  assert(all(abs(b(:))==1),'Rotations can be multiplied only by 1 or -1');
  tmp = rotation(rotation.id(size(b)));
  tmp.i = (1-b)./2;
  b = tmp;
end  

if isa(b,'vector3d')
  
  % apply rotation
  r = rotate_outer(b,a);
    
elseif isa(b,'quaternion')
  
  a = rotation(a);
  if isa(b,'orientation')
    if b.SS.id > 2 && any(max(dot_outer(b.SS,a))<0.99)
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
