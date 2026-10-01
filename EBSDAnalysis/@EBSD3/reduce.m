function ebsd = reduce(ebsd,fak)
% reduce ebsd data by a factor
% 
% Syntax
%   ebsd = reduce(ebsd)   % take every second voxel along each axis
%   ebsd = reduce(ebsd,3) % take every third voxel along each axis
%
% Input
%  ebsd    - @EBSD3
%  factor  - resample ebsd at rate factor (integer)
%
% Output
%  ebsd    - @EBSD3
%

if nargin == 1, fak = 2; end

% the voxels at every fak-th lattice position along each axis
[g,newId] = gridify(ebsd);
[i1,i2,i3] = ind2sub(size(g),newId);
ebsd = ebsd.subSet(~mod(i1-1,fak) & ~mod(i2-1,fak) & ~mod(i3-1,fak));
ebsd.unitCell = fak*ebsd.unitCell;

end
