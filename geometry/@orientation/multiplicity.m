function m = multiplicity(mori,varargin)
% number of misorientations symmetrically equivalent to mori
%
% Description
% The size of the orbit of mori under the two symmetries, i.e. the number of
% distinct symmetrically equivalent representations.
%
% Up to MTEX 6 this returned the reciprocal quantity - the order of the
% stabilizer, i.e. the number of symmetry operations that fix mori. See
% https://github.com/mtex-toolbox/mtex/issues/2584.
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
% See also
% Miller/multiplicity fibre/multiplicity

m = length(unique(symmetrise(mori),'noSymmetry'));