function ebsd = fillByGrainId(ebsd)
% the voxels on their full lattice, the cells not measured with grain id 0
%
% Syntax
%   ebsd = fillByGrainId(ebsd)
%
% Input
%  ebsd - @EBSD3
%
% Output
%  ebsd - @EBSD3square
%
% See also
% EBSD3.gridify EBSD3.fill

hasGrainId = ebsd.hasGrainId;
[ebsd,newId] = gridify(ebsd);

grainId = zeros(size(ebsd));
if hasGrainId, grainId(newId) = ebsd.prop.grainId(newId); end
ebsd.prop.grainId = grainId;

end
