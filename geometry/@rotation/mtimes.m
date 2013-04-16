function r = mtimes(a,b)
% r = a * b

% multiplication with -1 -> inversion
if isnumeric(a) && all(abs(a(:))==1)
  tmp = rotation(idquaternion(size(a)));
  tmp(a==-1) = -tmp(a==-1);
  a = tmp;
end  

if isnumeric(b) && all(abs(b(:))==1)
  tmp = rotation(idquaternion(size(b)));
  tmp(b==-1) = -tmp(b==-1);
  b = tmp;
end  

if isa(b,'vector3d')
  
  % apply rotation
  r = rotate(b,a);
    
elseif isa(b,'quaternion')
  
  a = rotation(a);
  b = rotation(b);
    
  r = mtimes@quaternion(a,b);
  r.i = bsxfun(@xor,a.i(:),b.i(:).');
    
end
