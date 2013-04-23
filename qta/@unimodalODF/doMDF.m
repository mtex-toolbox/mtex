function mdf = doMDF(odf1,varargin)
% calculate the uncorrelated misorientation distribution function (MDF) from one or two ODF


center = inverse(odf1.center) * odf2.center.';
c = odf1.c * odf2.c.';
psi = odf1.psi * odf2.psi;

% remove small values
ind = c > 0.1/numel(c);
c = c(ind);
center = center(ind);


% approximation
if numel(c1)*numel(c2) > 10000
  
  warning('not yet fully implemented');
  res = get_option(varargin,'resolution',1.25*degree);
  S3G = SO3Grid(res,cs2,cs1);
  
  % init variables
  d = zeros(1,numel(S3G));
  
  % iterate due to memory restrictions?
  maxiter = ceil(length(cs1) * length(cs2) * numel(center) /...
    getMTEXpref('memory',300 * 1024));
  if maxiter > 1, progress(0,maxiter);end
  
  for iter = 1:maxiter
    
    if maxiter > 1, progress(iter,maxiter); end
    
    dind = ceil(numel(center) / maxiter);
    sind = 1+(iter-1)*dind:min(numel(center),iter*dind);
    
    ind = find(S3G,center(sind));
    for i = 1:length(ind) % TODO -> make it faster
      d(ind(i)) = d(ind(i)) + c(sind(i));
    end
    
  end
  d = d ./ sum(d(:));
  
  %% eliminate spare rotations in grid
  del = d ~= 0;
  center = subGrid(S3G,del);
  c = d(del);
  
  
end

mdf = unimodalODF(center,psi,get(odf2,'CS'),get(odf1,'CS'),'weights',c);

end
