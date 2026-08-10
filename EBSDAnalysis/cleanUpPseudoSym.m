function [ebsd,grainsM,numChanged] = cleanUpPseudoSym(ebsd,grains,mori,varargin)
% cleanUpPseudoSym Corrects pseudo-symmetry artifacts in a single phase using tortuosity.
%
% A pseudo symmetry is a rotation which is not a symmetry of the crystal but
% maps the diffraction pattern almost onto itself, such that the indexing
% picks between the two solutions at random. The resulting boundaries follow
% the indexing noise and are therefore much more tortuous, i.e. much longer
% relative to the distance between their end points, than real grain
% boundaries. This command merges all grains separated by such a boundary
% and rotates the affected pixels by the pseudo symmetry.
%
% Since the phase to be corrected is determined by the symmetry of |mori|,
% only one phase is treated per call. To clean up pseudo-symmetries in
% multiple phases, run this function for each phase individually. Grain
% boundaries should not have been smoothed before, as this destroys exactly
% the tortuosity the detection is based on.
%
% Syntax
%   [ebsd, grainsM, numChanged] = cleanUpPseudoSym(ebsd, grains, mori)
%   [ebsd, grainsM, numChanged] = cleanUpPseudoSym(ebsd, grains, mori, 'threshold', 1.5)
%
% Input
%   ebsd   - @EBSD object, with grainId set by @EBSD.calcGrains
%   grains - @grain2d object
%   mori   - @rotation or @orientation (array of pseudo-symmetries, same CS and SS)
%
% Options
%   'delta'     - Tolerance for boundary misorientation angle to match pseudo-symmetry (default: 2*degree)
%   'threshold' - Minimum tortuosity (boundary length / straight distance) to trigger merge (default: 1.5)
%
% Output
%   ebsd       - updated @EBSD object
%   grainsM    - merged @grain2d object
%   numChanged - number of pixels that changed orientation
%
% Example
%
%   mtexdata forsterite
%   ebsd = ebsd('indexed');
%   [grains,ebsd] = calcGrains(ebsd,'angle',10*degree,'minPixel',5);
%
%   % the pseudo hexagonal oxygen sublattice of olivine
%   psSym = orientation.byAxisAngle(Miller(1,0,0,ebsd('Fo').CS,'uvw'),[60 120]*degree);
%
%   [ebsd,grains] = cleanUpPseudoSym(ebsd,grains,psSym)
%
% See also
% EBSDPseudoSymmetry grain2d.merge

% 0. Validate Inputs
if mori.CS ~= mori.SS
    error('cleanUpPseudoSym:PhaseMismatch', ...
          'Pseudo-symmetry misorientation must have identical crystal and specimen symmetry (mori.CS == mori.SS).');
end

% initialize output counter
numChanged = 0;

% Identify which phase ID we are correcting
pseudoSym_phase_id = ebsd.cs2phaseId(mori.CS);

if pseudoSym_phase_id == 0
  warning('cleanUpPseudoSym:PhaseNotFound', 'The pseudo-symmetry phase was not found in the EBSD data.');
  grainsM = grains;
  return;
end

% select grain boundaries with the correct symmetry
gB = grains.boundary(mori.CS, mori.CS);

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

% update EBSD orientations
if check_option(varargin,'check')
  
  for k = newInd
  
    ind = find(ebsd.grainId == grainsM.id(k));
    
    ori = orientation(ebsd.rotations(ind),mori.CS);

    swap = angle(ori,grainsM.meanOrientation(k) * inv(mori)) ...
      < angle(ori,grainsM.meanOrientation(k));
  
    ori(swap) = ori(swap) * mori;
    ebsd.rotations(ind) = ori;
  end
  return
end

% array of all possible operators: [identity, mori_1, mori_2, ...]
id_op = orientation.id(mori.CS,mori.CS); 
all_ops = [id_op, transpose(mori(:))];

% identify ebsd points belonging to the newly merged grains AND the target phase
updated_grain_ids = grainsM.id(newInd);
is_merged_pt = ismember(ebsd.grainId, updated_grain_ids);
is_target_phase = (ebsd.phaseId == pseudoSym_phase_id);

% Combine conditions to get the exact pixels to evaluate
valid_pts_mask = is_merged_pt(:) & is_target_phase;
valid_pts = find(valid_pts_mask);

if ~isempty(valid_pts)
  % extract orientations of merged points and their new grain mean orientations
  ori = ebsd(valid_pts).orientations;
  
  grain_inds = grainsM.id2ind(ebsd.grainId(valid_pts));
  mean_oris = grainsM(grain_inds).meanOrientation;
  
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
  ebsd(valid_pts).orientations = ori;
end
end