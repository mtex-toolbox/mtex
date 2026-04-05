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
  SLeft  = specimenSymmetry.default
  SRight = specimenSymmetry.default
  bandwidth = getMTEXpref('maxSO3Bandwidth');
  antipodal = false
end

properties (Dependent = true)
  isReal
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

    if check_option(varargin,'antipodal')
      SO3F.antipodal = true;
    end
    
  end

  function n = numArgumentsFromSubscript(varargin)
    n = 0;
  end

  function out = get.isReal(f)
    rot = rotation.rand(100);
    out = isreal(f.eval(rot));
  end

  function F = set.isReal(F,value)
    if ~value, return; end
    F = SO3FunHandle(@(rot) real(F.eval(rot)),F.CS,F.SS);
  end
  
  % % Using antipodal as dependent property is not completely clean, since
  % % the get-routine may be inexact for functions, that are zero nearly
  % % everywhere. 
  %
  % function out = get.antipodal(f)
  %   rot = rotation.rand(100);
  %   out = norm(f.eval(rot)-f.eval(rot.inv))<1e-6;
  % end
  % 
  % function F = set.antipodal(F,value)
  %   if ~value, return; end
  %   ensureCompatibleSymmetries(F,'antipodal');
  %   F = SO3FunHandle(@(rot) 0.5*F.eval(rot) + 0.5*F.eval(rot.inv),F.CS,F.SS);
  % end

end


methods (Static = true)
   
  SO3F = example(varargin)

end


end
