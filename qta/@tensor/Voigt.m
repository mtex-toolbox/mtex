function V = Voigt(T)

if T.rank == 4
  V = tensor42(T.M);
else
  error('requires a 4-rank tensor')
end