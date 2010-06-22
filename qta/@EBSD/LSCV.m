function [psi,c] = LSCV(ebsd,varargin)
% Least squares cross valiadation

%% input

N = sampleSize(ebsd);
o = get(ebsd,'orientations');

%% prepare kernels for testing
for k = 1:5
  psi(k) = kernel('de la Vallee Poussin','halfwidth',40*degree/2^(k/4)); %#ok<AGROW>
end
psi = get_option(varargin,'kernel',psi);


%% compute Fourier coefficients
L = 32;
odf_d = calcODF(ebsd,'kernel',kernel('Dirichlet',L),'Fourier','L',L,'silent');

%%

c = zeros(1,length(psi));

for i = 1:length(psi)
  
  disp('.');
  % compute
  eodf = conv(odf_d,psi(i));
  c(i) = (1-2/N)./(1-1/N)^2 * norm(Fourier(eodf,'l2-normalization'))^2 ...
    + 1./(N-1)^2 * norm(psi(i))^2 ...
    - 2./(N-1) * sum(eval(eodf,o)) + 2./(N-1) * eval(psi(i),0); %#ok<EVLC>
  
end

