function T = transpose(T)
% transpose a list of a tensors
%
% If T is a m x n list of rank r tensors so T.' is a n x m list of rank r
% tensors.
%
% Syntax
%   T_transpose = T.'
%
% Input
%  T - @tensor
% 
% Output
%  T_transpose - @tensor
%

T.M = permute(T.M,[1:T.rank T.rank + [2 1] (T.rank + 3):ndims(T.M)]);
  