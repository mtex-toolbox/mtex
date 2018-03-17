function T = dyad(v,varargin)
% dyadic tensor product 
%
% Synatx
%
%   T = dyad(v1,v2)
%   T = dyad(v1,2)
%
% Input
%  v1,v2 - @vector3d
%  n - power
%
% Output
%  T - @tensor
%

T = dyad(tensor(v),varargin{:});