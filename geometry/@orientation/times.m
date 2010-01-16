function r = times(a,b)
% orientation times Miller and quaternion times orientation


if isa(a,'orientation') && isa(b,'vector3d')
  
  if isa(b,'Miller'), b = set(b,'CS',a.cs);end
  
  r = a.i .* (a.quaternion .* vector3d(b));
   
elseif isa(a,'quaternion') && isa(b,'quaternion')
    
  if isa(a,'orientation')
    r = a;
    if isa(b,'orientation')
      r.i = a.i .* b.i;
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
  
  r.quaternion = quaternion(a) .* quaternion(b);  
    
else
  
  error([class(a) ' * ' class(b) ' is not defined!'])
    
end
