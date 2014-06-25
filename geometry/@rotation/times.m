function r = times(a,b)
% r = a .* b

if isnumeric(a) 

  % multiplication with -1 -> inversion
  assert(all(abs(a(:))==1),'Rotations can be multiplied only by 1 or -1');
  r = b; 
  r.i = xor(r.i,a==-1);
  
elseif isnumeric(b)
  
  % multiplication with -1 -> inversion
  assert(all(abs(b(:))==1),'Rotations can be multiplied only by 1 or -1');
  r = a;
  r.i = xor(r.i,b==-1);
  
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
