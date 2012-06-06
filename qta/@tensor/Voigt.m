function V = Voigt(T)

if T.rank == 4
  V = tensor42(T.M,T.doubleConvention);
elseif T.rank == 3
  V = tensor32(T.M,T.doubleConvention);
else
  error('requires a 3-rank or 4-rank tensor')
end
