classdef uniformComponent
% obsolete ODF component, converted into an @SO3FunRBF when it is loaded
%
% This class is obsolete since MTEX 5.9. It is kept only so that @ODFs saved
% by older versions can be loaded; use @SO3FunRBF instead.
%
% Syntax
%
%   % an ODF saved before MTEX 5.9 is converted while it is loaded
%   load('odf.mat','odf')

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