function modf = calcMODF(odf1,varargin)
% calculate the uncorrelated MODF from one or two ODF
%
%% Syntax  
% modf = calcMODF(odf,'bandwidth',32)
% modf = calcMODF(odf1,odf2,'bandwidth',32)
%
%% Input
%  odf  - @ODF
%
%% Options
% bandwidth - bandwidth for Fourier coefficients (default - 32)
% 
%% Output
%  modf - @ODF
%
%% See also
% EBSD/calcODF

%% first ODF
% compute Fourier coefficients 
L = get_option(varargin,'bandwidth',32);
odf1 = calcFourier(odf1,L);

% extract Fourier coefficients
odf1_hat = Fourier(odf1,'bandwidth',L);
L = min(bandwidth(odf1),L);

% % sum up Fourier coefficients
% odf_hat = zeros(deg2dim(L+1),1);
% 
% for i = 1:length(odf)
%   l = min(length(odf(i).c_hat),length(odf_hat));
%   odf_hat(1:l) = odf_hat(1:l) + reshape(odf(i).c_hat(1:l),[],1);  
% end
% 

%% second ODF
if nargin > 1 && isa(varargin{1},'ODF')
  odf2 = calcFourier(varargin{1},L);
  odf2_hat = Fourier(odf2,'bandwidth',L);
  L = min(bandwidth(odf2),L);
else  
  odf2 = odf1;
  odf2_hat = odf1_hat;
end

% compute Fourier coefficients of MODF
odf_hat = [odf1_hat(1)*odf2_hat(1);zeros(deg2dim(L+1)-1,1)];
for l = 1:L
  ind = deg2dim(l)+1:deg2dim(l+1);
  odf_hat(ind) = reshape(odf1_hat(ind),2*l+1,2*l+1)' * reshape(odf2_hat(ind),2*l+1,2*l+1) ./ (2*l+1);
end

% construct MODF
modf = FourierODF(odf_hat,get(odf1,'CS'),get(odf2,'CS'));
