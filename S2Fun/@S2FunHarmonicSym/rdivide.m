function sF = rdivide(sF1, sF2)
%
% Syntax
%   sF = sF1/sF2
%   sF = sF1/a
%   sF = a/sF1
%
% Input
%   sF1, sF2 - @S2FunHarmonic
%   a - double
%
% Output
%   sF - @S2FunHarmonic
%

sF = rdivide@S2FunHarmonic(sF1,sF2);

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

