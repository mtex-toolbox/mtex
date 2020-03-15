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

m = numSym(mori.CS) * numSym(mori.SS) ./ ...
  length(unique(symmetrise(mori),'noSymmetry'));