classdef FourierComponent
% This class is obsolet since MTEX 5.9. Use the class @SO3FunHarmonic instead.
% Anyway the class is preserved, so that saved @ODFs can be loaded.
  
methods (Static = true, Hidden=true)
  function odf = loadobj(s)
    fhat = s.f_hat;
    CS = s.CS;
    SS = s.SS;
    if isempty(fhat), fhat = 0; end
    if isempty(CS), CS = crystalSymmetry; end
    if isempty(SS), SS = specimenSymmetry; end
    odf = SO3FunHarmonic(fhat);
    % We use L2-normalized Wigner-D functions since MTEX Version 5.9.
    odf = L2normalizeFourierCoefficients(odf);
    % The ODFs has been real valued before MTEX verison 5.9.
    odf.isReal = 1;
    % do not symmetrise odf by defining the symmetries.
    odf.CS = CS;
    odf.SS = SS;
  end
end

end