function out = rdivide(T,S)

if isa(S,'double') 
  
  T.M = T.M / S;
  out = T;
    
elseif isa(S,'tensor')
  
  T.M = T.M ./ S.M;
  out = T;
  
end
