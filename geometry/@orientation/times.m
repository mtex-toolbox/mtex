function r = times(a,b)
% orientation times Miller and quaternion times orientation


if isa(a,'orientation') && isa(b,'vector3d')
  
  if isa(b,'Miller'), b = set(b,'CS',a.CS);end
  
  r = a.i .* (a.quaternion .* vector3d(b));
   
elseif isa(a,'quaternion') && isa(b,'quaternion')
    
  if isa(a,'orientation')
    r = a;
    if isa(b,'orientation')
      r.i = a.i .* b.i;
      % check that symmetries are ok
      if a.SS ~= b.CS
        warning('MTEX:Orientation','Symmetry mismatch!');
      end
      r.CS = b.SS;      
    else
      r = b;
      if length(r.CS) > 1
        warning('MTEX:Orientation','Symmetry mismatch!');
        r.CS = symmetry;
      end
    end
  else
    r = b;
    if length(r.SS) > 1
      warning('MTEX:Orientation','Symmetry mismatch!');
      r.ss = symmetry;
    end
  end
  
  r.quaternion = quaternion(a) .* quaternion(b);  
    
else
  
  error([class(a) ' * ' class(b) ' is not defined!'])
    
end
