function odf = FourierODF(C,varargin)
% defines an ODF by its Fourier coefficients
%
% Syntax
%   odf = FourierODF(C,CS,SS)
%
% Input
%  C      - Fourier coefficients / C coefficients
%  CS, SS - crystal, specimen @symmetry
%
% Output
%  odf - @ODF
%
% See also
% ODF/ODF uniformODF fibreODF unimodalODF
   
odf = SO3FunHarmonic(C,varargin{:});

end
