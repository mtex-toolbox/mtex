function sF = times(sF1,sF2)
% overloads sF1 .* sF2
%
% Syntax
%   sF = sF1.*sF2
%   sF = a.*sF1
%   sF = sF1.*a
%
% Input
%   sF1, sF2 - S2FunHarmonic
%
% Output
%   sF - S2FunHarmonic
%

sF = times@S2FunHarmonic(sF1,sF2);

% try to preserve symmetry 
if isa(sF1,'S2FunHarmonicSym') && isa(sF2,'S2FunHarmonicSym') 
  sym = disjoint(sF1.CS,sF2.CS);
  sF = S2FunHarmonicSym(sF.fhat,sym);
end
  