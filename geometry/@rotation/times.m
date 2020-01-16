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
  
  % quaternion multiplication
  r = times@quaternion(a,b);
    
  % apply inversion
  try ai = a.i; catch, ai = false(size(a)); end
  try bi = b.i; catch, bi = false(size(b)); end
  r.i = xor(ai,bi);
  
  if isa(b,'orientation') % rotA * oriB
    if b.SS.id > 2 && any(max(dot_outer(b.SS,a))<0.99)
      warning('Symmetry mismatch');
    end
 
    r = orientation(r,b.CS,b.SS);
        
  end
  
else % rot * Miller, rot * tensor, rot * slipSystem
 
    r = rotate(b,a);
    
end
  
end
