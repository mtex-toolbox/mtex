function n = ndims(T)
% overloads size

n = max(2,ndims(T.M) - T.rank);

