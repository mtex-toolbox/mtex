function m = min(T)

[e,v] = eig(T);
m = min(diag(v));