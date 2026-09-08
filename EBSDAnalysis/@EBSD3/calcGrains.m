function [grains,ebsd] = calcGrains(ebsd,varargin)
% reconstruct 3d grains from a list of voxels
%
% A list of voxels, as a selection |ebsd('Quartz')| from a volume returns,
% is put back onto its lattice with <EBSD3.gridify.html |gridify|> and the
% grains are reconstructed on that grid; the cells of the lattice the list
% does not occupy are not indexed. The options are those of
% <EBSD3square.calcGrains.html |calcGrains|> on a voxel grid.
%
% Syntax
%   [grains,ebsd] = calcGrains(ebsd,'angle',5*degree)
%
% Input
%  ebsd - @EBSD3
%
% Output
%  grains - @grain3d
%  ebsd   - the input list with |grainId|; |grains.boundary.ebsdId| refers to
%           the grid the reconstruction ran on
%
% See also
% EBSD3square/calcGrains EBSD3/gridify

[ebsdGrid,newId] = gridify(ebsd);
[grains,ebsdGrid] = calcGrains(ebsdGrid,varargin{:});
if nargout > 1, ebsd.grainId = ebsdGrid.grainId(newId); end

end
