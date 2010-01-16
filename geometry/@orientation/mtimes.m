function r = mtimes(a,b)
% orientation times Miller and quaternion times orientation


if isa(a,'orientation') && isa(b,'vector3d')
  
  if isa(b,'Miller'), b = set(b,'CS',a.cs);end
  
  r = diag(a.i) * (a.quaternion * vector3d(b));
   
elseif isa(a,'symmetry')
  
  if a ~= b.ss
    warning('MTEX:Orientation','Symmetry mismatch!');
  end
  r = b;
  r.quaternion = quaternion(a) * b.quaternion;
  r.ss = symmetry;
  
elseif isa(b,'symmetry')
  
  if a.cs ~= b
    warning('MTEX:Orientation','Symmetry mismatch!');
  end
  r = a;
  r.quaternion = a.quaternion * quaternion(b);
  r.cs = symmetry;
  
elseif isa(a,'quaternion') && isa(b,'quaternion')
    
  if isa(a,'orientation')
    r = a;
    if isa(b,'orientation')
      
      r.i = a.i * b.i;
      % check that symmetries are ok
      if a.cs ~= b.ss
        warning('MTEX:Orientation','Symmetry mismatch!');
      end
      r.cs = b.cs;
    else
      if length(r.cs) > 1
        warning('MTEX:Orientation','Symmetry mismatch!');
        r.cs = symmetry;
      end
    end
  else
    r = b;
    if length(r.ss) > 1
      warning('MTEX:Orientation','Symmetry mismatch!');
      r.ss = symmetry;
    end
  end
  
  r.quaternion = quaternion(a) * quaternion(b);
    
else
  
  error([class(a) ' * ' class(b) ' is not defined!'])
    
end
