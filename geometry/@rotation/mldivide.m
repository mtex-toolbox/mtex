function r = mldivide(a,b)
% o \ v 

if isa(a,'rotation') && isa(b,'vector3d')
    
  r = a.quaternion' * vector3d(b);
  
elseif isa(a,'quaternion') && isa(b,'quaternion')
  % a*r = b
  if isa(a,'rotation'), a = a.quaternion; end
  if isa(b,'rotation'), b = b.quaternion; end
  
  r = rotation(a\b);
  
else
  
  error([class(a) ' \ ' class(b) ' is not defined!'])
    
end
