function r = mtimes(a,b,varargin)
% maximal n-fold of symmetry axes

if isa(a,'symmetry')

  if a.id == 1
    
    r = reshape(b,1,[]);
  
  elseif isa(b,'orientation')
    r = mtimes(a.rot,b,1);
  elseif isa(b,'quaternion')
    r = mtimes(a.rot,b,0);
  else
    r = rotate_outer(b,a.rot);
  end
  
else
  
  r = mtimes(a,b.rot,1);

end
