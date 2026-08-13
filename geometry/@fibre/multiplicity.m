function m = multiplicity(f,varargin)
% number of fibres symmetrically equivalent to f
%
% Description
% The size of the orbit of f under the crystal and specimen symmetry, i.e.
% the number of distinct symmetrically equivalent fibres.
%
% Up to MTEX 6 this returned the reciprocal quantity - the order of the
% stabilizer, i.e. the number of symmetry operations that fix f. See
% https://github.com/mtex-toolbox/mtex/issues/2584.
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
% See also
% Miller/multiplicity orientation/multiplicity


[~,m] = symmetrise(f,'unique');