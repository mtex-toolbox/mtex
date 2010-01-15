function r = mtimes(a,b)
% orientation times Miller and quaternion times orientation


if isa(a,'orientation') && isa(b,'vector3d')
  
  if isa(b,'Miller'), b = set(b,'CS',a.cs);end
  
  r = diag(a.i) * (a.quaternion * vector3d(b));
   
elseif isa(a,'quaternion') && isa(b,'orientation')
    
  r = b;
  r.quaternion = a * b.quaternion;
    
else
  
  error([class(a) ' * ' class(b) ' is not defined!'])
    
end
