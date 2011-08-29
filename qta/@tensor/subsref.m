function d = subsref(T,s)
%overloads subsref

if T.rank == 4
  M = tensor42(T.M);
  d = subsref(M,s);
elseif T.rank==3
  M = tensor32(T.M);
  d = subsref(M,s);
else
  d = subsref(T.M,s);
end