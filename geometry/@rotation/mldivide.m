function r = mldivide(a,b)
% o \ v 

if isa(a,'rotation') && isa(b,'vector3d')
    
  n = 1:length(a.i);
  r = sparse(n,n,a.i) * (a.quaternion' * vector3d(b));
  
else
  
  error([class(a) ' \ ' class(b) ' is not defined!'])
    
end
