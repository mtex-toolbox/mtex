function d = subsref(T,s)
%overloads subsref

if T.rank == 4
  M = tensor42(T.M);
  d = subsref(M,s);
else
  d = subsref(T.M,s);
end