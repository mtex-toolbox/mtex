function grains = findByOrientation( grains,ori, epsilon )
% select grains by orientation
%
% Syntax
%   grains = findByOrientation(grains,ori,epsilon);
%
% Input
%  grains  - @grain2d
%  ori     - @orientation 
%  epsilon - misorientation angle threshold
%
% Output
%  grains - @grain2d
%
% See also
% EBSD/findByLocation grain2d/findByOrientation

if nargin == 2, epsilon = 1*degree; end

% restrict to the right phase
if isa(ori,'orientation')
  phaseId = cellfun(@(cs) isa(cs,'crystalSymmetry') & ori.CS == cs, grains.CSList);
  grains = subSet(grains,ismember(grains.phaseId,find(phaseId)));
end

% find grains by their mean orientation
ind = find(grains.meanOrientation,ori,epsilon);

grains = subSet(grains,any(ind,2));
