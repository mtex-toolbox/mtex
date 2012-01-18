function grains = findByOrientation( grains,q0, epsilon )
% select grains by orientation
%
%% Input
% grains - @GrainSet
% q0 - @quaternion | @rotation | @orientation 
% epsilon - searching radius
%
%% Output
% grains - @GrainSet
%
%% Example 
%  g = findByLocation(grains,idquaternion,10*degree);
%
%% See also
% EBSD/findByLocation GrainSet/findByOrientation



o = get(grains,'orientation');

ind = find(o,q0,epsilon);

grains = subsref(grains,any(ind,2));

