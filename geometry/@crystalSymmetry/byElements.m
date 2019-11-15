function cs = byElements(rot,varargin)
% generate a symmetry group from rotations

% generate a group
for k = 1:100
  
  numRot = length(rot);
  rot = unique(rot * rot,'tolerance',1e-2);
  if length(rot) <= numRot, break; end
  
end
  
cs = crystalSymmetry(rot);