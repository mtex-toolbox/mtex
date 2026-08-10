function ebsd = subGrid(ebsd,ind)
% indexing of EBSD data
%
% Syntax
%   subGrid(ebsd,ind)
%

id = ebsd.id(ind);

% determine bounding rectangle
if islogical(ind)
  yMin = find(any(ind,2),1,"first");
  yMax = find(any(ind,2),1,"last");
  xMin = find(any(ind,1),1,"first");
  xMax = find(any(ind,1),1,"last");
else
  % ind2sub returns the ROW first - the logical branch above derives
  % yMin/yMax from any(ind,2), i.e. also rows, so keep the two consistent
  [r,c] = ind2sub(ebsd,ind);
  yMin = min(r(:));
  yMax = max(r(:));
  xMin = min(c(:));
  xMax = max(c(:));
end

mask = false(size(ebsd));
mask(yMin:yMax,xMin:xMax) = true;

ebsd = subSet(ebsd,mask,'keepGrid');
ebsd = reshape(ebsd,yMax-yMin+1,xMax-xMin+1);

% fill with NaN
nanId = ~ismember(ebsd.id,id);
ebsd.phaseId(nanId) = NaN;
ebsd.rotations(nanId) = NaN;