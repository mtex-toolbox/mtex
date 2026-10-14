function sF = plus(sF1,sF2)
% add symmetric spherical functions, keeping their common symmetry
%
% Syntax
%
%   sF = sF1 + sF2 % sum of two functions
%   sF = sF1 + a   % function plus a number
%
% Input
%  sF1, sF2 - @S2FunHarmonicSym
%  a - double
%
% Output
%  sF - @S2FunHarmonicSym
%

% call parent method
sF = plus@S2FunHarmonic(sF1,sF2);

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
