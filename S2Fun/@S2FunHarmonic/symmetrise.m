function sFs = symmetrise(sF, varargin)
% symmetrises a function with respect to a symmetry 
%
% Syntax
%   sFs = sF.symmetrise(cs)
%   sFs = sF.symmetrise(ss)
%
% Input
%  sF - @S2Fun
%  cs,ss - @crystalSymmetry, @specimenSymmetry
%
% Output
%  sFs - symmetrised @S2Fun
%

% extract symmetry
sym = getClass(varargin,'symmetry');

% maybe we can set antipodal and save some time
if sym.isLaue
  symX = sym.properSubGroup;
  varargin = [varargin,'antipodal'];
else
  symX = sym;
end

% maybe there is nothing to do
if sF.bandwidth == 0 || length(symX) == 1
  sFs = S2FunHarmonicSym(sF.fhat, sym, varargin{:});
  return;
end

% define a symmetrized evaluation function
f = @(v) sF.eval(v);
fsym = @(v) mean(reshape(f(symX * v),length(symX),[]));

% compute Fourier coefficients by quadrature
sF = S2FunHarmonic.quadrature(fsym, 'bandwidth', sF.bandwidth,varargin{:});

% set up S2FunHarmonicSym
sFs = S2FunHarmonicSym(sF.fhat,sym);

end
