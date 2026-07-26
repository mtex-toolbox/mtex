function [grains,ebsd] = calcGrains(seg,varargin)
% turn the segmentation into a grain2d object
%
% The regions found by the segmenter are handed to the ordinary
% reconstruction chain as a custom grain boundary criterion, so that
% boundaries, polygons, mean orientations and everything else on the
% resulting grain2d are computed by exactly the same code as for
% EBSD.calcGrains. Nothing in that chain is modified or bypassed.
%
% Pixels the segmenter could not explain (see grainSegmenter.isOutlier)
% stay in the grain they lie in, but their orientation is set to NaN: they
% have been assigned, not fitted, and should not contribute to the grain
% mean orientation or to any misorientation statistics.
%
% Syntax
%   [grains,ebsd] = seg.calcGrains
%   [grains,ebsd] = seg.calcGrains('keepOutliers')
%
% Options
%  keepOutliers - leave the orientation of outlier pixels alone
%
% Output
%  grains - @grain2d
%  ebsd   - @EBSD carrying grainId
%
% See also
% grainSegmenter grainSegmenter.merge EBSD.calcGrains

ebsd = seg.ebsd;

if ~check_option(varargin,'keepOutliers') && any(seg.isOutlier)
  rot = ebsd.rotations;
  rot(seg.isOutlier) = rotation.nan;
  ebsd.rotations = rot;
end

% pixels outside the segmentation (not indexed, NaN) must not be joined to
% anything, so give each of them a label of its own
lab = seg.id;
own = lab == 0;
lab(own) = seg.numRegions + (1:nnz(own));

[grains,ebsd] = calcGrains(ebsd,gbcCustom(lab,0.5),varargin{:});

end
