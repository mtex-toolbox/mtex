function odf_hat = Fourier(odf,varargin)
% get Fourier coefficients of and ODF
%
% Returns the Fourier coefficients of an ODF. If no option is specified all
% allready precomputed Fourier coefficients are returned. If the option
% 'order' is specified only Fourier coefficients of this specific order are
% returned. If the option 'bandwidth' is specified all Fourier coefficients
% up to this bandwidth are returned.
%
%% Syntax  
% odf_hat = Fourier(odf,'order',L)
% odf_hat = Fourier(odf,'bandwidth',B)
%
%% Input
%  odf  - @ODF
%  L    - order of Fourier coefficients to be returned
%  B    - maximum order of Fourier coefficients to be returned
%
%% Options
%  l2-normalized - used L^2 normalization
%
%% Output
%  odf_hat - Fourier coefficient - complex (2L+1)x(2L+1) matrix
%  
%% See also
% ODF/plotFourier WiegnerD ODF/calcFourier FourierODF ODF/textureindex ODF/entropy ODF/eval
%

% compute Fourier coefficients 
L = get_option(varargin,{'order','bandwidth'},bandwidth(odf));
odf = calcFourier(odf,L);

% sum up Fourier coefficients
odf_hat = zeros(deg2dim(L+1),1);

for i = 1:length(odf)
  l = min(length(odf(i).c_hat),length(odf_hat));
  odf_hat(1:l) = odf_hat(1:l) + reshape(odf(i).c_hat(1:l),[],1);  
end

if check_option(varargin,'l2-normalization')
  for l = 0:L
    odf_hat(deg2dim(l)+1:deg2dim(l+1)) = ...
      odf_hat(deg2dim(l)+1:deg2dim(l+1)) ./ sqrt(2*l+1);    
  end
end
  
if check_option(varargin,'weighted')
  w = get_option(varargin,'weighted');
  for l = 0:L
    odf_hat(deg2dim(l)+1:deg2dim(l+1)) = ...
      odf_hat(deg2dim(l)+1:deg2dim(l+1)) .* w(l+1);
  end
end


if check_option(varargin,'order')
  odf_hat = reshape(odf_hat(deg2dim(L)+1:deg2dim(L+1)),2*L+1,2*L+1);
end
