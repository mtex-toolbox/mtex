function cS = times(alpha,cS)

if ~isa(cS,'crystalShape')
  [cS,alpha] = deal(alpha,cS); 
end

alpha = repmat(alpha(:).',size(cS.V,1),size(cS.V,2)/numel(alpha));
cS.V = alpha .* cS.V;