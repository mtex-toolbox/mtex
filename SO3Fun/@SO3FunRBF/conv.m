function SO3F = conv(SO3F1,SO3F2,varargin)
% convolution of an SO3FunRBF with another SO3FunRBF or an SO3Kernel
%
% For detailed information about the definition of the convolution take a 
% look in the <SO3FunConvolution.html documentation>.
%
% Syntax
%   SO3F = conv(SO3F1,SO3F2)
%   SO3F = conv(SO3F1,SO3F2,'noFourier')
%   SO3F = conv(SO3F1,psi)
%
% Input
%  SO3F1,SO3F2 - @SO3FunRBF
%  psi - @SO3Kernel
%
% Output
%  SO3F - @SO3FunRBF
%
% See also
% SO3FunHarmonic/conv SO3FunCBF/conv SO3Kernel/conv S2FunHarmonic/conv S2Kernel/conv

if isnumeric(SO3F1)
  SO3F = conv(SO3F2,SO3F1,varargin{:});
  return
end
if isnumeric(SO3F2)
  v = 2*(1:length(SO3F2))'-1;
  SO3F2 = SO3Kernel(SO3F2.*v);
end

% ------------------- convolution with a SO3Kernel -------------------
% update the local kernel function
if isa(SO3F2,'SO3Kernel')

  SO3F1.psi = conv(SO3F1.psi,SO3F2);
  SO3F1.c0 = SO3F1.c0 * SO3F2.A(1);
  SO3F = SO3F1;
  return
end


% ------------------- convolution of SO3Funs -------------------
% a) maybe we should go the Fourier route
if ~isa(SO3F2,'SO3FunRBF') || ...
    (length(SO3F1.center) > 100 && length(SO3F2.center) > 100 && ... 
    ~check_option(varargin,'noFourier'))

  if isa(SO3F2,'SO3FunRBF')
    warning(['The convolution of two SO3FunRBFs could be done fast by pure RBF method. ' ...
    'For big center sizes this yields an SO3FunRBF with lots of centers, which is ' ...
    'not manageable anymore. If you still want to generate an SO3FunRBF use ''noFourier''.']);
  end
  SO3F = conv@SO3Fun(SO3F1,SO3F2,varargin{:});
  return

end


% b) pure RBF method
ensureCompatibleSymmetries(SO3F1,SO3F2,'conv');
warning(['The convolution of two SO3FunRBFs could be done fast by pure RBF method.' ...
  'For big center sizes this yields an SO3FunRBF with lots of centers, which is ' ...
  'not manageable anymore. Possibly transform one SO3FunRBF to an SO3FunHarmonic.']);

psi = conv(SO3F1.psi, SO3F2.psi);
center = SO3F1.center * SO3F2.center.';

s1 = size(SO3F1.weights);
s2 = size(SO3F2.weights);
l = length(s2)-length(s1);
s = max([s1(2:end),ones(1,l);s2(2:end),ones(1,-l)]);

% compute Fourier coefficients of the convolution
if prod(s) == 1 %simple SO3Fun
  weights = SO3F1.weights(:) * SO3F2.weights.';
  weights = weights(:);
else % vector valued SO3Fun  
  w1 = reshape(SO3F1.weights,[s1(1) 1 s1(2:end)]);
  w2 = reshape(SO3F2.weights,[1 s2(1) s2(2:end)]);
  weights = w1.*w2;
  weights = reshape(weights,[],prod(s));
end

% remove small values
ind = any(weights > 0.1/numel(center),2);
center = center(ind);
weights = reshape(weights(ind,:),[sum(ind) s]);

% % if to much data -> approximation
% if numel(weights) > 10000
% 
%   warning('not yet fully implemented');
%   res = get_option(varargin,'resolution',1.25*degree);
%   cs1 = center.CS;
%   cs2 = center.SS;
%   S3G = equispacedSO3Grid(cs1,cs2,'resolution',res);
% 
%   % init variables
%   d = zeros(length(S3G),prod(s));
% 
%   % iterate due to memory restrictions?
%   maxiter = ceil(cs1.numSym * cs2.numSym * length(center) /...
%     getMTEXpref('memory',300 * 1024));
%   if maxiter > 1, progress(0,maxiter);end
% 
%   for iter = 1:maxiter
% 
%     if maxiter > 1, progress(iter,maxiter); end
% 
%     dind = ceil(length(center) / maxiter);
%     sind = 1+(iter-1)*dind:min(length(center),iter*dind);
% 
%     ind = find(S3G,center(sind));
%     d(ind,:) = d(ind,:) + weights(sind,:);
% 
%   end
%   d = d ./ sum(d);
% 
%   % eliminate spare rotations in grid
%   del = any(d ~= 0,2);
%   center = subGrid(S3G,del);
%   weights = d(del);
% 
%   % reshape
%   weights = reshape(weights,[sum(del) s]);
% 
% end

SO3F = SO3FunRBF(center, psi, weights, SO3F1.c0 .* SO3F2.c0 + ...
  SO3F1.c0 .* reshape(sum(SO3F2.weights),[s2(2:end) 1]) + SO3F2.c0 .* reshape(sum(SO3F1.weights),[s1(2:end) 1]));

end