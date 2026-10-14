function sF = power(sF1,sF2)
% pointwise power of a symmetrised spherical function
%
% Syntax
%
%   sF = sF1.^a     % the power a of sF1, symmetric as sF1
%   sF = sF1.^sF2   % the symmetry is the one both functions share
%
% Input
%  sF1, sF2 - @S2FunHarmonicSym
%  a        - double
%
% Output
%  sF - @S2FunHarmonicSym


sF = power@S2FunHarmonic(sF1,sF2);

% try to preserve symmetry 
sym = [];
if isnumeric(sF1)
  sym = sF2.CS;
elseif isnumeric(sF2)
  sym = sF1.CS;
elseif isa(sF1,'S2FunHarmonicSym') && isa(sF2,'S2FunHarmonicSym') 
  sym = disjoint(sF1.CS,sF2.CS);
end
  
if ~isempty(sym), sF = S2FunHarmonicSym(sF.fhat,sym); end

end
