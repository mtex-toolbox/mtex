function T = plus(T1,T2)
% add two tensors

if ~isa(T1,'tensor'), [T1,T2] = deal(T1,T2); end

T = T1;
if isa(T2,'tensor')
  T.M = T.M + T2.M;
else
  
  if T1.rank == 4 && size(T2,1) == 6 && size(T2,2) == 6
    T.M = tensor24(matrix(T1,'Voigt') + T2,T1.doubleConvention);
  else
    T.M = T.M + reshape(T2,[ones(1,T1.rank),size(T2)]);
  end
end

end