function f_hat = calcFourier(odf,L,varargin)
% compute Fourier coefficients of odf
%
% Compute the Fourier coefficients of the ODF and store them in the
% returned ODF. In order to get the Fourier coefficients of an ODF use
% [[ODF_Fourier.html,Fourier]].
%
% Syntax  
%   odf = calcFourier(odf,L)
%
% Input
%  odf  - @ODF
%  L    - order up to which Fourier coefficients are calculated
%
% Output
%  nodf - @ODF where Fourier coefficients are stored for further use 
%
% See also
% ODF/plotFourier ODF/Fourier wignerD FourierODF ODF/textureindex ODF/entropy ODF/eval 
%

L = max(L,4);

f_hat = zeros(deg2dim(L+1),1);

for i = 1:numel(odf)
  
  hat = doFourier(odf(i),L,varargin{:});
  
  f_hat(1:numel(hat)) = f_hat(1:numel(hat)) + odf(i).weight * hat;
    
end

end
