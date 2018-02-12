function r = times(a,b)
% r = a .* b

if isnumeric(a) % (-1) * rot -> inversion
  
  assert(all(abs(a(:))==1),'Rotations can be multiplied only by 1 or -1');
  r = b;
  r.a = r.a .* ones(size(a));
  r.b = r.b .* ones(size(a));
  r.c = r.c .* ones(size(a));
  r.d = r.d .* ones(size(a));
  r.i = xor(b.i,a==-1);
  
elseif isnumeric(b) % rot * (-1) -> inversion
  
  assert(all(abs(b(:))==1),'Rotations can be multiplied only by 1 or -1');
  r = a;
  r.i = xor(r.i,b==-1);
  
elseif isa(b,'quaternion') % rotA * rotB
  
  % cast to rotation
  a = rotation(a);
  if isa(b,'orientation') % rotA * oriB
    if ~b.SS.id > 2 && any(max(dot_outer(b.SS,a))<0.99)      
      warning('Symmetry mismatch');
    end
    
    % apply proper rotation
    r = times@quaternion(a,b);
    
    % apply inversion
    r.i = xor(a.i,b.i);
    
    r = orientation(r,b.CS,b.SS);
    
  else % rotA * rotB
    
    b = rotation(b);
    
    % apply proper rotation
    r = times@quaternion(a,b);
    
    % apply inversion
    r.i = xor(a.i,b.i);
  end
  
else % rot * Miller, rot * tensor, rot * slipSystem
 
    r = rotate(b,a);
    
end
  
end
