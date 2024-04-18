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
  function sF = S2FunHarmonicSym(fhat, s,varargin)
    if nargin == 0, return; end
    if isa(fhat,'S2FunHarmonic')
      sF = S2FunHarmonicSym(fhat.fhat,s);
      return
    elseif isa(fhat,'S2Fun')
      fhat = S2FunHarmonic.quadrature(fhat);
      sF = S2FunHarmonicSym(fhat,s);
      return
    elseif isa(fhat,'S2Kernel')
      psi = fhat;
      bw = psi.bandwidth;
      fhat = zeros((bw+1)^2,1);
      for l = 0:bw
        fhat(l^2+1+l) = 2*sqrt(pi)./sqrt(2*l+1)*psi.A(l+1); 
      end
      sF = S2FunHarmonicSym(fhat,s);
      return
    end

    sF.fhat = fhat;
    sF.s = s;
    if ~check_option(varargin,'skipSymmetrise')
      sF.symmetrise;
    end
  end
  
  function CS = get.CS(sF)
    CS = sF.s;
  end
  function SS = get.SS(sF)
    SS = sF.s;
  end
  function sF = set.CS(sF,CS)
    sF.s = CS;
  end
  function sF = set.SS(sF,SS)
    sF.s = SS;
  end
  
end

methods (Static = true)
  sF = quadrature(f, varargin);
end

end
