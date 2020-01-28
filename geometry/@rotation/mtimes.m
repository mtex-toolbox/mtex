function r = mtimes(a,b,varargin)
% r = a * b

% multiplication with -1 -> inversion
if isnumeric(a) 
  assert(all(abs(a(:))==1),'Rotations can be multiplied only by 1 or -1');
  tmp = rotation.id(size(a));
  tmp.i = (1-a)./2;
  a = tmp;
end  

if isnumeric(b)
  assert(all(abs(b(:))==1),'Rotations can be multiplied only by 1 or -1');
  tmp = rotation.id(size(b));
  tmp.i = (1-b)./2;
  b = tmp;
end  

if isa(b,'vector3d')
  
  % apply rotation
  r = rotate_outer(b,a);
  
elseif isa(b,'quaternion')

  r = mtimes@quaternion(a,b,varargin{:});
 
else
  
  r = rotate_outer(b,a);
  
end
    
end
