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

elseif isa(a,'symmetry') && isa(b,'orientation')
  % if right is an orientation this should be handled by orientation.mtimes
  
  % symmetry times orientation
  r = inv(mtimes(inv(b),inv(a))).';
  
elseif isa(b,'quaternion')

  % ensure that both have an inversion flag
  a = rotation(a);
  b = rotation(b);
  
  r = mtimes@quaternion(a,b);
  r.i = bsxfun(@xor,a.i(:),b.i(:).');
 
else
  
  r = rotate_outer(b,a);
  
end
    
  
    
end
