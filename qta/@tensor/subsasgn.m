function T = subsasgn(T,s,b)
% overloads subsasgn

if T.rank == 4,  T.M = tensor42(T.M); end

T.M = subsasgn(T.M,s,b);

if T.rank == 4,  T.M = tensor24(T.M); end