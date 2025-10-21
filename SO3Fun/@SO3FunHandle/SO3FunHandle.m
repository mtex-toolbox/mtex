classdef SO3FunHandle < SO3Fun
% a class representing a function on the rotation group by an function
% handle
%
% Syntax
%   SO3F = SO3FunHandle(fun)
%
% Input
%  fun - @function_handle
%
% Output
%  SO3F - @SO3FunHandle
%
% Example
%
%   r = orientation.rand;
%   SO3F = SO3FunHandle(@(rot) angle(rot,r))
%
properties
  fun
  % TODO: antipodal wird weder erkannt noch gesetzt/verwendet
  antipodal = false
  SLeft  = specimenSymmetry
  SRight = specimenSymmetry
  bandwidth = getMTEXpref('maxSO3Bandwidth');
end

methods
  
  function SO3F = SO3FunHandle(fun,varargin)

    if isa(fun,'SO3Fun')
      SO3F.fun = @(rot) fun.eval(rot);
      SO3F.SRight = fun.SRight;
      SO3F.SLeft = fun.SLeft;
      return
    end
    
    SO3F.fun = fun;

    [SRight,SLeft] = extractSym(varargin);
    SO3F.SRight = SRight;
    SO3F.SLeft = SLeft;
    
  end

  function n = numArgumentsFromSubscript(varargin)
    n = 0;
  end
  
end


methods (Static = true)
   
  SO3F = example(varargin)

end


end
