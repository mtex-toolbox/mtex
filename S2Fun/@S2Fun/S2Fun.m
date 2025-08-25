classdef S2Fun
% an abstract class representing functions on the sphere
%
% 
% See also
% S2FunHarmonic S2FunBingham S2FunTri

properties (Abstract = true)
  s % symmetry / reference system
end

properties (Dependent = true)  
  CS, SS   % crystal / specimen symmetry - both refer to s
  how2plot % plotting convention 
end

   
methods (Abstract = true)
  f = eval(sF,v,varargin)
end

methods
  
  function out = isReal(~)
    out = true;
  end
  
  
  function pC = get.how2plot(sF)
    pC = sF.s.how2plot;
  end

  function sF = set.how2plot(sF,pC)
    sF.s.how2plot = pC;
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

  function n = numel(sF)
    n = prod(size(sF)); %#ok<PSIZE>
  end

 end


 methods (Static = true)
  
   s2F = smiley(varargin)
   s2F = unimodal(v,varargin)
    
 end

end
