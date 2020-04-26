function m = multiplicity(f,varargin)
% directions symmetrically equivalent to m
%
% Syntax
%   m = multiplicity(f)
%
% Input
%  f - @fibre
%
% Output
%  m - integer
%


[~,m] = symmetrise(f,'unique');

m = numSym(f.CS) * numSym(f.SS) ./ m;