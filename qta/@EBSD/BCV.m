function c = BCV(ebsd,psi)
% biased cross validation
%
%% Input
%  ebsd - @EBSD
%  psi  - @kernel
%% Output
%  c    - halfwidth
%
%% See also
% EBSD/calcODF EBSD/calcKernel grain/calcKernel EBSD/LSCV

% extract data
N = numel(ebsd);
NCS = N * numel(get(ebsd,'CS'));

o = get(ebsd,'orientations');
try
  w = get(ebsd,'weight');
  w = ones(size(w));
catch
  w = ones(size(o));
end
w = w ./ sum(w(:));
ebsd = set(ebsd,'weight',w);

% compute Fourier coefficients
L = 16;
odf_d = calcODF(ebsd,'kernel',kernel('Dirichlet',L),'Fourier',L,'silent');


sob = kernel('Sobolev',1,'bandwidth',L);

c = zeros(1,length(psi));

for i = 1:length(psi)
  
  kappa = get(psi(i),'kappa');
  
  % compute ODF
  eodf = conv(odf_d,(psi(i)*sob)^2);
  
  
  % compute BCV
  rf =  1/N * sum(1./(1-w) .* eval(eodf,o)) ...
    - 1/N * eval(psi(i),0)* sum(w./(1-w)); %#ok<EVLC>
  
  c(i) = (kappa+2)^(-2) * rf + pi/8 * kappa^(3/2) / NCS;
      
  disp(c(i));
  
end
