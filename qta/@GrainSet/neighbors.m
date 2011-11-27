function [n,pairs] = neighbors(grains)


s = any(grains.I_DG,1);

A_G = grains.A_G(s,s);
A_G = A_G | A_G';
[a,b,n] = find(sum(A_G,2));
[a,b] = find(triu(A_G,1));
pairs = [a,b];