function cs = byElements(rot,varargin)
% generate a symmetry group from rotations

% ensure that we have at least the identical rotation
rot = [rotation.id;rot(:)];

% generate a group
for k = 1:100
  
  numRot = length(rot);
  rot = unique(rot * rot,'tolerance',1e-2);
  if length(rot) <= numRot, break; end
  assert(length(rot) < 200,'No finite symmetry group could be build');
      
end
  
cs = crystalSymmetry(rot);