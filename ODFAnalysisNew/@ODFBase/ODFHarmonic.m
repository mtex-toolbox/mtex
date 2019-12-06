function odf = ODFHarmonic(odf,varargin)
% compute Harmonic representation of an ODF
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

odf = ODFHarm(calcFourier(odf),odf.CS,odf.SS);

end
