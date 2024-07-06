function [childId,packetId,bainId,fit] = calcVariantId(parentOri,childOri,p2c,varargin)
% compute variantIds, packetId and bainId from parent / child orientation pairs
%
% Syntax
%
%   % compute variantIds
%   variantId = calcVariantId(parentOri,childOri,p2c)
%
%   % compute variantIds & packetIds
%   hklParent1 = Miller({1,1,1},{1,-1,1},{-1,1,1},{1,1,-1},p2c.CS);
%   hklChild1  = Miller(1,0,1,p2c.SS);
%
%   [variantId,packetId] = calcVariantId(parentOri,childOri,p2c,...
%     'packet', hklParent1,hklChild1)
%
%   % compute variantIds, packetIds & bainIds
%   hklParent1 = Miller({1,1,1},{1,-1,1},{-1,1,1},{1,1,-1},p2c.CS);
%   hklChild1  = Miller(1,0,1,p2c.SS);
%
%   hklParent2 = Miller({0,0,1},{1,0,0},{0,1,0},p2c.CS);
%   hklChild2  = Miller(1,0,0,p2c.SS);
%
%   [variantId,packetId,bainId] = calcVariantId(parentOri,childOri,p2c,...
%     'packet', hklParent1,hklChild1,...
%     'bain', hklParent2,hklChild2)
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
%  bainId    - bain id
%  fit       - fit between parentOri and childOri vs. to the OR

% all child variants
childVariants  = variants(p2c, parentOri);

if size(childVariants,1) == 1
  childVariants = repmat(childVariants,length(childOri),1);
end

% compute distance to all possible variants
fit = angle(childVariants,repmat(childOri(:),1,size(childVariants,2)));

% take the best fit
[fit,childId] = min(fit,[],2);


% compute packetId if required
if nargout >= 2
  if ~isempty(varargin) && any(strcmpi(varargin,'packet')) % definition given
    h1 = varargin{find(strcmpi('packet',varargin)==1)+1};
    h2 = varargin{find(strcmpi('packet',varargin)==1)+2};
    if ~isa(h1,'Miller') || ~isa(h2,'Miller')
      error('Input for packet ID calculation must be Miller.');
    end
  else % definition assumed
    warning('Packet ID calculation assuming {111}_p||{110}_c');
    h1 = Miller({1,1,1},{1,-1,1},{-1,1,1},{1,1,-1},p2c.CS);
    h2 = Miller(1,0,1,p2c.SS);
  end
  
  omega = dot(variants(p2c,h1),h2);
  [~,packetId] = max(omega,[],1);
  packetId = packetId(childId)';
end

% compute bainId if required
if nargout >= 3
  if ~isempty(varargin) && any(strcmpi(varargin,'bain')) % definition given
    h1 = varargin{find(strcmpi('bain',varargin)==1)+1};
    h2 = varargin{find(strcmpi('bain',varargin)==1)+2};
    if ~isa(h1,'Miller') || ~isa(h2,'Miller')
      error('Input for bain ID calculation must be Miller.');
    end
  else % definition assumed
    warning('Bain ID calculation assuming {001}_p||{100}_c');
    h1 = Miller({0,0,1},{1,0,0},{0,1,0},p2c.CS);
    h2 = Miller(1,0,0,p2c.SS);
  end
  
  omega = dot(variants(p2c,h1),h2);
  [~,bainId] = max(omega,[],1);
  bainId = bainId(childId)';
end

end
