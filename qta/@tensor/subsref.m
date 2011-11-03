function d = subsref(T,s)
%overloads subsref

if T.rank == 4 && numel(s.subs)==2
  M = tensor42(T.M);
  d = subsref(M,s);
elseif T.rank==3 && numel(s.subs)==2
  M = tensor32(T.M,isfield(T,'doubleconvention'));
  d = subsref(M,s);
else
  d = subsref(T.M,s);
end
