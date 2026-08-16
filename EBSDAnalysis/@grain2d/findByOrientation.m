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
phaseId = find(grains.CSList == ori.CS);
if isempty(phaseId), grains = []; return, end
ind = grains.phaseId == phaseId;

% find grains by their mean orientation
ind(ind) = angle(ori,grains.prop.meanRotation(ind)) < epsilon;

grains = subSet(grains,ind);
