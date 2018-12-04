function C = colon(A,B)
% double dot A:B between two tensors
%
% Syntax
%   C = A:B
%

id1 = [1:A.rank-2,-1,-2];
id2 = [-1,-2,A.rank-2 + (1:B.rank-2)];
C = EinsteinSum(A,id1,B,id2);
