function sF = symmetrise(sF, varargin)
% symmetrises a function with respect to a symmetry 
%
% Syntax
%  sF = sF.symmetrise(cs)
%  sF = sF.symmetrise(ss)
%
% Input
%  sF - spherical function
%  cs,ss - @crystalSymmetry, @specimenSymmetry
%
% Options
%  M - minimal degree of the spherical harmonic
%

sym = getClass(varargin,'symmetry');

for j = 2:length(sym)
  sF = sF + sF.rotate(sym(j));
end

sF = sphFunHarmonicS(sF.fhat, sym) ./ length(sym);

end
