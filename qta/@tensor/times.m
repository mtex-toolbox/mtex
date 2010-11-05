function T = times(T1,T2)
% multiply a tensor by a scalar

if isa(T1,'tensor') && isa(T2,'double')
  
  % copy argument
  T = T1;
  r = T.rank;
  s = size(T.M);
  
  % reshape tensor
  T.M = reshape(T.M,[prod(s(1:r)) 1 prod(s(r+1:end))]);
  
  % reshape the scalar field
  shape = [1 1,prod(s(r+1:end))];
  if numel(T2) > 1, T2 = reshape(T2,shape);end
     
  % multiply
  T.M = mtimesx(T.M,T2);
  
  % reshape tensor back
  T.M = reshape(T.M,s);
  
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
