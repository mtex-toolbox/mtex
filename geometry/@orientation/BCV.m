function c = BCV(ori,psi,varargin)
% biased cross validation
%
% Input
%  ebsd - @EBSD
%  psi  - @kernel
%
% Output
%  c    - halfwidth
%
% See also
% EBSD/calcODF EBSD/calcKernel orientation/LSCV

% extract data
N = length(ori);
NCS = N * numProper(ori.CS);

w = get_option(varargin,'weights',ones(size(ori)));
w = w ./ sum(w(:));

% compute Fourier coefficients
L = 16;
odf_d = calcFourierODF(ori,'weights',weights,...
  'kernel',DirichletKernel(L),'silent');

sob = SobolevKernel(1,'bandwidth',L);

c = zeros(1,length(psi));

for i = 1:length(psi)
  
  kappa = psi{i}.kappa;
  
  % compute ODF
  eodf = conv(odf_d,(psi{i}*sob)^2);
  
  
  % compute BCV
  rf =  1/N * sum(1./(1-w) .* eval(eodf,ori)) ...
    - 1/N * eval(psi(i),0)* sum(w./(1-w));
  
  c(i) = (kappa+2)^(-2) * rf + pi/8 * kappa^(3/2) / NCS;
      
  disp(c(i));
  
end
