function odf = FourierODF(C,CS,SS,varargin)
% defines an ODF by its Fourier coefficients
%
%% Description
% *FourierODF* defines an  ODF by its Fourier coefficients
%
%% Syntax
%  odf = FourierODF(C,CS,SS)
%
%% Input
%  C      - Fourier coefficients / C -- coefficients
%  CS, SS - crystal, specimen @symmetry
%
%% Output
%  odf - @ODF
%
%% See also
% ODF/ODF uniformODF fibreODF unimodalODF

if isa(C,'ODF')
  
  odf = C;
  odf = set(odf,'center',[]);
  odf = set(odf,'c',1);
  odf = set(odf,'psi',[]);
  odf = set(odf,'options',{{'fourier'}});
  
else
  error(nargchk(3,3,nargin));
  argin_check(C,'double');
  argin_check(CS,'symmetry');
  argin_check(SS,'symmetry');

  odf = ODF(C,[],[],CS,SS,'Fourier');
end
