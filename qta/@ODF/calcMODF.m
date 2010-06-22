function modf = calcMODF(odf,varargin)
% calculate the uncorrelated MODF from an ODF
%
%% Syntax  
%
%% Input
%  odf  - @ODF
%
%% Options
%
%% Output
%  modf - @ODF
%
%% See also
%

% compute Fourier coefficients 
odf = calcFourier(odf,32);
L = bandwidth(odf);

% sum up Fourier coefficients
odf_hat = zeros(deg2dim(L+1),1);

for i = 1:length(odf)
  l = min(length(odf(i).c_hat),length(odf_hat));
  odf_hat(1:l) = odf_hat(1:l) + reshape(odf(i).c_hat(1:l),[],1);  
end

% compute Fourier coefficients of MODF
for l = 1:L
  ind = deg2dim(l)+1:deg2dim(l+1);
  odf_hat(ind) = reshape(odf_hat(ind),2*l+1,2*l+1)' * reshape(odf_hat(ind),2*l+1,2*l+1) ./ (2*l+1);
end

% construct MODF
modf = FourierODF(odf_hat,get(odf,'CS'),get(odf,'CS'));
