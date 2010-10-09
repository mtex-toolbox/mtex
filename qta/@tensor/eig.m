function [E,V] = eig(T)

if rank(T) == 4, T.M = tensor42(T.M); end
  %?? eigenvalues of 3 or 4 rank  tensors?

[E,V] = eig(T.M);