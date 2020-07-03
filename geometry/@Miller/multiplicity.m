function n = multiplicity(m,varargin)
% directions symmetrically equivalent to m
%
% Syntax
%   n = multiplicity(m) % @Miller indices symmetrically equivalent to m
%
% Input
%  m - @Miller
%
% Output
%  n - integer
%
% Options
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%  skipAntipodal - do not include antipodal symmetry


[~,n] = symmetrise(m,'unique','noAntipodal');

n = numSym(m.CS) ./ n;