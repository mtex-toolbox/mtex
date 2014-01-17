function T = minus(T1,T2)
% add two tensors

if isa(T1,'tensor')
  T = T1;
  if isa(T2,'tensor')
    T.M = T.M - T2.M;
  else
    T.M = T.M - T2;
  end
else
  T = T2;
  if isa(T1,'tensor')
    T.M = T1.M - T.M;
  else
    T.M = T1 - T.M;
  end
end