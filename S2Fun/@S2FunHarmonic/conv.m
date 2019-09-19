function sF = conv(sF, psi, varargin)
% spherical convolution of sF with a radial function psi 
%
% Syntax
%   sF = conv(sF, psi)
%   sF = conv(sF, A)
%   SO3F = conv(sF1, sF2)
%
% Input
%  sF, sF1, sF1 - @S2FunHarmonic
%  psi - @S2Kernel
%  A   - list of Legendre coeficients
%
% Output
%  sF   - @S2FunHarmonic
%  SO3F - @ODF
%

if isa(psi,'S2Fun')
  
  if isa(psi,'S2FunHarmonic')
    sF2 = psi;
    bw = get_option(varargin,'bandwidth',min(sF.bandwidth,sF2.bandwidth));
  else
    bw = get_option(varargin,'bandwidth',sF.bandwidth);
    sF2 = S2FunHarmonic.quadrature(psi,'bandwidth',bw);
  end
  
  fhat = [];
  for l = 0:bw
    fhat = [fhat;reshape(sF.fhat(l^2+1:(l+1)^2) * ...
      sF2.fhat(l^2+1:(l+1)^2)',[],1)]; %#ok<AGROW>
  end
  
  % extract symmetries if possible
  CS1 = crystalSymmetry; CS2 = specimenSymmetry;
  try CS1 = sF.CS; end; try CS2 = sF2.CS; end %#ok<TRYNC>
    
  sF = FourierODF(fhat,CS1,CS2);
    
else

  % extract Legendre coefficients
  if isa(psi,'double')
    A = psi(:);
  elseif isa(psi,'S2Kernel')
    A = psi.A(:);
    A = A ./ (2*(0:length(A)-1)+1).';
  elseif isa(psi,'kernel')
    A = psi.A(:);
    A = A ./ (2*(0:length(A)-1)+1).';
  else
    error('wrong second argument');
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



