function grains = findByOrientation( grains,q0, epsilon )
% select grains by orientation
%
% Input
%  grains - @GrainSet
%  q0 - @quaternion | @rotation | @orientation 
%  epsilon - searching radius
%
% Output
%  grains - @GrainSet
%
% Example 
%   g = findByOrientation(grains,idquaternion,10*degree);
%
% See also
% EBSD/findByLocation GrainSet/findByOrientation

ind = find(grains.meanOrientation,q0,epsilon);

grains = subSet(grains,any(ind,2));
