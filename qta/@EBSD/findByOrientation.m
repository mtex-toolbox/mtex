function ebsd = findByOrientation(ebsd,q0,epsilon)
% select grains by orientation
%
% Input
%  ebsd    - @EBSD
%  q0      - @quaternion | @rotation | @orientation 
%  epsilon - searching radius
%
% Output
%  ebsd - @EBSD
%
% See also
% EBSD/findByLocation GrainSet/findByOrientation

ind  = find(ebsd.orientations,q0,epsilon);

ebsd = subSet(ebsd,any(ind,2));
