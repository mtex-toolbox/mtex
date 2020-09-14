function C = colon(A,B)
% double dot A:B between two tensors
%
% Syntax
%   C = A:B
%
% Description 
%
% $$ (A:B)_{i_1,\ldots,j_n,j_1,\ldots,j_m} = \sum_{k,l} A_{i_1,\ldots,i_n,k,l} B_{k,l,j_1,\ldots,j_m} $$
%

id1 = [1:A.rank-2,-1,-2];
id2 = [-1,-2,A.rank-2 + (1:B.rank-2)];
C = EinsteinSum(A,id1,B,id2);
