classdef S2FunHarmonicSym < S2FunHarmonic
% a class represeneting a symmetrised function on the sphere

properties
  s = []; % symmetry
end

properties (Dependent = true)
  CS
  SS 
end


methods
  function sF = S2FunHarmonicSym(fhat, s)
    if nargin == 0, return; end
    sF.fhat = fhat;
    sF.s = s;
  end
  
  function CS = get.CS(sF)
    CS = sF.s;
  end
  
  function SS = get.SS(sF)
    SS = sF.s;
  end
  
end

methods (Static = true)
  sF = quadrature(f, varargin);
end

end
