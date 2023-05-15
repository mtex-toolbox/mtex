function SO3F = conv(SO3F1,SO3F2,varargin)
% convolution of an SO3FunHarmonic with a function or a kernel on SO(3)
% 
% 1) SO3Fun * SO3Fun
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
% 2) SO3Fun * S2Fun
% The convolution of an SO3Fun  $f: _{S_f^L\backslash}SO(3)_{/S_f^R} \to \mathbb{C}$
% with an S2Fun $h: \mathbb S^2_{/S_h} \to \mathbb{C}$ yields 
% $f*h:\mathbb S^2_{/S_f^L} \to \mathbb{C}$ with
%
% $$ (f * h)(\xi) =  \frac1{8\pi^2} \int_{SO(3)} f(q) \cdot h(q^{-1}\,\xi) \, dq $$.
%
% 3) In particular we convolute an SO3Fun with an SO3Kernel similar to the
% first case. Therefore the Right and Left sided convolution are
% equivalent. The convolution of an SO3Fun with an S2Kernel works analogue 
% to case 2. 
%
% 
% Syntax
%   SO3F = conv(SO3F1,SO3F2)
%   SO3F = conv(SO3F1,SO3F2,'Right')
%   SO3F = conv(SO3F1,psi)
%   sF2 = conv(SO3F1,sF1)
%   sF2 = conv(SO3F1,phi)
%
% Input
%  SO3F1, SO3F2 - @SO3Fun
%  psi          - convolution @SO3Kernel
%  sF1          - @S2Fun
%  phi          - convolution @S2Kernel
%
% Output
%  SO3F - @SO3FunHarmonic
%  sF2  - @S2FunHarmonic
%
% See also
% SO3Kernel/conv SO3FunHarmonic/conv SO3FunRBF/calcFourier S2FunHarmonic/conv S2Kernel/conv


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


% ------------------- convolution with a S2Kernel -------------------
if isa(SO3F2,'S2Kernel')
  psi = SO3F2;
  L = min(SO3F1.bandwidth,psi.bandwidth);
  
  fhat = zeros((L+1)^2,1);
  for l = 0:L
    fhat(l^2+1:(l+1)^2) = 2*sqrt(pi)/(2*l+1) * ...
          SO3F1.fhat(deg2dim(l)+(2*l+1)*l+(1:2*l+1)')*psi.A(l+1);
  end

  warning(['There is no symmetry given for the S2Kernel function. But for convolution the ' ...
      'right symmetry of the SO3Fun has to be compatible with the symmetry of the S2Fun.'])
  SO3F = S2FunHarmonic(fhat);
  return

end


% ------------------- convolution with a S2Fun -------------------
if isa(SO3F2,'S2Fun')

  sF = S2FunHarmonic(SO3F2);
  L = min(SO3F1.bandwidth,sF.bandwidth);
  
  fhat = zeros((L+1)^2,1);
  for l = 0:L
    fhat(l^2+1:(l+1)^2) = reshape(SO3F1.fhat(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1) * ...
          sF.fhat(l^2+1:(l+1)^2) ./ sqrt(2*l+1);
  end

  % we need that SO3F1.SRight == SO3F.Sym
  if numProper(SO3F1.SLeft) == 1 
    SO3F = S2FunHarmonicSym(fhat,SO3F1.SRight);
  elseif isa(SO3F2,'S2FunHarmonicSym')
    ensureCompatibleSymmetries(SO3F1,SO3F2);    
    SO3F = S2FunHarmonicSym(fhat,SO3F1.SRight);
  else
    warning(['There is no symmetry of the S2Fun given. But for convolution the ' ...
      'right symmetry of the SO3Fun has to be compatible with the unknown symmetry.'])
    SO3F = S2FunHarmonic(fhat);
  end

  return

end


% ------------------- convolution with a SO3Kernel -------------------
% ( Here *L is the same like *R ) 
if isa(SO3F2,'SO3Kernel')

  L = min(SO3F1.bandwidth,SO3F2.bandwidth);
  SO3F1.bandwidth = L;
  s = size(SO3F1); SO3F1 = SO3F1.subSet(':');

  % multiply Wigner-D coefficients of SO3F1 
  % with the Chebyshev coefficients A of SO3F2 
  A = SO3F2.A;
  for l = 0:L
    SO3F1.fhat(deg2dim(l)+1:deg2dim(l+1),:) = ...
      A(l+1)./(2*l+1) * SO3F1.fhat(deg2dim(l)+1:deg2dim(l+1),:);
  end

  SO3F = reshape(SO3F1,s);
  return

end


% ------------------- convolution of SO3Fun's -------------------
% i) right sided convolution
if check_option(varargin,'Right')
  SO3F = inv(conv(inv(SO3F1),inv(SO3F2)));
  return
end

% ii) left sided convolution (default)
ensureCompatibleSymmetries(SO3F1,SO3F2,'conv_Left');

L = min(SO3F1.bandwidth,SO3F2.bandwidth);

% compute Fourier coefficients
fhat1 = SO3F1.calcFourier('bandwidth',L);
fhat2 = SO3F2.calcFourier('bandwidth',L);

% construct SO3FunHarmonic by multiplying the Fourier coefficients
SO3F = SO3FunHarmonic(convSO3(fhat1,fhat2),SO3F2.SRight,SO3F1.SLeft);

end

