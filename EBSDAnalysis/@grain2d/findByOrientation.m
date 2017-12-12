function grains = findByOrientation( grains,q0, epsilon )
% select grains by orientation
%
% Syntax
%   g = findByOrientation(grains,ori,epsilon);
%
% Input
%  grains - @grain2d
%  q0 - @quaternion | @rotation | @orientation 
%  epsilon - searching radius
%
% Output
%  grains - @grain2d
%
% See also
% EBSD/findByLocation grain2d/findByOrientation

ind = find(grains.meanOrientation,q0,epsilon);

grains = subSet(grains,any(ind,2));
