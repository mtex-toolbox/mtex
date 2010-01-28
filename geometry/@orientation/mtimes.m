function r = mtimes(a,b)
% orientation times Miller and quaternion times orientation


if isa(a,'orientation') && isa(b,'vector3d')
  
  if isa(b,'Miller'), b = set(b,'CS',a.CS);end
  
  r = a.rotation * b;
   
elseif isa(a,'symmetry')
  
  if a ~= b.ss
    warning('MTEX:Orientation','Symmetry mismatch!');
  end
  r = b;
  r.rotation = quaternion(a) * b.rotation;
  r.ss = symmetry;
  
elseif isa(b,'symmetry')
  
  if a.CS ~= b
    warning('MTEX:Orientation','Symmetry mismatch!');
  end
  r = a;
  r.rotation = a.rotation * quaternion(b);
  r.CS = symmetry;
  
elseif isa(a,'quaternion') && isa(b,'quaternion')
    
  if isa(a,'orientation')
    r = a;
    if isa(b,'orientation')
      
      % check that symmetries are ok
      if a.CS ~= b.SS
        warning('MTEX:Orientation','Symmetry mismatch!');
      end
      r.CS = b.CS;
    else
      if length(r.CS) > 1
        warning('MTEX:Orientation','Symmetry mismatch!');
        r.CS = symmetry;
      end
    end
  else
    r = b;
    if length(r.SS) > 1
      warning('MTEX:Orientation','Symmetry mismatch!');
      r.SS = symmetry;
    end
  end
  
  r.rotation = rotation(quaternion(a) * quaternion(b));
    
else
  
  error([class(a) ' * ' class(b) ' is not defined!'])
    
end
