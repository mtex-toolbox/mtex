function n = multiplicity(m,varargin)
% number of directions symmetrically equivalent to m
%
% Description
% The multiplicity of a crystal direction is the size of its orbit under the
% crystal symmetry, i.e. the number of distinct symmetrically equivalent
% directions - 6 for {100}, 12 for {110}, 8 for {111} and 48 for {321} in
% m-3m. This is the multiplicity as the term is used crystallographically,
% e.g. the factor scaling the intensity of a reflection in powder
% diffraction.
%
% Up to MTEX 6 this returned the reciprocal quantity, numSym(CS)/n, i.e. the
% order of the stabilizer - the number of symmetry operations that fix m.
% See https://github.com/mtex-toolbox/mtex/issues/2584. The two multiply to
% the order of the group, so the old value is numSym(m.CS) ./ multiplicity(m).
%
% Syntax
%   n = multiplicity(m) % number of @Miller indices equivalent to m
%
% Input
%  m - @Miller
%
% Output
%  n - integer
%
% See also
% vector3d/symmetrise orientation/multiplicity fibre/multiplicity


[~,n] = symmetrise(m,'unique','noAntipodal');