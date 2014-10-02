function [n,pairs] = neighbors(grains)
% returns the number of neighboring grains
%
%% Input
% grains - @GrainSet
%% Output
% n     - number of neighbors per grain
% pairs - index list of size N x 2, where  
%    $$N = 2 \sum n_i $$
%    is the total number of neighborhood relations (without self--reference).
%
%    pairs(i,:) give the indexes of two neighbored grains, i.e 
%
%     neighbor_gr = grains(pairs(1,:))
%
%    selects two neighbored grains.
%
s = logical(grains);

A_G = grains.A_G(s,s);
A_G = A_G | A_G' - diag(diag(A_G));

[a,b,n] = find(sum(A_G,2));
[a,b] = find(triu(A_G,1));
pairs = [a,b];
