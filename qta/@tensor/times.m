function T = times(T1,T2)
% multiply a tensor by a scalar

if isa(T1,'tensor') && isa(T2,'double')
  
  % copy argument
  T = T1;
  
  % reshape the scalar field
  s = size(T.M);
  shape = [ones(1,T.rank),s((T.rank+1):end)];
  if numel(T2) > 1, T2 = reshape(T2,shape);end
  
  % multiply
  T.M = mtimesx(T.M,T2);
  
elseif isa(T2,'tensor') && isa(T1,'double')
  
  T = times(T2,T1);
  
end
