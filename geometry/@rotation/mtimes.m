function r = mtimes(a,b)
% orientation times Miller and quaternion times orientation


if isa(a,'orientation') && isa(b,'vector3d')
  
  if isa(b,'Miller'), b = set(b,'CS',a.CS);end
  
  r = diag(a.i) * (a.quaternion * b);
   
elseif isa(a,'symmetry')
  
  if a ~= b.ss
    warning('MTEX:Orientation','Symmetry mismatch!');
  end
  r = b;
  r.quaternion = quaternion(a) * b.quaternion;
  r.ss = symmetry;
  
elseif isa(b,'symmetry')
  
  if a.CS ~= b
    warning('MTEX:Orientation','Symmetry mismatch!');
  end
  r = a;
  r.quaternion = a.quaternion * quaternion(b);
  r.CS = symmetry;
  
elseif isa(a,'quaternion') && isa(b,'quaternion')
    
  if isa(a,'orientation')
    r = a;
    if isa(b,'orientation')
      
      r.i = a.i * b.i;
      % check that symmetries are ok
      if a.CS ~= b.SS
        warning('MTEX:Orientation','Symmetry mismatch!');
      end
      r.SS = b.CS;
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
  
  r.quaternion = quaternion(a) * quaternion(b);
    
else
  
  error([class(a) ' * ' class(b) ' is not defined!'])
    
end
