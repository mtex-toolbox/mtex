function r = times(a,b)
% r = a .* b


if isa(a,'rotation') && isa(b,'vector3d')
  
  r = a.quaternion .* vector3d(b);
  
  if ~isempty(a.inversion)
    ind = a.inversion<0;
    r(ind) = -r(ind);
  end
   
elseif isa(a,'quaternion') && isa(b,'quaternion')
    
  if isa(a,'rotation')
    r = a;
    a = a.quaternion;
    
    if isa(b,'rotation')
      b = b.quaternion; 
      if ~isempty(b.inversion)
        if isempty(a.inversion)
          r.inversion = b.inversion;
        else
          r.inversion = a.inversion .* b.inversion;
        end
      end
    end
  else
    r = b;
    b = b.quaternion;
  end
  
  r.quaternion = a .* b;  
    
else
  
  error([class(a) ' * ' class(b) ' is not defined!'])
    
end
