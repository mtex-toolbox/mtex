function T = EinsteinSum(q,varargin)
% tensor multiplication according to Einstein summation
%
% Description
% This function computes a tensor product according to Einstein summation
% convention
%
% Syntax
%   % sumation against dimension 1 and 2
%   C = EinsteinSum(E,[1 -1 2 -2],v,-1,v,-2) 
%
% Input
%  T1,T2 - @tensor
%  dimT1 - vector of indices giving the summation order in tensor 1
%  dimT2 - vector of indices giving the summation order in tensor 2
%
% Output
%  q - @quaternion
%
% See also
%

T = EinsteinSum(tensor(q).varargin{:});