function bM = subSet(bM,ind)
% indexing of quaternions
%
% Syntax
%   subSet(q,ind) % 
%

bM.mori = bM.mori(ind);
bM.N1 = bM.N1(ind);
