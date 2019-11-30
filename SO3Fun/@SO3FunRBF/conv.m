function SO3F = conv(SO3F1,SO3F2,varargin)
% convolution between two SO3Fun gives again a SO3Fun
%
% Syntax
%   SO3F = conv(SO3F1,SO3F2,varargin)
%   SO3F = conv(SO3F1,psi,varargin)
%
% Input
%  SO3F1,SO3F2 - SO3FunRBF
%  psi - @SO3Kernel
%
% Output
%  SO3F - @SO3FunRBF
%

% if second argument is just a kernel function we need only to update the
% local kernel function
if isa(SO3F2,'SO3Kernel')
  SO3F1.psi = conv(SO3F1.psi,SO3F2);
  return;
end

center = inv(SO3F1.center) * SO3F2.center.';
weights = SO3F1.weights * SO3F2.weights.';
psi = conv(SO3F1.psi, SO3F2.psi);

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
  maxiter = ceil(length(cs1) * length(cs2) * length(center) /...
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

% SO3F2.CS,SO3F1.CS
SO3F = SO3FunRBF(center,psi,weights);

end
