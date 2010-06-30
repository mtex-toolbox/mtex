function c = LSCV(ebsd,psi,varargin)
% least squares cross valiadation
%
%% Input
%  ebsd - @EBSD
%  psi  - @kernel
%
%% Output
%  c
%
%% See also
% EBSD/calcODF EBSD/calcKernel grain/calcKernel EBSD/BCV

% extract data
N = sampleSize(ebsd);
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
L = 32;
odf_d = calcODF(ebsd,'kernel',kernel('Dirichlet',L),'Fourier',L,'silent');


c = zeros(1,length(psi));

for i = 1:length(psi)
  
  % compute ODF
  eodf = conv(odf_d,psi(i));
  
  %c(i) = (1-2/N)./(1-1/N)^2 * norm(Fourier(eodf,'l2-normalization'))^2 ...
  %  + 1./(N-1)^2 * norm(psi(i))^2 ...
  %  - 2./(N-1) * sum(eval(eodf,o)) + 2./(N-1) * eval(psi(i),0); %#ok<EVLC>
  
  % compute LSCV
  c(i) = (1-1/N)^2 * norm(Fourier(eodf,'l2-normalization'))^2 ...
    - 2/N * sum(1./(1-w) .* eval(eodf,o)) ...
    + 2/N * eval(psi(i),0)* sum(w./(1-w)); %#ok<EVLC>
    
  % compute something else ---> no sence
  %c(i) = sum(w.^2./(1-w).^2) * ...
  %  ( norm(Fourier(eodf,'l2-normalization'))^2 + norm(psi(i)) ) ...
  %  - sum(w.^2./(1-w).^2 .* eval(conv(eodf,psi(i)),o));
    
  disp(c(i));
  
end

