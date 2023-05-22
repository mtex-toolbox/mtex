function ebsd = findByOrientation(ebsd,ori,epsilon)
% select ebsd data by orientation
%
% Syntax
%   ebsd = findByOrientation(ebsd,ori,epsilon)
%
%   f = fibre(Miller(1,1,1,cs),vector3d.Z)
%   ebsd = findByOrientation(ebsd,f,epsilon)
%
% Input
%  ebsd    - @EBSD
%  ori     - @orientation 
%  f       - @fibre 
%  epsilon - misorientation angle threshold
%
% Output
%  ebsd - @EBSD
%
% See also
% EBSD/findByLocation grain2d/findByOrientation

if nargin == 2, epsilon = 1*degree; end

% restrict to the right phase
if isa(ori,'orientation') || isa(ori,'fibre')
  phaseId = cellfun(@(cs) isa(cs,'crystalSymmetry') & ori.CS == cs, ebsd.CSList);
  ebsd = subSet(ebsd,ismember(ebsd.phaseId,find(phaseId)));
end

ind  = find(ebsd.orientations,ori,epsilon);

ebsd = subSet(ebsd,any(ind,2));
