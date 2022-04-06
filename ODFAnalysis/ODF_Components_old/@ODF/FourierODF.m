function odf = FourierODF(odf,varargin)
% compute FourierODF from another ODF
%
% Description
%
% Computes the Fourier coefficients of the ODF and store them in the
% returned @FourierODF. In order to get the Fourier coefficients of an ODF
% use <ODF.calcFourier.html calcFourier>.
%
% Syntax  
%   odf = FourierODF(odf,L)
%
% Input
%  odf  - @ODF
%  L    - order up to which Fourier coefficients are calculated
%
% Output
%  odf - @FourierODF where Fourier coefficients are stored for further use 
%
% See also
% ODF/plotFourier ODF/Fourier wignerD FourierODF ODF/textureindex ODF/entropy ODF/eval 
%

if length(odf.components) == 1 && isa(odf.components{1},'FourierComponent')
  return
end

f_hat = calcFourier(odf,varargin{:});
f_hat(1) = real(f_hat(1));

if abs(f_hat(1)) > 1e-10
  odf.weights = f_hat(1);
  f_hat = f_hat ./ odf.weights;
else
  odf.weights = 1;
end

ap = odf.antipodal;
odf.components = {FourierComponent(f_hat,odf.CS,odf.SS)};
odf.antipodal = ap;

end
