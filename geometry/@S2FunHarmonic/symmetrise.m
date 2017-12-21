function sFs = symmetrise(sF, varargin)
% symmetrises a function with respect to a symmetry 
%
% Syntax
%  sFs = sF.symmetrise(cs)
%  sFs = sF.symmetrise(ss)
%
% Input
%  sF - @S2Fun
%  cs,ss - @crystalSymmetry, @specimenSymmetry
%
% Output
%  sFs - symmetrised @S2Fun
%

sym = getClass(varargin,'symmetry');

sFs = sF;
for j = 2:length(sym)
  sFs = sFs + sF.rotate(sym(j));
end

sFs = S2FunHarmonicSym(sFs.fhat, sym) ./ length(sym);

end
