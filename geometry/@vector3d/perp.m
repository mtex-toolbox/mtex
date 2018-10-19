function N = perp(v)
% conmpute an vector best orthogonal to a list of directions

[N,~] = eig3(v*v);
N = N.subSet(1);
