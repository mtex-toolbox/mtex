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
  [x,y] = ind2sub(ebsd,ind);
  yMin = min(y(:));
  yMax = max(y(:));
  xMin = min(x(:));
  xMax = max(x(:));
end

mask = false(size(ebsd));
mask(yMin:yMax,xMin:xMax) = true;

ebsd = subSet(ebsd,mask,'keepGrid');
ebsd = reshape(ebsd,yMax-yMin+1,xMax-xMin+1);

% fill with NaN
nanId = ~ismember(ebsd.id,id);
ebsd.phaseId(nanId) = NaN;
ebsd.rotations(nanId) = NaN;