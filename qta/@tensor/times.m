function T = times(T1,T2)
% multiply a tensor by a scalar

if isa(T1,'tensor') && isa(T2,'double')
  
  T = EinsteinSum(T1,1:T1.rank,T2,[]);
  
elseif isa(T2,'tensor') && isa(T1,'double')
  
  T = times(T2,T1);
  
elseif isa(T2,'tensor') && isa(T2,'tensor')
  
  if rank(T1) < rank(T2)
    r = size(T2.M);
    r(1:rank(T1)) = 1;
    T1.M = repmat(T1.M,r);
    T1.rank = T2.rank;
  elseif rank(T1) > rank(T2)
    r = size(T1.M);
    r(1:rank(T2)) = 1;
    T2.M = repmat(T2.M,r);
    T2.rank = T1.rank;
  end
  
  T = T1;
  T.M = T.M .* T2.M;
  
end
