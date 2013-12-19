function ebsd = findByOrientation(ebsd,q0,epsilon)
% select grains by orientation
%
%% Input
% ebsd - @EBSD
% q0 - @quaternion | @rotation | @orientation 
% epsilon - searching radius
%
%% Output
% ebsd - @EBSD
%
%% See also
% EBSD/findByLocation GrainSet/findByOrientation


o = get(ebsd,'orientations');

ind  = find(o,q0,epsilon);

ebsd = subsref(ebsd,any(ind,2));
