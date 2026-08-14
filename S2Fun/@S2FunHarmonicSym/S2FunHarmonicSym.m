classdef S2FunHarmonicSym < S2FunHarmonic
% a class representing a symmetric function on the sphere
%
% This is the one S2Fun that holds a symmetry - the abstract classes
% carry only a referenceFrame, which for a symmetrised function is the
% frame of its symmetry.

properties
  s % the symmetry
end

properties (Dependent = true)
  CS, SS % crystal / specimen symmetry - both refer to s
end

methods

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

  function fr = getFrame(sF)
    % the frame of a symmetrised function is the frame of its symmetry -
    % resolved live, so it can never go stale when s is replaced
    if isempty(sF.s)
      fr = sF.framePrivate;
    else
      fr = sF.s.frame;
    end
  end

  function sF = setFrame(sF,fr) %#ok<INUSD>
    error('MTEX:S2Fun:fixedFrame',...
      ['The frame of a symmetrised S2Fun is the frame of its symmetry ' ...
      '- assign sF.s instead.']);
  end

  function s = getSym(sF)
    s = sF.s;
  end

  function sF = S2FunHarmonicSym(fhat, s,varargin)
    if nargin == 0, return; end
    if isa(fhat,'S2FunHarmonic')
      sF.fhat = fhat.fhat;
      % only a convention fhat carried itself, not the one it merely
      % inherited from its old symmetry - otherwise attaching s here would
      % not put the function into the frame of s
      sF.how2plotPrivate = fhat.how2plotPrivate;
      sF.CS = s;
      %sF = sF.symmetrise;
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
  sF = example(varargin);
end

end
