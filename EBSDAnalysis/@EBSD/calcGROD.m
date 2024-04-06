function GROD = calcGROD(ebsd,grains,rotRef)
% compute grain reference orientation deviation / mis2mean
%
% Syntax
%
%   % reconstruct grains
%   [grains, ebsd,grainId] = calcGrains(ebsd('indexed'))
%
%   % compute grain reference orientation deviation
%   GROD = calcGROD(ebsd,grains)
%
%   % grain reference orientation deviation with respect to oriRef
%   GROD = calcGROD(ebsd,grains,oriRef)
%
% Input 
%  ebsd   - @EBSD
%  grains - @grain2d
%  oriRef - (list of) reference @rotation 
%
% Output
%  GROD - @rotation, mis@orientation
%
% See also
%

GROD = rotation.nan(size(ebsd));

for phId = grains.indexedPhasesId

  thisPhase = ebsd.phaseId == phId;

  if ~any(thisPhase), continue; end
    
  if nargin == 2
    
    oriRef = grains.meanRotation(ebsd.grainId(thisPhase));

  elseif isscalar(rotRef)
    
    oriRef = repmat(rotRef, nnz(thisPhase),1);
  
  else
   
    oriRef = rotRef(ebsd.grainId(thisPhase));

  end
  
  oriRef = project2FundamentalRegion(oriRef, ebsd.CSList{phId}, ebsd.rotations(thisPhase));
  GROD(thisPhase) = inv(oriRef) .* ebsd.rotations(thisPhase);
    
end

if ebsd.isSinglePhase, GROD = orientation(GROD,ebsd.CS,ebsd.CS); end
