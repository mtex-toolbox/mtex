function SO3F = conv(SO3F1,SO3F2,varargin)
% convolution of a rotational function with a rotational or spherical function
% or a kernel function.
%
% For detailed information about the definition of the convolution take a 
% look in the <SO3FunConvolution.html documentation>.
% 
% The convolution of matrices of SO3Functions with matrices of SO3Functions 
% works elementwise.
%
% Syntax
%   SO3F = conv(SO3F1,SO3F2)
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
  
  fhat = zeros([(L+1)^2,size(SO3F1)]);
  for l = 0:L
    fhat(l^2+1:(l+1)^2,:) = 2*sqrt(pi)/(2*l+1) * ...
          pagemtimes( SO3F1.fhat(deg2dim(l)+(2*l+1)*l+(1:2*l+1)',:) , psi.A(l+1) );
  end

  warning(['There is no symmetry given for the S2Kernel function. But for convolution the ' ...
      'right symmetry of the SO3Fun has to be compatible with the symmetry of the S2Fun.'])
  SO3F = S2FunHarmonic(fhat);
  return

end


% ------------------- convolution with a S2Fun -------------------
if isa(SO3F2,'S2Fun')

  % old sizes
  s1 = size(SO3F1);
  s2 = size(SO3F2);
  % new size
  l=length(s2)-length(s1);
  s = max([s1,ones(1,l);s2,ones(1,-l)]);

  sF = S2FunHarmonic(SO3F2);
  L = min(SO3F1.bandwidth,sF.bandwidth);

  fhat = zeros([(L+1)^2,s]);
  if prod(s) == 1 %simple SO3Fun
    for l = 0:L
      fhat(l^2+1:(l+1)^2) = reshape(SO3F1.fhat(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1) * ...
            sF.fhat(l^2+1:(l+1)^2) ./ sqrt(2*l+1);
    end
  else % vector valued SO3Fun  
    for l = 0:L
      ind = l^2+1:(l+1)^2;
      fhat_l = pagemtimes( full(reshape(SO3F1.fhat(deg2dim(l)+1:deg2dim(l+1),:),[2*l+1,2*l+1,s1])) , ...
        full(reshape(sF.fhat(ind,:),[2*l+1,1,s2])) ) ./ sqrt(2*l+1);
      fhat(ind,:) = reshape(fhat_l,[],prod(s));
    end
  end

  % we need that SO3F1.SLeft == SO3F2.Sym
  if numProper(SO3F1.SLeft) == 1 
    SO3F = S2FunHarmonicSym(fhat,SO3F1.SRight);
  elseif isa(SO3F2,'S2Fun')
    ensureCompatibleSymmetries(SO3F1,SO3F2);    
    SO3F = S2FunHarmonicSym(fhat,SO3F1.SRight);
  else
    warning(['There is no symmetry of the S2Fun given. But for convolution the ' ...
      'left symmetry of the SO3Fun has to be compatible with the unknown symmetry.'])
    SO3F = S2FunHarmonic(fhat);
  end

  return

end


% ------------------- convolution with a SO3Kernel -------------------
% this is commutative
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
ensureCompatibleSymmetries(SO3F1,SO3F2,'conv');

L = min(SO3F1.bandwidth,SO3F2.bandwidth);

% compute Fourier coefficients
fhat1 = SO3F1.calcFourier('bandwidth',L);
fhat2 = SO3F2.calcFourier('bandwidth',L);

% construct SO3FunHarmonic by multiplying the Fourier coefficients
SO3F = SO3FunHarmonic(convSO3(fhat1,fhat2),SO3F2.SRight,SO3F1.SLeft);

end

