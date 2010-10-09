function d = subsref(T,s)
%overloads subsref

if T.rank == 4,  T.M = tensor42(T.M); end

d = subsref(T.M,s);

if T.rank == 4,  T.M = tensor24(T.M); end
