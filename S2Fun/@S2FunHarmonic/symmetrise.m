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

if sF.bandwidth == 0
  sFs = S2FunHarmonicSym(sF.fhat, sym);
  return;
end

sym = getClass(varargin,'symmetry');

f = @(v) sF.eval(v);
for j = 2:length(sym)
  f = @(v) [f(v) sF.eval(rotate(v, sym(j)))];
end

sF = S2FunHarmonic.quadrature(f, 'bandwidth', sF.bandwidth);
sFs = S2FunHarmonic(0);
figure(2);
plot(sF);

for j = 1:length(sF)
  sFs = sFs+subSet(sF, j);
end

sFs = S2FunHarmonicSym(sFs.fhat, sym) ./ length(sym);

end
