function [childId, packetId] = calcVariantIDs(parentOri,childOri,p2c,variantIDs)
%
% Syntax
%
%  childId = calcVariantIDs(parentOri,childOri,p2c,variantIDs)
%
% Input
%  parentOri  - parent @orientation
%  childOri   - child @orientation
%  p2c        - parent to child mis@orientation
%  variantIDs - order of child variants 
%
% Output
%  childId   - child variant Id
%
% Description
%
%

parentOri = parentOri.project2FundamentalRegion;

% all child variants
childVariants  = variants(p2c, parentOri);

if nargin == 4
   childVariants = childVariants(:,variantIDs); 
end

if size(childVariants,1) == 1
  childVariants = repmat(childVariants,length(childOri),1);
end
  
% compute distance to all possible variants
d = dot(childVariants,repmat(childOri,1,size(childVariants,2)));

% take the best fit
[~,childId] = max(d,[],2);

% compute packetId if required
if nargout == 2
  
  h = Miller({1,1,1},{1,-1,1},{-1,1,1},{1,1,-1},p2c.CS);

  omega = dot(variants(p2c,h),Miller(1,0,1,p2c.SS));

  [~,packetId] = max(omega,[],2);
  
  packetId = packetId(childId);
  
end


end