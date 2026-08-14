classdef S2Fun
% an abstract class representing functions on the sphere
%
% 
% See also
% S2FunHarmonic S2FunBingham S2FunTri

properties (Abstract = true)
  s % symmetry / reference system
  isReal
end

properties (Dependent = true)
  CS, SS   % crystal / specimen symmetry - both refer to s
  how2plot % plotting convention
end

properties (Hidden = true)
  % the plotting convention of this function, empty means follow the one of
  % s - see get.how2plot
  how2plotPrivate = []
end

   
methods (Abstract = true)
  f = eval(sF,v,varargin)
end

methods
  
  function pC = get.how2plot(sF)
    % a function that was not given a convention of its own follows its
    % reference system, so setting s.how2plot keeps working as before
    pC = sF.how2plotPrivate;
    if isempty(pC), pC = sF.s.how2plot; end
  end

  function sF = set.how2plot(sF,pC)
    % stored on the function, never on sF.s: symmetry is a handle class and
    % the class default of s is one single specimenSymmetry shared by every
    % S2Fun, so writing the convention through s changed the plotting frame
    % of unrelated functions
    %
    % accept a string like 'y↑→x' as a shortcut, as symmetry does
    if ischar(pC) || isstring(pC), pC = plottingConvention(pC); end
    sF.how2plotPrivate = pC;
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

  function sF = power(sF1,sF2)
    %
    % Syntax
    %   sF = sF1.^a
    %

    if isnumeric(sF1)
      
      sF = S2FunHandle(@(v) sF1 .^ eval(sF2, v), sF2.s);
  
    elseif isnumeric(sF2)

      sF = S2FunHandle(@(v) eval(sF1, v) .^ sF2, sF1.s);

    else

      sF = S2FunHandle(@(v) eval(sF1, v) .^ eval(sF2, v), sF2.s);

    end

  end

 end


 methods (Static = true)
  
   s2F = smiley(varargin)
   s2F = unimodal(v,varargin)
    
 end

end
