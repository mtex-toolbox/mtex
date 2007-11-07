function odf_hat = fourier(odf,varargin)
% get Fourier coefficients of and ODF
%
% Returns the Fourier coefficients of an ODF. If no option is specified all
% allready precomputed Fourier coefficients are returned. If the option
% 'order' is specified only Fourier coefficients of this specific order are
% returned. If the option 'bandwidth' is specified all Fourier coefficients
% up to this bandwidth are returned.
%
%% usage:  
% odf_hat = fourier(odf,'order',L)
% odf_hat = fourier(odf,'bandwidth',B)
%
%% Input
%  odf  - @ODF
%  L    - order of Fourier coefficients to be returned
%  B    - maximum order of Fourier coefficients to be returned
%
%% Output
%  odf_hat - Fourier coefficient - complex (2L+1)x(2L+1) matrix
%  
%% See also
% ODF/calcfourier ODF/textureindex ODF/entropy ODF/eval
%

% compute Fourier coefficients 
L = get_option(varargin,{'order','bandwidth'});
if nargin > 1, odf = calcfourier(odf,L);end

% sum up Fourier coefficients
odf_hat = zeros(deg2dim(L+1),1);

for i = 1:length(odf)
  l = min(length(odf(i).c_hat),length(odf_hat));
  odf_hat(1:l) = odf_hat(1:l) + reshape(odf(i).c_hat(1:l),[],1);  
end
  
if check_option(varargin,'order')
  odf_hat = reshape(odf_hat(deg2dim(L)+1:deg2dim(L+1)),2*L+1,2*L+1);
end
