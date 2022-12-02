function SO3F = conv(SO3F1,SO3F2,varargin)
% convolution of an SO3FunRBF with another SO3FunRBF or an SO3Kernel
%
% There are two SO3Funs $f: _{S_f^L\backslash}SO(3)_{/S_f^R} \to \mathbb{C}$
% where $S_f^L$ is the Left symmetry and $S_f^R$ is the Right symmetry and
% $g: _{S_g^L\backslash}SO(3)_{/S_g^R} \to \mathbb{C}$ given.
% Then the convolution $ f *_L g : _{S_f^L\backslash}SO(3)_{/S_g^R} \to
% \mathbb{C}$ is defined by
%
% $$ (f *_L g)(R) = \frac1{8\pi^2} \int_{SO(3)} f(q) \cdot g(q^{-1}\,R) \, dq $$
%
% and the convolution $ f *_R g : _{S_g^L\backslash}SO(3)_{/S_f^R} \to
% \mathbb{C}$ is defined by
%
% $$ (f *_R g)(R) = \frac1{8\pi^2} \int_{SO(3)} f(q) \cdot g(R\,q^{-1}) \, dq $$.
%
% with $vol(SO(3)) = \int_{SO(3)} 1 \, dR = 8\pi^2$.
% The convolution $*_L$ is used as default.
% The convolution of matrices of SO3Functions with matrices of SO3Functions
% works elementwise.
%
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
% SO3FunHarmonic/conv  SO3Kernel/conv S2FunHarmonic/conv S2Kernel/conv


% The convolution is defined like above. But in MTEX the convolution of two
% SO3Funs is mostly calculated by
%                    conv(inv(conj(SO3F1)),SO3F2).
%


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
% i) right sided convolution
if check_option(varargin,'Right')
  SO3F = inv(conv(inv(SO3F1),inv(SO3F2)));
  return
end

% ii) left sided convolution (default)
ensureCompatibleSymmetries(SO3F1,SO3F2,'conv_Left');
warning(['The convolution of two SO3FunRBFs could be done fast by pure RBF method.' ...
  'For big center sizes this yields an SO3FunRBF with lots of centers, which is ' ...
  'not manageable anymore. Possibly transform one SO3FunRBF to an SO3FunHarmonic.']);

center = SO3F1.center * SO3F2.center.';
weights = SO3F1.weights(:) * SO3F2.weights.';
psi = conv(SO3F1.psi, SO3F2.psi);

% remove small values
ind = weights > 0.1/numel(weights);
weights = weights(ind);
center = center(ind);

% % if to much data -> approximation
% if numel(weights) > 10000
%   
%   warning('not yet fully implemented');
%   res = get_option(varargin,'resolution',1.25*degree);
%   S3G = SO3Grid(res,cs2,cs1);
%   
%   % init variables
%   d = zeros(1,length(S3G));
% 
%   % iterate due to memory restrictions?
%   maxiter = ceil(length(cs1) * length(cs2) * length(center) /...
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
%     for i = 1:length(ind) % TODO -> make it faster
%       d(ind(i)) = d(ind(i)) + weights(sind(i));
%     end
%     
%   end
%   d = d ./ sum(d(:));
%   
%   % eliminate spare rotations in grid
%   del = d ~= 0;
%   center = subGrid(S3G,del);
%   weights = d(del);
%   
% end

SO3F = SO3FunRBF(center, psi, weights, SO3F1.c0 * SO3F2.c0 + ...
  SO3F1.c0 * sum(SO3F2.weights,'all') + SO3F2.c0 * sum(SO3F1.weights,'all'));


end