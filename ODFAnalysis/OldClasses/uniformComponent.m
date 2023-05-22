classdef uniformComponent
% This class is obsolet since MTEX 5.9. Use the class @SO3FunRBF instead.
% Anyway the class is preserved, so that saved @ODFs can be loaded.

methods (Static = true, Hidden=true)
  function odf = loadobj(s)
    CS = s.CS;
    SS = s.SS;
    if isempty(CS), CS = crystalSymmetry; end
    if isempty(SS), SS = specimenSymmetry; end
    ori = orientation(CS,SS);
    psi = SO3DeLaValleePoussinKernel;
    if s.antipodal==1, ori.antipodal=1; end
    odf = SO3FunRBF(ori,psi);
  end
end
    
end