function mdf = calcMDF(component1,component2,varargin)
% calculate the uncorrelated misorientation distribution function (MDF) from one or two ODF

center = inv(component1.center) * component2.center.';
weights = component1.weights * component2.weights.';
psi = component1.psi * component2.psi;

% remove small values
ind = weights > 0.1/numel(weights);
weights = weights(ind);
center = center(ind);

% if to much data -> approximation
if numel(weights) > 10000
  
  warning('not yet fully implemented');
  res = get_option(varargin,'resolution',1.25*degree);
  S3G = SO3Grid(res,cs2,cs1);
  
  % init variables
  d = zeros(1,length(S3G));
  
  % iterate due to memory restrictions?
  maxiter = ceil(numProper(cs1) * numProper(cs2) * length(center) /...
    getMTEXpref('memory',300 * 1024));
  if maxiter > 1, progress(0,maxiter);end
  
  for iter = 1:maxiter
    
    if maxiter > 1, progress(iter,maxiter); end
    
    dind = ceil(length(center) / maxiter);
    sind = 1+(iter-1)*dind:min(length(center),iter*dind);
    
    ind = find(S3G,center(sind));
    for i = 1:length(ind) % TODO -> make it faster
      d(ind(i)) = d(ind(i)) + weights(sind(i));
    end
    
  end
  d = d ./ sum(d(:));
  
  % eliminate spare rotations in grid
  del = d ~= 0;
  center = subGrid(S3G,del);
  weights = d(del);
  
  
end

mdf = unimodalODF(center,psi,component2.CS,component1.CS,'weights',weights);

end
