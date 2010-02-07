function r = mldivide(a,b)
% o \ v 

if isa(a,'rotation') && isa(b,'vector3d')
    
  r = a.quaternion' * vector3d(b);
  
else
  
  error([class(a) ' \ ' class(b) ' is not defined!'])
    
end
