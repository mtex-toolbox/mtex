function [E,V] = eig(T)
% compute the eigenvalues and eigenvectors of a tensor

switch rank(T)

  case 1
  case 2
    [E,V] = eig(T.M);
  case 3
  case 4
    M = tensor42(T.M);
    [E,V] = eig(M)
end