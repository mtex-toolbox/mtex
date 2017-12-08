function cS = times(alpha,cS)

if ~isa(cS,'crystalShape')
  [cS,alpha] = deal(alpha,cS); 
end

alpha = repmat(alpha(:).',length(cS.V)/numel(alpha),1);
cS.V = alpha .* cS.V;