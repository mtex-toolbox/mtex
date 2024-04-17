function p2c = MoritoOrder(p2c)
% adjusts ordering of variants according to Morito convention
%
% Syntax
%
%   p2c.variantMap = MoritoOrder(p2c)
%
%   p2cV = variants(p2c)
%
% Input
%  p2c - parent to child orientation relationship, @orientation
%
% Output
%  variantMap - reordering of the default MTEX variants
%

% default variant ordering
p2c.opt.variantMap = [];
p2cV = p2c.variants;

% set up planes and directions
% TODO: make this work for OR other than Kurdjumov Sachs
[nParent,nChild] = round2Miller(p2cV(1));

csParent = p2cV.CS;
csChild = p2cV.SS;

if angle(nParent,Miller({1 1 1},csParent)) < 5*degree
  nParent = Miller({1 1 1},{1 -1 1},{-1 1 1},{1 1 -1},csParent);
else
  nParent = nParent.symmetrise;
end

if angle(nChild,Miller(0,1,1,csChild)) < 5*degree
  nChild = Miller(0,1,1,csChild);
end

% Step 1
% determine child symmetry such that (011) is parallel to (XXX)
% with only one negative X -> this does not change variantId

d = angle_outer(inv(p2cV) * p2cV.SS * nChild, nParent,'noSymmetry');
d = min(d,[],2);
d = reshape(d,length(p2cV),numSym(p2cV.SS));

[~,id] = min(d,[],2);

symRot = p2cV.SS.rot;
p2cV = inv(symRot(id)) .* p2cV(:);

% determine packetId
[~,packetId] = min(reshape(angle(p2cV * nParent, nChild),[],length(nParent)),[],2);

% Step 2
% transform to packet 1

dParent = Miller({-1 0 1},{0 1 -1},{1 -1 0},csParent);
rot2p1 = orientation.map(nParent(1),nParent, ...
  dParent(1),Miller({-1 0 1},{1 0 -1},{0 -1 1},{-1 1 0},csParent));

p2cp1 = p2cV .* rot2p1(packetId);

% step 3
% determine lathId in packet 1

dChild = Miller({-1 -1 1},{-1 1 -1},csChild);

d = reshape(angle_outer(inv(p2cp1)*dChild,dParent,'noSymmetry'),[],length(dParent)*length(dChild));

% the lath id
[~,lathId] = min(d,[],2);

% the variant Id
vId = 6*(packetId-1) + lathId;

% new order we get from reordering the variant Id
[~,newOrder] = sort(vId);

%p2cV = p2cV(newOrder);

% TODO!
p2c.opt.variantMap = newOrder;
