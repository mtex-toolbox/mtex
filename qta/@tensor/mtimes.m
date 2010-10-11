function T = mtimes(T1,T2)
% implements T1 * T2

if isa(T1,'double')
  
  T = T2;
  T.M = T1*T.M;
  
elseif isa(T2,'double')
  
  T = T1;
  T.M = T.M * T2;
else
  
  error('Wrong type! For tensor product use the command EinsteinSum!')
  
end
