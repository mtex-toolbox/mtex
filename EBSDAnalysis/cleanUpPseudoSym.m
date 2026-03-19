function [ebsd,grainsM,numChanged] = cleanUpPseudoSym(ebsd,grains,mori,varargin)
% cleanUpPseudoSym Corrects pseudo-symmetry artifacts using tortuosity.
%
% Syntax
%   [ebsd, grainsM, numChanged] = cleanUpPseudoSym(ebsd, grains, mori, varargin)
%
% Input
%   ebsd   - @EBSD object
%   grains - @grain2d object
%   mori   - @orientation (can be an array of pseudo-symmetries)
%
% Options
%   'delta'     - Tolerance for boundary misorientation angle to match pseudo-symmetry (default: 2*degree)
%   'threshold' - Minimum tortuosity (boundary length / straight distance) to trigger merge (default: 1.5)
%
% Output
%   ebsd       - updated @EBSD object
%   grainsM    - merged @grain2d object
%   numChanged - number of pixels that changed orientation

% initialize output counter
numChanged = 0;

% select grain boundaries with the correct symmetry
gB = grains.boundary(mori(1).CS, mori(1).CS);

% select grain boundaries with the mori
tol = get_option(varargin,'delta',2*degree);

% evaluate all moris and keep boundary if any match is within tolerance
isMatch = any(angle(gB.misorientation, mori) < tol, 2);
gB = gB(isMatch);

% extent of each component
xmin = accumarray(gB.componentId,gB.midPoint.x,[],@min);
ymin = accumarray(gB.componentId,gB.midPoint.y,[],@min);
xmax = accumarray(gB.componentId,gB.midPoint.x,[],@max);
ymax = accumarray(gB.componentId,gB.midPoint.y,[],@max);
d = sqrt((xmax-xmin).^2 + (ymax-ymin).^2);

% boundary length of each component
l = accumarray(gB.componentId,gB.segLength);

% tortuosity projected back to each segment
tortuosity = l(gB.componentId)./d(gB.componentId);
maxT = get_option(varargin,'threshold',1.5);
cond = tortuosity > maxT & gB.componentSize > 4;

% merge grains
[grainsM,parentId,newInd] = merge(grains,gB(cond),...
  'calcMeanOrientation','maxArea');

% update EBSD
ind = ebsd.grainId > 0;
ebsd.grainId(ind) = parentId(grains.id2ind(ebsd.grainId(ind)));

% array of all possible operators: [identity, mori_1, mori_2, ...]
id_op = orientation.id(mori(1).CS,mori(1).CS); 
all_ops = [id_op, transpose(mori(:))];

% identify ebsd points belonging to the newly merged grains
updated_grain_ids = grainsM.id(newInd);
is_merged_pt = ismember(ebsd.grainId, updated_grain_ids);
merged_pts = find(is_merged_pt);

if ~isempty(merged_pts)
  % extract orientations of merged points and their new grain mean orientations
  ori = ebsd.orientations(merged_pts);
  
  grain_inds = grainsM.id2ind(ebsd.grainId(merged_pts));
  mean_oris = grainsM.meanOrientation(grain_inds);
  
  % calculate distances for all operators simultaneously
  dists = angle(ori .* all_ops, mean_oris);
  
  % find the operator that minimizes the misorientation distance
  [~, best_op_idx] = min(dists, [], 2);
  
  % count pixels that will change (index 1 is the identity operator)
  numChanged = sum(best_op_idx > 1);
  
  % apply the best operator (skip index 1 since it is the identity)
  for m = 1:length(mori)
      swap = (best_op_idx == m + 1);
      if any(swap)
          ori(swap) = ori(swap) * mori(m);
      end
  end
  
  % update EBSD orientations
  ebsd.orientations(merged_pts) = ori;
end
end