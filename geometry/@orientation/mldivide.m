function r = mldivide(a,b)
% o \ v 

if isa(a,'orientation') && isa(b,'vector3d')
    
  r = Miller(diag(a.i) * (a.quaternion' * vector3d(b)),a.cs);
  
else
  
  error([class(a) ' \ ' class(b) ' is not defined!'])
    
end
