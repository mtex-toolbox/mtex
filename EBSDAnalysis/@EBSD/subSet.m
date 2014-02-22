function ebsd = subSet(ebsd,ind)
% indexing of EBSD data
%
% Syntax
%   subSet(ebsd,ind)
%

ebsd = subSet@dynProp(ebsd,ind);
ebsd.rotations = ebsd.rotations(ind);
