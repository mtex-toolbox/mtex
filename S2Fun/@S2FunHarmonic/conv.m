function sF = conv(sF, psi, varargin)
% spherical convolution of sF with a radial function or another
% sperical function psi
%
% Syntax
%   sF = conv(sF, psi)
%   sF = conv(sF, A)
%   SO3F = conv(sF1, sF2)
%
% Input
%  sF, sF1, sF1 - @S2FunHarmonic
%  psi - @S2Kernel
%  A   - list of Legendre coefficients
%
% Output
%  sF   - @S2FunHarmonic
%  SO3F - @SO3Fun
%
% See also
% S2Kernel/conv SO3FunHarmonic/conv SO3Kernel/conv 


% The convolution is defined like above. But in MTEX the convolution of two
% S2Funs is mostly calculated by
%                    inv(4*pi*conv(sF1,conj(sF2))).
%


if isnumeric(sF)
  sF = conv(psi,sF,varargin{:});
  return
end


% ------------------- convolution of S2Funs -------------------
if isa(psi,'S2Fun')
  
  if isa(psi,'S2FunHarmonic')
    sF2 = psi;
    bw = min(get_option(varargin,'bandwidth',NaN),min(sF.bandwidth,sF2.bandwidth));
  else
    bw = min(get_option(varargin,'bandwidth',NaN),sF.bandwidth);
    sF2 = S2FunHarmonic.quadrature(psi,'bandwidth',bw);
  end
  
  fhat = [];
  for l = 0:bw
    A = sF.fhat(l^2+1:(l+1)^2) * sF2.fhat((l+1)^2:-1:l^2+1).' /(4*pi)/sqrt(2*l+1);
    fhat = [fhat;A(:)];
  end
  
  % extract symmetries if possible
  CS1 = crystalSymmetry; CS2 = specimenSymmetry;
  try CS1 = sF.s; end; try CS2 = sF2.s; end
    
  sF = SO3FunHarmonic(fhat,CS1,CS2,varargin{:});
    
  return
end


% ------------------- convolution of S2Kernel functions -------------------

  % extract Legendre coefficients
  if isa(psi,'double')
    A = psi(:);
  elseif isa(psi,'S2Kernel')
    A = psi.A(:);
    A = A ./ (2*(0:length(A)-1)+1).';
  end
  A = A(1:min(sF.bandwidth+1,length(A)));
  
  % reduce bandwidth if required
  bandwidth = length(A)-1;
  sF.bandwidth = bandwidth;

  % extend coefficients
  A = repelem(A,2*(0:bandwidth)+1);

  % multiplication in harmonic domain
  sF.fhat = A .* sF.fhat;


end



