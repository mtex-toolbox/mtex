classdef FourierComponent
% This class is obsolet since MTEX 6.0. Use the class @SO3FunHarmonic instead.
% Anyway the class is preserved, so that saved @ODFs can be loaded.
  
methods (Static = true, Hidden=true)
  function odf = loadobj(s)
    fhat = s.f_hat;
    CS = s.CS;
    SS = s.SS;
    if isempty(fhat), fhat = 0; end
    if isempty(CS), CS = crystalSymmetry; end
    if isempty(SS), SS = specimenSymmetry; end
    odf = SO3FunHarmonic(fhat,CS,SS);
    warning('The Fourier coefficients are normalized since MTEX Version 5.0.')
  end
end

end