function f_hat = calcFourier(odf,varargin)
% compute Fourier coefficients of odf
%
% Compute the Fourier coefficients of the ODF and store them in the
% returned ODF. In order to get the Fourier coefficients of an ODF use
% <ODF_Fourier.html Fourier>.
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

if nargin > 1 && isnumeric(varargin{1})
  L = max(varargin{1},4);
else
  L = get_option(varargin,'bandwidth',32);
end

f_hat = zeros(deg2dim(L+1),1);

for i = 1:numel(odf.components)
  
  hat = calcFourier(odf.components{i},L,varargin{:});
  
  f_hat(1:numel(hat)) = f_hat(1:numel(hat)) + odf.weights(i) * hat;
    
end

end
