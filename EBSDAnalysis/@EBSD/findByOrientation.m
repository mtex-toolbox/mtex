function ebsd = findByOrientation(ebsd,q0,epsilon)
% select ebsd data by orientation
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
% EBSD/findByLocation grain2d/findByOrientation

ind  = find(ebsd.orientations,q0,epsilon);

ebsd = subSet(ebsd,any(ind,2));
