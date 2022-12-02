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
%  odf - @SO3Fun
%
% See also
% uniformODF unimodalODF BinghamODF fibreODF

odf = SO3FunHarmonic(C,varargin{:});

end
