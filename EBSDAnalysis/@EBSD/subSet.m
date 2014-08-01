function ebsd = subSet(ebsd,ind)
% indexing of EBSD data
%
% Syntax
%   subSet(ebsd,ind)
%

ebsd = subSet@dynProp(ebsd,ind);
ebsd.rotations = ebsd.rotations(ind);
ebsd.phaseId = ebsd.phaseId(ind);
ebsd.id = ebsd.id(ind);
if ~isempty(ebsd.grainId), ebsd.grainId = ebsd.grainId(ind); end
if ~isempty(ebsd.A_D), ebsd.A_D = ebsd.A_D(ind,ind); end
