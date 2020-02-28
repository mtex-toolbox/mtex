function m = multiplicity(mori,varargin)
% multiplicity of a misorientation
%
% Syntax
%   m = multiplicity(mori)
%
% Input
%  mori - mis@orientation
%
% Output
%  m - integer
%

[~,m] = symmetrise(mori,'unique');

m = numSym(mori.CS) * numSym(mori.SS) ./ m;