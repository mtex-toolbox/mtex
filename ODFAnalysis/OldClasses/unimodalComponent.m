classdef unimodalComponent
% obsolete ODF component, kept to load ODFs saved before MTEX 5.9
%
% This class is obsolete since MTEX 5.9. Use the class @SO3FunRBF instead.
% The class is preserved, so that saved @ODFs can be loaded.
%
% Syntax
%
%   load('odf.mat')   % an ODF saved before MTEX 5.9 loads as @SO3FunRBF
%
% See also
% SO3FunRBF

methods (Static = true, Hidden=true)
  function odf = loadobj(s)
    psi = s.psi;
    if isempty(psi)
      psi = SO3DeLaValleePoussinKernel; 
      warning(['MTEX is not able to load the SO3Kernel of the unimodalODF, ' ...
        'because its class has been deleted. A standard kernel is used instead.'])
    end
    odf = SO3FunRBF(s.center,psi,s.weights);
  end
end

end