function r = times(a,b)
% orientation times Miller and quaternion times orientation


if isa(a,'orientation') && isa(b,'vector3d')
  
  if isa(b,'Miller'), b = set(b,'CS',a.CS);end
  
  r = a.rotation .* vector3d(b);
   
elseif isa(a,'quaternion') && isa(b,'quaternion')
    
  if isa(a,'orientation')
    r = a;
    a = a.rotation;
    if isa(b,'orientation')
      
      % check that symmetries are ok
      if r.CS ~= b.SS
        warning('MTEX:Orientation','Symmetry mismatch!');
      end
      r.CS = b.CS;
      b = b.rotation;
    else
      
      if length(r.CS) > 1
        warning('MTEX:Orientation','Symmetry lost!');
        r.CS = symmetry;
      end
    end
  else
    r = b;
    b = b.rotation;
    if length(r.SS) > 1
      warning('MTEX:Orientation','Symmetry mismatch!');
      r.ss = symmetry;
    end
  end
  
  r.rotation = a .* b;
    
else
  
  error([class(a) ' * ' class(b) ' is not defined!'])
    
end
