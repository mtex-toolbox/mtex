function sFs = symmetrise(sF, varargin)
% symmetrises a function with respect to a symmetry 
%
% Syntax
%  sFs = sF.symmetrise(cs)
%  sFs = sF.symmetrise(ss)
%
% Input
%  sF - @sphFun
%  cs,ss - @crystalSymmetry, @specimenSymmetry
%
% Output
%  sFs - symmetrised @sphFun
%
% Options
%  M - minimal degree of the spherical harmonic
%

sym = getClass(varargin,'symmetry');

sFs = sF;
for j = 2:length(sym)
  sFs = sFs + sF.rotate(sym(j));
end

sFs = sphFunHarmonicS(sFs.fhat, sym) ./ length(sym);

end
