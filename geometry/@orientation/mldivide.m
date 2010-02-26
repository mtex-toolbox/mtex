function r = mldivide(a,b)
% o \ v 


if isa(b,'vector3d')

  r = Miller(a.rotation \ b,a.CS);

elseif isa(a,'orientation') && isa(b,'orientation')
  % solve (a*q = b) modulo symmetry
  
  r = a' * b;
  
elseif isa(a,'orientation') && ~isa(b,'orientation') && isa(b,'quaternion')
  r = a \ orientation(b,a.CS,a.SS);
elseif isa(b,'orientation') && ~isa(a,'orientation') && isa(a,'quaternion')
  r = orientation(a,b.CS,b.SS) \ b;
else
  
  error([class(a) ' \ ' class(b) ' is not defined!'])
  
end
