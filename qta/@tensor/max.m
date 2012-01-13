function m = max(T)

[e,v] = eig(T);
m = max(diag(v));