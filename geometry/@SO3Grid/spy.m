function spy(N)
% spy distance matrix

spy(dot_outer(N,N,'epsilon',2*N.res));
