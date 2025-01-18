classdef S2FunHarmonicSym < S2FunHarmonic
% a class representing a symmetric function on the sphere

methods
  function sF = S2FunHarmonicSym(fhat, s,varargin)
    if nargin == 0, return; end
    if isa(fhat,'S2FunHarmonic')
      sF = S2FunHarmonicSym(fhat.fhat,s,varargin{:});
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
      sF = sF.symmetrise;
    end
  end
    
end

methods (Static = true)
  sF = quadrature(f, varargin);
end

end
