function T = EinsteinSum(varargin)
% tensor multiplication according to Einstein summation convention
%
% Description
% This function computes a tensor product according to Einstein summation
% convention
%
% Syntax
%   % sumation against dimension 1 and 2
%   C = EinsteinSum(E,[1 -1 2 -2],v,-1,v,-2) 
%
%   eps = EinsteinSum(C,[-1 1 -2 2],sigma,[-1 -2])
%
% Input
%  T1,T2 - @tensor, @vector3d, @rotation
%  dimT1 - vector of indices giving the summation order in tensor 1
%  dimT2 - vector of indices giving the summation order in tensor 2
%
% Output
%  T - @tensor
%
% See also
%


t = tensor(varargin{1});
T = t.EinsteinSum(varargin{2:end});

end