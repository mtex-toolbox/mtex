function [childId, packetId] = calcVariantId(parentOri,childOri,p2c,varargin)
% compute variantIds and packetId from parent / child orientation pairs
%
% Syntax
%
%   variantId = calcVariantId(parentOri,childOri,p2c)
%
%   % compute packetIds
%   [variantId,packetId] = calcVariantId(parentOri,childOri,p2c,...
%     {hklParent,hklChild})
%
%   % packet determination
%   hklParent = Miller({1,1,1},{1,-1,1},{-1,1,1},{1,1,-1},p2c.CS);
%   hklChild  = Miller(1,0,1,p2c.SS);
%
%   [variantId,packetId] = calcVariantId(parentOri,childOri,p2c,...
%     {hklParent,hklChild})
%
% Input
%  parentOri - parent @orientation
%  childOri  - child @orientation
%  p2c       - parent to child mis@orientation
%  hklParent, hklChild - correspondent planes between parent and child
%
% Output
%  variantId - variant id
%  packetId  - packet id
%

% all child variants
childVariants  = variants(p2c, parentOri);

if size(childVariants,1) == 1
  childVariants = repmat(childVariants,length(childOri),1);
end
  
% compute distance to all possible variants
d = dot(childVariants,repmat(childOri(:),1,size(childVariants,2)));

% take the best fit
[~,childId] = max(d,[],2);

% compute packetId if required
if nargout == 2
  % Get packet definition
  tmp = getClass(varargin,'cell');
  isMiller = [];
  for ii = 1:length(tmp); isMiller(ii) = ~isempty(getClass(tmp(ii),'Miller')); end
  
  if sum(isMiller) == 2 % definition given
    ind = find(isMiller);
    h1 = tmp{ind(1)};  
    h2 = tmp{ind(2)};
  else % definition assumed
    warning('Packet ID calculation assuming {111}_p||{110}_c');
    h1 = Miller({1,1,1},{1,-1,1},{-1,1,1},{1,1,-1},p2c.CS);
    h2 = Miller(1,0,1,p2c.SS);
  end
  
  omega = dot(variants(p2c,h1),h2);

  [~,packetId] = max(omega,[],1);
  
  packetId = packetId(childId);
  
end

end